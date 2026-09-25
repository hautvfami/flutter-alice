import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_alice/core/alice_dio_interceptor.dart';
import 'package:flutter_alice/core/expandable_fab.dart';
import 'package:flutter_alice/theme/theme.dart';
import 'package:flutter_alice/ui/page/statistics/alice_stats_screen.dart';

import 'alice_core.dart';
import 'inspector/alice_bubble_evaluator.dart';
import 'inspector/alice_draggable_overlay.dart';
import 'inspector/alice_inspector_bubble.dart';

export 'expandable_fab.dart';
export 'inspector/alice_bubble_evaluator.dart';
export 'inspector/alice_bubble_status.dart';
export 'inspector/alice_drag_bounds.dart';
export 'inspector/alice_draggable_overlay.dart';
export 'inspector/alice_inspector_bubble.dart';

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

class _AliceInspectorState extends State<AliceInspector> {
  final aliceCore = AliceCore.inst;

  AliceBubbleEvaluator get _evaluator => AliceBubbleEvaluator(
        slowDurationMs: widget.urgentSlowDurationMs,
        frequencyThreshold: widget.urgentFrequencyThreshold,
        frequencyWindow: widget.urgentFrequencyWindow,
      );

  @override
  void initState() {
    super.initState();
    _initAlice();
  }

  void _initAlice() {
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
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.debug) return widget.child ?? const SizedBox.shrink();

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Theme(
        data: aliceTheme,
        child: AliceDraggableOverlay(
          bigButtonBuilder: (_, toggleMenu) => AliceInspectorBubble(
            callsStream: aliceCore.callsSubject.stream,
            evaluator: _evaluator,
            onTap: () => aliceCore.navigateToCallListScreen(),
            onLongPress: toggleMenu,
          ),
          children: [
            ActionButton(
              tooltip: "Clear requests",
              onPressed: aliceCore.clears,
              foregroundColor: AliceColors.error,
              icon: const Icon(Icons.delete_outline),
            ),
            ActionButton(
              tooltip: "Statistics",
              onPressed: () => aliceCore.push(
                (_) => AliceStatsScreen(aliceCore),
              ),
              foregroundColor: AliceColors.primary,
              icon: const Icon(Icons.bar_chart_rounded),
            ),
          ],
          child: widget.child,
        ),
      ),
    );
  }
}
