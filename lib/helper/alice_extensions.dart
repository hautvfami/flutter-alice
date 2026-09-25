import 'package:flutter/material.dart';
import 'package:flutter_alice/helper/alice_convert_helper.dart';
import 'package:flutter_alice/model/alice_http_call.dart';
import 'package:flutter_alice/theme/alice_colors.dart';

/// Extension methods for [DateTime] formatting.
extension AliceDateTimeExtension on DateTime {
  /// Formats time to `HH:mm:ss.SSS` format.
  String get formattedTime {
    String pad(int n, [int width = 2]) => n.toString().padLeft(width, '0');
    return '${pad(hour)}:${pad(minute)}:${pad(second)}.${pad(millisecond, 3)}';
  }
}

/// Extension methods for [int] to format bytes and durations.
extension AliceNumExtension on int {
  /// Formats bytes into a human-readable string (e.g. `12 kB`, `1.50 MB`).
  String get toFormattedBytes => AliceConvertHelper.formatBytes(this);

  /// Formats milliseconds duration into a human-readable string (e.g. `120 ms`, `1.50 s`).
  String get toFormattedDuration => AliceConvertHelper.formatTime(this);
}

/// Extension methods for [Iterable] to find elements safely.
extension AliceIterableExtension<T> on Iterable<T> {
  /// Returns the first element satisfying [test], or `null` if none found.
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

/// UI helper extensions on [AliceHttpCall].
extension AliceHttpCallUiExtension on AliceHttpCall {
  /// Returns a concise status code string (e.g. `200`, `ERR`, `???`).
  String get statusText {
    final res = response;
    if (res == null || res.status == 0) return "???";
    if (res.status == -1) return "ERR";
    return "${res.status}";
  }

  /// Returns text color based on the HTTP response status code.
  Color getStatusColor(BuildContext context) {
    final status = response?.status ?? 0;
    return switch (status) {
      -1 => AliceColors.red,
      < 200 => Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
      < 300 => AliceColors.green,
      < 400 => AliceColors.orange,
      < 600 => AliceColors.red,
      _ => Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
    };
  }

  /// Returns text color for the endpoint text depending on loading status.
  Color getEndpointTextColor(BuildContext context) {
    if (loading) {
      return AliceColors.grey;
    }
    return getStatusColor(context);
  }
}
