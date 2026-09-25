import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_alice/core/alice_dio_interceptor.dart';
import 'package:flutter_alice/model/alice_http_call.dart';
import 'package:flutter_alice/theme/theme.dart';
import 'package:flutter_alice/ui/page/statistics/alice_stats_screen.dart';

import 'alice_core.dart';
import 'expandable_fab.dart';

class AliceInspector extends StatefulWidget {
  final Widget? child;
  final bool debug;
  final List<Dio>? dios;
  final int limitLogs;
  final GlobalKey<NavigatorState>? navigatorKey;

  /// Milliseconds threshold to consider an API slow (default: 2000ms = 2s)
  final int urgentSlowDurationMs;

  /// Max requests allowed in [urgentFrequencyWindow] before marking as high frequency (default: 5)
  final int urgentFrequencyThreshold;

  /// Time window to check request frequency (default: 3 seconds)
  final Duration urgentFrequencyWindow;

  const AliceInspector({
    super.key,
    this.child,
    this.debug = true,
    this.dios,
    this.limitLogs = 1000,
    this.navigatorKey,
    this.urgentSlowDurationMs = 2000,
    this.urgentFrequencyThreshold = 5,
    this.urgentFrequencyWindow = const Duration(seconds: 3),
  });

  @override
  State<AliceInspector> createState() => _AliceInspectorState();
}

