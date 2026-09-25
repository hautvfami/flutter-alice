import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_alice/model/alice_http_call.dart';
import 'package:flutter_alice/theme/theme.dart';
import 'alice_bubble_evaluator.dart';
import 'alice_bubble_status.dart';
import 'alice_draggable_overlay.dart';

/// Dedicated widget for the circular bubble button with auto-revert timer.
class AliceInspectorBubble extends StatefulWidget {
  // final AliceCore aliceCore;
  final AliceBubbleEvaluator evaluator;
  final Stream<List<AliceHttpCall>> callsStream;
  final double fabSize;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const AliceInspectorBubble({
    super.key,
    // required this.aliceCore,
    required this.evaluator,
    required this.callsStream,
    this.fabSize = AliceDraggableOverlay.fabSize,
    required this.onTap,
    this.onLongPress,
  });

  @override
  State<AliceInspectorBubble> createState() => _AliceInspectorBubbleState();
}

class _AliceInspectorBubbleState extends State<AliceInspectorBubble> {
  Timer? _revertTimer;
  final kDu = const Duration(milliseconds: 100);

  @override
  void dispose() {
    _revertTimer?.cancel();
    super.dispose();
  }

  void _scheduleRevertTimer() {
    _revertTimer?.cancel();
    _revertTimer = Timer(widget.evaluator.frequencyWindow + kDu, () {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = widget.fabSize * 0.32;
    final smallFontSize = widget.fabSize * 0.27;

    Widget button = SizedBox(
      width: widget.fabSize,
      height: widget.fabSize,
      child: Opacity(
        opacity: 0.6,
        child: StreamBuilder<List<AliceHttpCall>>(
          initialData: const [],
          stream: widget.callsStream,
          builder: (_, snapshot) {
            final calls = snapshot.data ?? [];
            final count = calls.length;
            final countText = count > 99 ? '99+' : '$count';
            final status = widget.evaluator.evaluate(calls);
            final bubbleColor = AliceBubbleEvaluator.colorFor(status);

            if (status != AliceBubbleStatus.normal) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _scheduleRevertTimer();
                }
              });
            }

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: bubbleColor,
                shape: BoxShape.circle,
              ),
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  splashColor: Colors.white.withValues(alpha: 0.35),
                  highlightColor: Colors.white.withValues(alpha: 0.15),
                  onTap: widget.onTap,
                  onLongPress: widget.onLongPress,
                  child: Center(
                    child: Text(
                      countText,
                      style: AliceStyles.monoBold.copyWith(
                        color: Colors.white,
                        fontSize: count > 99 ? smallFontSize : fontSize,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
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
