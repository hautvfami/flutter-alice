import 'package:flutter/material.dart';
import 'package:flutter_alice/core/expandable_fab.dart';

import 'alice_drag_bounds.dart';

/// A draggable overlay widget that encapsulates position management,
/// drag gestures, edge snapping, menu expansion, and backdrop.
///
/// This widget is purely focused on UI layout, movement, and presentation.
/// The [bigButton] (or [bigButtonBuilder]) and action [children] are provided externally.
class AliceDraggableOverlay extends StatefulWidget {
  final Widget? child;
  final Widget? bigButton;
  final Widget Function(BuildContext context, VoidCallback toggleMenu)? bigButtonBuilder;
  final List<Widget> children;

  static const double fabSize = 48.0;
  static const double expandedDistance = 80.0;

  const AliceDraggableOverlay({
    super.key,
    this.child,
    this.bigButton,
    this.bigButtonBuilder,
    this.children = const [],
  }) : assert(
          bigButton != null || bigButtonBuilder != null,
          'Either bigButton or bigButtonBuilder must be provided',
        );

  @override
  State<AliceDraggableOverlay> createState() => _AliceDraggableOverlayState();
}

class _AliceDraggableOverlayState extends State<AliceDraggableOverlay>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ExpandableFabState> _fabKey = GlobalKey<ExpandableFabState>();
  bool _isMenuOpen = false;
  Offset _offset = Offset.zero;
  bool _isInitialized = false;

  AnimationController? _snapController;
  Animation<Offset>? _snapAnimation;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _snapController!.addListener(() {
      if (_snapAnimation != null) {
        setState(() {
          _offset = _snapAnimation!.value;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final size = MediaQuery.sizeOf(context);
      final padding = MediaQuery.paddingOf(context);
      setState(() {
        _offset = Offset(
          size.width - padding.right - AliceDraggableOverlay.fabSize - 12.0,
          padding.top + 100.0,
        );
        _isInitialized = true;
      });
    });
  }

  @override
  void dispose() {
    _snapController?.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isMenuOpen) {
      _fabKey.currentState?.close();
    }
    final bounds = AliceDragBounds.fromMediaQuery(
      MediaQuery.of(context),
      AliceDraggableOverlay.fabSize,
    );
    setState(() {
      _offset = bounds.clamp(_offset, details.delta);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final bounds = AliceDragBounds.fromMediaQuery(
      MediaQuery.of(context),
      AliceDraggableOverlay.fabSize,
    );
    _animateSnap(bounds.snapTarget(_offset));
  }

  void _animateSnap(Offset target) {
    if (_snapController == null) return;
    _snapAnimation = Tween<Offset>(
      begin: _offset,
      end: target,
    ).animate(
      CurvedAnimation(
        parent: _snapController!,
        curve: Curves.easeOutCubic,
      ),
    );
    _snapController!.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final midX = mediaQuery.size.width / 2;
    final isDockedOnLeft = _offset.dx < midX;
    final isNearTop = _offset.dy < (mediaQuery.padding.top + 140.0);

    final expandTowardsLeft = !isDockedOnLeft;
    final expandDownwards = isNearTop;

    // Adjust position when menu is open so the anchor FAB stays stationary
    final double left;
    final double top;
    if (_isMenuOpen) {
      left = expandTowardsLeft
          ? _offset.dx - AliceDraggableOverlay.expandedDistance
          : _offset.dx;
      top = expandDownwards
          ? _offset.dy
          : _offset.dy - AliceDraggableOverlay.expandedDistance;
    } else {
      left = _offset.dx;
      top = _offset.dy;
    }

    final Widget effectiveBigButton = widget.bigButtonBuilder != null
        ? widget.bigButtonBuilder!(
            context,
            () => _fabKey.currentState?.toggle(),
          )
        : widget.bigButton!;

    return Stack(
      children: [
        if (widget.child != null) widget.child!,
        if (_isMenuOpen)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _fabKey.currentState?.close(),
              child: Container(
                color: Colors.black.withValues(alpha: 0.25),
              ),
            ),
          ),
        if (_isInitialized)
          Positioned(
            left: left,
            top: top,
            child: GestureDetector(
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: ExpandableFab(
                key: _fabKey,
                fabSize: AliceDraggableOverlay.fabSize,
                distance: AliceDraggableOverlay.expandedDistance,
                expandTowardsLeft: expandTowardsLeft,
                expandDownwards: expandDownwards,
                onOpenChanged: (isOpen) =>
                    setState(() => _isMenuOpen = isOpen),
                bigButton: effectiveBigButton,
                children: widget.children,
              ),
            ),
          ),
      ],
    );
  }
}