class _AliceInspectorState extends State<AliceInspector>
    with SingleTickerProviderStateMixin {
  final aliceCore = AliceCore.inst;
  static const _expandedDistance = 80.0;
  static const _fabSize = 48.0;

  final GlobalKey<ExpandableFabState> _fabKey = GlobalKey<ExpandableFabState>();

  Offset _offset = Offset.zero;
  bool _isMenuOpen = false;
  bool _isInitialized = false;

  AnimationController? _snapController;
  Animation<Offset>? _snapAnimation;

  @override
  void initState() {
    super.initState();
    aliceCore.limitLogs = widget.limitLogs;
    if (widget.navigatorKey != null) {
      aliceCore.setNavigatorKey(widget.navigatorKey!);
    } else if (aliceCore.navigatorKey == null) {
      debugPrint(
        "AliceInspector: NavigatorKey is not set. "
        "Please provide a navigatorKey to AliceInspector or AliceCore.",
      );
      throw Exception(
        'AliceInspector: NavigatorKey is not set.\n'
        'Please provide a navigatorKey to AliceInspector or AliceCore.\n'
        'navigatorKey: navigatorKey, or alice.setNavigatorKey(navigatorKey)',
      );
    }

    if (widget.dios != null && widget.debug) {
      final interceptor = aliceCore.getDioInterceptor();
      for (final dio in widget.dios!) {
        dio.interceptors.removeWhere((e) => e is AliceDioInterceptor);
        dio.interceptors.add(interceptor);
      }
    }

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
          size.width - padding.right - _fabSize - 12.0,
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
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final padding = mediaQuery.padding;

    final minX = padding.left + 8.0;
    final maxX = size.width - padding.right - _fabSize - 8.0;
    final minY = padding.top + 8.0;
    final maxY = size.height - padding.bottom - _fabSize - 8.0;

    setState(() {
      final newX = (_offset.dx + details.delta.dx)
          .clamp(minX, math.max(minX, maxX))
          .toDouble();
      final newY = (_offset.dy + details.delta.dy)
          .clamp(minY, math.max(minY, maxY))
          .toDouble();
      _offset = Offset(newX, newY);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final padding = mediaQuery.padding;

    final minX = padding.left + 8.0;
    final maxX = size.width - padding.right - _fabSize - 8.0;
    final midX = (minX + maxX) / 2;

    final targetX = _offset.dx < midX ? minX : maxX;
    _animateSnap(Offset(targetX, _offset.dy));
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
    if (!widget.debug) return widget.child ?? const SizedBox.shrink();

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
      left = expandTowardsLeft ? _offset.dx - _expandedDistance : _offset.dx;
      top = expandDownwards ? _offset.dy : _offset.dy - _expandedDistance;
    } else {
      left = _offset.dx;
      top = _offset.dy;
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Theme(
        data: aliceTheme,
        child: Stack(
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
                  child: _buildDraggyWidget(
                    expandTowardsLeft: expandTowardsLeft,
                    expandDownwards: expandDownwards,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraggyWidget({
    required bool expandTowardsLeft,
    required bool expandDownwards,
  }) {
    return ExpandableFab(
      key: _fabKey,
      fabSize: _fabSize,
      distance: _expandedDistance,
      expandTowardsLeft: expandTowardsLeft,
      expandDownwards: expandDownwards,
      onOpenChanged: (isOpen) => setState(() => _isMenuOpen = isOpen),
      bigButton: _buildBigButton(context),
      children: [
        ActionButton(
          size: _fabSize,
          tooltip: "Clear requests",
          onPressed: aliceCore.clears,
          foregroundColor: AliceColors.error,
          icon: const Icon(Icons.delete_outline),
        ),
        ActionButton(
          size: _fabSize,
          tooltip: "Statistics",
          onPressed: () => aliceCore.push((_) => AliceStatsScreen(aliceCore)),
          foregroundColor: AliceColors.primary,
          icon: const Icon(Icons.bar_chart_rounded),
        ),
      ],
    );
  }

  /// Checks if any urgent condition is met:
  /// 1. High frequency: >= [widget.urgentFrequencyThreshold] requests within [widget.urgentFrequencyWindow].
  /// 2. Slow API: Any recent request finished with duration >= [widget.urgentSlowDurationMs] ms,
  ///    or currently loading for >= [widget.urgentSlowDurationMs] ms.
  bool _checkIsUrgent(List<AliceHttpCall> calls) {
    if (calls.isEmpty) return false;

    final now = DateTime.now();

    // 1. Check slow requests (either finished with long duration or currently hanging)
    final hasSlow = calls.any((c) {
      if (c.duration >= widget.urgentSlowDurationMs) return true;
      if (c.loading && c.request?.time != null) {
        if (now.difference(c.request!.time).inMilliseconds >=
            widget.urgentSlowDurationMs) {
          return true;
        }
      }
      return false;
    });
    if (hasSlow) return true;

    // 2. Check high frequency: count requests in recent time window
    int recentCount = 0;
    for (final c in calls) {
      final reqTime = c.request?.time;
      if (reqTime != null &&
          now.difference(reqTime) <= widget.urgentFrequencyWindow) {
        recentCount++;
        if (recentCount >= widget.urgentFrequencyThreshold) {
          return true;
        }
      }
    }

    return false;
  }

  Widget _buildBigButton(BuildContext context) {
    const fontSize = _fabSize * 0.32;
    const smallFontSize = _fabSize * 0.27;
    const dotSize = _fabSize * 0.2;
    const dotOffset = _fabSize * 0.08;
    const dotBorderWidth = _fabSize * 0.035;

    Widget button = SizedBox(
      width: _fabSize,
      height: _fabSize,
      child: Opacity(
        opacity: 0.6,
        child: Material(
          color: AliceColors.primary,
          shape: const CircleBorder(),
          elevation: 4.0,
          shadowColor: AliceColors.primaryDark.withValues(alpha: 0.45),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            customBorder: const CircleBorder(),
            splashColor: Colors.white.withValues(alpha: 0.35),
            highlightColor: Colors.white.withValues(alpha: 0.15),
            onTap: () {
              if (_isMenuOpen) {
                _fabKey.currentState?.close();
              } else {
                aliceCore.navigateToCallListScreen();
              }
            },
            onLongPress: () {
              _fabKey.currentState?.toggle();
            },
            child: StreamBuilder<List<AliceHttpCall>>(
              initialData: const [],
              stream: aliceCore.callsSubject.stream,
              builder: (_, snapshot) {
                final calls = snapshot.data ?? [];
                final count = calls.length;
                final countText = count > 99 ? '99+' : '$count';
                final isUrgent = _checkIsUrgent(calls);

                return Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Text(
                      countText,
                      style: AliceStyles.monoBold.copyWith(
                        color: Colors.white,
                        fontSize: count > 99 ? smallFontSize : fontSize,
                      ),
                    ),
                    if (isUrgent)
                      Positioned(
                        top: dotOffset,
                        right: dotOffset,
                        child: Container(
                          width: dotSize,
                          height: dotSize,
                          decoration: BoxDecoration(
                            color: AliceColors.error,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: dotBorderWidth,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );

    if (Overlay.maybeOf(context) != null) {
      button = Tooltip(
        message: "Alice Inspector\nTap: Open calls\nHold: Quick actions",
        preferBelow: false,
        child: button,
      );
    }

    return button;
  }
}
