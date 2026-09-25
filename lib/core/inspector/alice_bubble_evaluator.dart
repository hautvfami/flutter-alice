import 'package:flutter/material.dart';
import 'package:flutter_alice/model/alice_http_call.dart';
import 'package:flutter_alice/theme/theme.dart';
import 'alice_bubble_status.dart';

/// Evaluates bubble status based solely on slow API and duplicate API thresholds.
class AliceBubbleEvaluator {
  final int slowDurationMs;
  final int frequencyThreshold;
  final Duration frequencyWindow;

  const AliceBubbleEvaluator({
    required this.slowDurationMs,
    required this.frequencyThreshold,
    required this.frequencyWindow,
  });

  /// Evaluates bubble status based solely on slow API and duplicate API thresholds:
  /// - [AliceBubbleStatus.urgent] (Red): >= 100% of threshold
  ///   (duration >= [slowDurationMs] or endpoint count >= [frequencyThreshold])
  /// - [AliceBubbleStatus.warning] (Yellow): >= 60% of threshold
  ///   (duration >= 60% of [slowDurationMs] or endpoint count >= 60% of [frequencyThreshold])
  /// - [AliceBubbleStatus.normal] (Green): < 60% of threshold
  AliceBubbleStatus evaluate(List<AliceHttpCall> calls) {
    if (calls.isEmpty) return AliceBubbleStatus.normal;

    final now = DateTime.now();

    final slowUrgentThreshold = slowDurationMs;
    final slowWarningThreshold = (slowDurationMs * 0.6).round();

    final freqUrgentThreshold = frequencyThreshold;
    final freqWarningThreshold = (frequencyThreshold * 0.6).ceil();

    bool hasUrgent = false;
    bool hasWarning = false;

    final Map<String, int> endpointCounts = {};

    for (final c in calls) {
      final reqTime = c.request?.time;
      if (reqTime == null) continue;

      final age = now.difference(reqTime);

      // Check hanging loading requests
      if (c.loading) {
        final hangingMs = age.inMilliseconds;
        if (hangingMs >= slowUrgentThreshold) {
          hasUrgent = true;
        } else if (hangingMs >= slowWarningThreshold) {
          hasWarning = true;
        }
      }

      // Since calls is sorted newest-first, if call is older than window and not loading,
      // stop scanning older calls
      if (age > frequencyWindow && !c.loading) {
        break;
      }

      // Check completed request duration in the recent window
      if (!c.loading) {
        if (c.duration >= slowUrgentThreshold) {
          hasUrgent = true;
        } else if (c.duration >= slowWarningThreshold) {
          hasWarning = true;
        }
      }

      // Count per endpoint (method + endpoint) in recent window
      final key = '${c.method}_${c.endpoint}';
      final count = (endpointCounts[key] ?? 0) + 1;
      endpointCounts[key] = count;

      if (count >= freqUrgentThreshold) {
        hasUrgent = true;
      } else if (count >= freqWarningThreshold) {
        hasWarning = true;
      }
    }

    if (hasUrgent) return AliceBubbleStatus.urgent;
    if (hasWarning) return AliceBubbleStatus.warning;
    return AliceBubbleStatus.normal;
  }

  static Color colorFor(AliceBubbleStatus status) {
    switch (status) {
      case AliceBubbleStatus.urgent:
        return AliceColors.error;
      case AliceBubbleStatus.warning:
        return AliceColors.warning;
      case AliceBubbleStatus.normal:
        return AliceColors.primary;
    }
  }
}
