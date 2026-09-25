import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_alice/model/alice_http_call.dart';
import 'package:flutter_alice/theme/alice_colors.dart';

/// Severity level for latency (slowest) and frequency (frequent endpoints).
enum AliceSeverity {
  none,
  warning,
  high,
  urgent;

  bool get isNone => this == AliceSeverity.none;
  bool get isWarning => this == AliceSeverity.warning;
  bool get isHigh => this == AliceSeverity.high;
  bool get isUrgent => this == AliceSeverity.urgent;
  bool get hasAlert => this != AliceSeverity.none;

  Color get color => switch (this) {
        AliceSeverity.urgent => AliceColors.error,
        AliceSeverity.high => const Color(0xffe55039),
        AliceSeverity.warning => AliceColors.warning,
        AliceSeverity.none => Colors.transparent,
      };

  Color get backgroundColor => switch (this) {
        AliceSeverity.urgent => AliceColors.error.withValues(alpha: 0.12),
        AliceSeverity.high => const Color(0xffff793f).withValues(alpha: 0.10),
        AliceSeverity.warning => AliceColors.warning.withValues(alpha: 0.08),
        AliceSeverity.none => Colors.transparent,
      };

  String get label => switch (this) {
        AliceSeverity.urgent => "URGENT",
        AliceSeverity.high => "HIGH",
        AliceSeverity.warning => "WARNING",
        AliceSeverity.none => "",
      };
}

/// Thresholds for warning, high, and urgent levels for slowest latency and frequent calls.
class AliceStatsThresholds {
  AliceStatsThresholds._();

  // Slowest / Latency thresholds (in milliseconds)
  static const int latencyWarningMs = 800;
  static const int latencyHighMs = 2000;
  static const int latencyUrgentMs = 4000;

  // Frequent call count thresholds
  static const int frequentWarningCount = 3;
  static const int frequentHighCount = 8;
  static const int frequentUrgentCount = 15;

  // Error count thresholds
  static const int errorWarningCount = 1;
  static const int errorHighCount = 5;
  static const int errorUrgentCount = 10;

  /// Evaluates severity based on call duration in milliseconds.
  static AliceSeverity getLatencySeverity(int durationMs) {
    if (durationMs >= latencyUrgentMs) return AliceSeverity.urgent;
    if (durationMs >= latencyHighMs) return AliceSeverity.high;
    if (durationMs >= latencyWarningMs) return AliceSeverity.warning;
    return AliceSeverity.none;
  }

  /// Evaluates severity based on endpoint call frequency.
  static AliceSeverity getFrequencySeverity(int count) {
    if (count >= frequentUrgentCount) return AliceSeverity.urgent;
    if (count >= frequentHighCount) return AliceSeverity.high;
    if (count >= frequentWarningCount) return AliceSeverity.warning;
    return AliceSeverity.none;
  }

  /// Evaluates severity based on endpoint error count.
  static AliceSeverity getErrorSeverity(int errorCount) {
    if (errorCount >= errorUrgentCount) return AliceSeverity.urgent;
    if (errorCount >= errorHighCount) return AliceSeverity.high;
    if (errorCount >= errorWarningCount) return AliceSeverity.warning;
    return AliceSeverity.none;
  }
}

/// Aggregated statistics for an individual endpoint (Method + Endpoint).
class AliceEndpointStats {
  final String method;
  final String endpoint;
  final String server;
  final int count;
  final int errorCount;
  final int totalDuration;
  final int minDuration;
  final int maxDuration;
  final int totalBytes;
  final List<AliceHttpCall> calls;

  const AliceEndpointStats({
    required this.method,
    required this.endpoint,
    required this.server,
    required this.count,
    required this.errorCount,
    required this.totalDuration,
    required this.minDuration,
    required this.maxDuration,
    required this.totalBytes,
    required this.calls,
  });

  /// Average duration for calls to this endpoint in milliseconds.
  int get avgDuration => count > 0 ? totalDuration ~/ count : 0;

