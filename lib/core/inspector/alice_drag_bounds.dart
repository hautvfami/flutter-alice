import 'dart:math' as math;
import 'package:flutter/widgets.dart';

/// Helper class encapsulating screen boundaries and clamping/snapping logic.
class AliceDragBounds {
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;
  final double midX;

  const AliceDragBounds({
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
    required this.midX,
  });

  factory AliceDragBounds.fromMediaQuery(
    MediaQueryData mediaQuery,
    double fabSize,
  ) {
    final size = mediaQuery.size;
    final padding = mediaQuery.padding;

    final minX = padding.left + 8.0;
    final maxX = size.width - padding.right - fabSize - 8.0;
    final minY = padding.top + 8.0;
    final maxY = size.height - padding.bottom - fabSize - 8.0;
    final midX = (minX + maxX) / 2;

    return AliceDragBounds(
      minX: minX,
      maxX: maxX,
      minY: minY,
      maxY: maxY,
      midX: midX,
    );
  }

  Offset clamp(Offset current, Offset delta) {
    final newX =
        (current.dx + delta.dx).clamp(minX, math.max(minX, maxX)).toDouble();
    final newY =
        (current.dy + delta.dy).clamp(minY, math.max(minY, maxY)).toDouble();
    return Offset(newX, newY);
  }

  Offset snapTarget(Offset current) {
    final targetX = current.dx < midX ? minX : maxX;
    return Offset(targetX, current.dy);
  }
}
