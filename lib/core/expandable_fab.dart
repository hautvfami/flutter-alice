//
// Created by HauTV3 on 11/19/21.
// Copyright (c) 2021 OMG. All rights reserved.
//

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_alice/theme/theme.dart';

@immutable
class ExpandableFab extends StatefulWidget {
  const ExpandableFab({
    super.key,
    this.initialOpen,
    required this.distance,
    required this.children,
    required this.bigButton,
    this.animationDuration = const Duration(milliseconds: 250),
    this.curve = Curves.fastOutSlowIn,
    this.reverseCurve = Curves.easeOutQuad,
    this.enableHapticFeedback = true,
    this.expandTowardsLeft = true,
    this.expandDownwards = false,
    this.onOpenChanged,
    this.fabSize = 48.0,
  });

  final bool? initialOpen;
  final double distance;
  final List<Widget> children;
  final Widget bigButton;
  final Duration animationDuration;
  final Curve curve;
  final Curve reverseCurve;
  final bool enableHapticFeedback;
  final bool expandTowardsLeft;
  final bool expandDownwards;
  final ValueChanged<bool>? onOpenChanged;
  final double fabSize;

  @override
  State<ExpandableFab> createState() => ExpandableFabState();
}

class ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _open = false;

  bool get isOpen => _open;

  @override
  void initState() {
    super.initState();
    _open = widget.initialOpen ?? false;
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: widget.animationDuration,
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: widget.curve,
      reverseCurve: widget.reverseCurve,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void open() {
    if (!_open) _toggle();
  }

  void close() {
    if (_open) _toggle();
  }

  void toggle() => _toggle();

  void _toggle() {
    setState(() {
      _open = !_open;
    });
    if (_open) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
    widget.onOpenChanged?.call(_open);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final isExpanded = _open || _controller.value > 0;
        final totalSize = widget.distance + widget.fabSize;
        final width = isExpanded ? totalSize : widget.fabSize;
        final height = isExpanded ? totalSize : widget.fabSize;

        final alignment = _getStackAlignment();

        return SizedBox(
          width: width,
          height: height,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: alignment,
            children: [
              if (isExpanded) ..._buildExpandingActionButtons(),
              _buildTapToCloseFab(),
              _buildTapToOpenFab(),
            ],
          ),
        );
      },
    );
  }

  Alignment _getStackAlignment() {
    if (widget.expandTowardsLeft && !widget.expandDownwards) {
      return Alignment.bottomRight;
    } else if (!widget.expandTowardsLeft && !widget.expandDownwards) {
      return Alignment.bottomLeft;
    } else if (widget.expandTowardsLeft && widget.expandDownwards) {
      return Alignment.topRight;
    } else {
      return Alignment.topLeft;
    }
  }

  Widget _buildTapToCloseFab() {
    return IgnorePointer(
      ignoring: !_open,
      child: FadeTransition(
        opacity: _expandAnimation,
        child: ScaleTransition(
          scale: _expandAnimation,
          child: Material(
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            elevation: 4.0,
            color: AliceColors.surface,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _toggle,
              child: SizedBox(
                width: widget.fabSize,
                height: widget.fabSize,
                child: Center(
                  child: Icon(
                    Icons.close,
                    color: AliceColors.primaryDark,
                    size: widget.fabSize * 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;
    if (count == 0) return children;

    final hSign = widget.expandTowardsLeft ? -1.0 : 1.0;
    final vSign = widget.expandDownwards ? 1.0 : -1.0;

    for (var i = 0; i < count; i++) {
      final double dx;
      final double dy;

      if (count == 1) {
        dx = 0.0;
        dy = vSign * widget.distance;
      } else {
        // Quarter circle arc from vertical (0) to horizontal (pi/2)
        final theta = (i / (count - 1)) * (math.pi / 2.0);
        dx = hSign * widget.distance * math.sin(theta);
        dy = vSign * widget.distance * math.cos(theta);
      }

      final childWidget = widget.children[i];
      final Widget interactiveChild;
      if (childWidget is ActionButton) {
        interactiveChild = ActionButton(
          key: childWidget.key,
          size: childWidget.size,
          icon: childWidget.icon,
          tooltip: childWidget.tooltip,
          backgroundColor: childWidget.backgroundColor,
          foregroundColor: childWidget.foregroundColor,
          onPressed: () {
            _toggle();
            childWidget.onPressed?.call();
          },
        );
      } else {
        interactiveChild = GestureDetector(
          onTap: () {
            _toggle();
          },
          child: childWidget,
        );
      }

      children.add(
        _ExpandingActionButton(
          dx: dx,
          dy: dy,
          progress: _expandAnimation,
          child: interactiveChild,
        ),
      );
    }
    return children;
  }

  Widget _buildTapToOpenFab() {
    return IgnorePointer(
      ignoring: _open,
      child: AnimatedOpacity(
        opacity: _open ? 0.0 : 1.0,
        curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
        duration: widget.animationDuration,
        child: GestureDetector(
          onLongPress: _toggle,
          child: SizedBox(
            width: widget.fabSize,
            height: widget.fabSize,
            child: widget.bigButton,
          ),
        ),
      ),
    );
  }
}

@immutable
class _ExpandingActionButton extends StatelessWidget {
  const _ExpandingActionButton({
    required this.dx,
    required this.dy,
    required this.progress,
    required this.child,
  });

  final double dx;
  final double dy;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final currentDx = dx * progress.value;
        final currentDy = dy * progress.value;

        return Transform.translate(
          offset: Offset(currentDx, currentDy),
          child: Transform.scale(
            scale: progress.value,
            child: child,
          ),
        );
      },
      child: FadeTransition(opacity: progress, child: child),
    );
  }
}

@immutable
class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    this.onPressed,
    required this.icon,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.size = 48.0,
  });

  final VoidCallback? onPressed;
  final Widget icon;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = backgroundColor ?? (isDark ? AliceColors.surfaceDark : Colors.white);
    final fg = foregroundColor ?? (isDark ? Colors.white : AliceColors.primaryDark);

    Widget button = Material(
      color: bg,
      shape: const CircleBorder(),
      elevation: 4.0,
      shadowColor: Colors.black38,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: IconTheme(
              data: IconThemeData(color: fg, size: 20.0),
              child: icon,
            ),
          ),
        ),
      ),
    );

    if (tooltip != null &&
        tooltip!.isNotEmpty &&
        Overlay.maybeOf(context) != null) {
      button = Tooltip(
        message: tooltip!,
        preferBelow: false,
        child: button,
      );
    }

    return button;
  }
}