  /// Flags potential duplicate or redundant calls if called 3 or more times.
  bool get isDuplicateWarning => count >= AliceStatsThresholds.frequentWarningCount;

  /// Severity based on call frequency
  AliceSeverity get frequencySeverity =>
      AliceStatsThresholds.getFrequencySeverity(count);

  /// Severity based on average latency
  AliceSeverity get latencySeverity =>
      AliceStatsThresholds.getLatencySeverity(avgDuration);

  /// Severity based on error count
  AliceSeverity get errorSeverity =>
      AliceStatsThresholds.getErrorSeverity(errorCount);

  /// Overall combined severity
  AliceSeverity get overallSeverity {
    if (frequencySeverity == AliceSeverity.urgent ||
        latencySeverity == AliceSeverity.urgent ||
        errorSeverity == AliceSeverity.urgent) {
      return AliceSeverity.urgent;
    }
    if (frequencySeverity == AliceSeverity.high ||
        latencySeverity == AliceSeverity.high ||
        errorSeverity == AliceSeverity.high) {
      return AliceSeverity.high;
    }
    if (frequencySeverity == AliceSeverity.warning ||
        latencySeverity == AliceSeverity.warning ||
        errorSeverity == AliceSeverity.warning) {
      return AliceSeverity.warning;
    }
    return AliceSeverity.none;
  }
}

/// Comprehensive, pre-computed statistics for all captured HTTP calls.
class AliceStatsData {
  final int totalRequests;
  final int pendingRequests;
  final int successRequests;
  final int redirectionRequests;
  final int errorRequests;
  final int bytesSent;
  final int bytesReceived;
  final int avgDuration;
  final int minDuration;
  final int maxDuration;
  final int getCount;
  final int postCount;
  final int putCount;
  final int deleteCount;
  final int patchCount;
  final int securedCount;
  final int unsecuredCount;
  final int heavyPayloadCount;
  final Map<int, int> statusCodes;
  final List<AliceHttpCall> slowestCalls;
  final List<AliceEndpointStats> endpointStats;

  const AliceStatsData({
    required this.totalRequests,
    required this.pendingRequests,
    required this.successRequests,
    required this.redirectionRequests,
    required this.errorRequests,
    required this.bytesSent,
    required this.bytesReceived,
    required this.avgDuration,
    required this.minDuration,
    required this.maxDuration,
    required this.getCount,
    required this.postCount,
    required this.putCount,
    required this.deleteCount,
    required this.patchCount,
    required this.securedCount,
    required this.unsecuredCount,
    required this.heavyPayloadCount,
    required this.statusCodes,
    required this.slowestCalls,
    required this.endpointStats,
  });

  /// Error percentage (e.g. 5.5%).
  double get errorRate =>
      totalRequests > 0 ? (errorRequests / totalRequests) * 100 : 0.0;

  /// Success percentage (e.g. 94.5%).
  double get successRate =>
      totalRequests > 0 ? (successRequests / totalRequests) * 100 : 0.0;

  /// High error rate warning threshold (> 10%).
  bool get hasHighErrorRate => errorRate > 10.0;

  /// Unsecured HTTP request warning (plaintext HTTP without SSL).
  bool get hasUnsecuredRequests => unsecuredCount > 0;

  /// Slow latency warning (request taking 2+ seconds).
  bool get hasSlowRequests => maxDuration >= 2000;

  /// Heavy payload warning (response > 1MB).
  bool get hasHeavyPayloads => heavyPayloadCount > 0;

  /// Computes all stats in a single, high-performance pass.
  static AliceStatsData compute(List<AliceHttpCall> callList) {
    int pending = 0;
    int success = 0;
    int redirection = 0;
    int error = 0;
    int bytesSent = 0;
    int bytesReceived = 0;
    int requestTimeSum = 0;
    int completedCount = 0;
    int maxRequestTime = 0;
    int minRequestTime = callList.isEmpty ? 0 : 10000000;
    int getCount = 0;
    int postCount = 0;
    int deleteCount = 0;
    int putCount = 0;
    int patchCount = 0;
    int securedCount = 0;
    int unsecuredCount = 0;
    int heavyPayloadCount = 0;

    final statusCodes = <int, int>{};
    final slowestCalls = <AliceHttpCall>[];
    final endpointMap = <String, List<AliceHttpCall>>{};

    for (final call in callList) {
      if (call.loading) {
        pending++;
      }

      final response = call.response;
      if (response != null) {
        final status = response.status;
        if (status >= 200 && status < 300) {
          success++;
        } else if (status >= 300 && status < 400) {
          redirection++;
        } else if (status >= 400 && status < 600) {
          error++;
        }

        if (status > 0) {
          statusCodes[status] = (statusCodes[status] ?? 0) + 1;
        }

        bytesReceived += response.size;
        if (response.size > 1024 * 1024) {
          heavyPayloadCount++;
        }
      }

      final request = call.request;
      if (request != null) {
        bytesSent += request.size;
      }

      if (!call.loading) {
        completedCount++;
        requestTimeSum += call.duration;
        maxRequestTime = math.max(maxRequestTime, call.duration);
        minRequestTime = math.min(minRequestTime, call.duration);
        slowestCalls.add(call);
      }

      final method = call.method.toUpperCase();
      switch (method) {
        case "GET":
          getCount++;
        case "POST":
          postCount++;
        case "DELETE":
          deleteCount++;
        case "PUT":
          putCount++;
        case "PATCH":
          patchCount++;
      }

      if (call.secure) {
        securedCount++;
      } else {
        unsecuredCount++;
      }

      // Group by method and endpoint
      final key = "$method ${call.endpoint}";
      (endpointMap[key] ??= []).add(call);
    }

    // Sort slowest calls descending
    slowestCalls.sort((a, b) => b.duration.compareTo(a.duration));

    // Build endpoint stats list
    final endpointStats = <AliceEndpointStats>[];
    for (final entry in endpointMap.entries) {
      final calls = entry.value;
      final first = calls.first;
      int epDurationSum = 0;
      int epErrorCount = 0;
      int epMinDuration = calls.first.duration;
      int epMaxDuration = 0;
      int epTotalBytes = 0;

      for (final c in calls) {
        epDurationSum += c.duration;
        epMaxDuration = math.max(epMaxDuration, c.duration);
        epMinDuration = math.min(epMinDuration, c.duration);
        if (c.error != null || ((c.response?.status ?? 0) >= 400)) {
          epErrorCount++;
        }
        if (c.response != null) {
          epTotalBytes += c.response!.size;
        }
      }

      endpointStats.add(
        AliceEndpointStats(
          method: first.method,
          endpoint: first.endpoint,
          server: first.server,
          count: calls.length,
          errorCount: epErrorCount,
          totalDuration: epDurationSum,
          minDuration: epMinDuration,
          maxDuration: epMaxDuration,
          totalBytes: epTotalBytes,
          calls: calls,
        ),
      );
    }

    // Sort endpoints by call count descending by default
    endpointStats.sort((a, b) => b.count.compareTo(a.count));

    return AliceStatsData(
      totalRequests: callList.length,
      pendingRequests: pending,
      successRequests: success,
      redirectionRequests: redirection,
      errorRequests: error,
      bytesSent: bytesSent,
      bytesReceived: bytesReceived,
      avgDuration: completedCount > 0 ? requestTimeSum ~/ completedCount : 0,
      minDuration: callList.isEmpty || completedCount == 0 ? 0 : minRequestTime,
      maxDuration: maxRequestTime,
      getCount: getCount,
      postCount: postCount,
      putCount: putCount,
      deleteCount: deleteCount,
      patchCount: patchCount,
      securedCount: securedCount,
      unsecuredCount: unsecuredCount,
      heavyPayloadCount: heavyPayloadCount,
      statusCodes: statusCodes,
      slowestCalls: slowestCalls,
      endpointStats: endpointStats,
    );
  }
}
