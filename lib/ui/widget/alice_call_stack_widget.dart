import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_alice/model/alice_http_call.dart';
import 'package:flutter_alice/theme/theme.dart';
import 'package:flutter_alice/ui/widget/alice_base_mixin.dart';

class AliceCallStackWidget extends StatelessWidget with AliceBaseMixin {
  final AliceHttpCall call;

  const AliceCallStackWidget(this.call, {super.key});

  @override
  Widget build(BuildContext context) {
    final stackTrace = call.request?.stackTrace;
    final stackTraceStr = stackTrace?.toString().trim() ?? "";

    if (stackTraceStr.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 48, color: AliceColors.grey),
              SizedBox(height: 12),
              Text(
                "No call stack available for this request",
                style: AliceTextStyles.titleMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 6),
              Text(
                "Call stack is recorded when request is dispatched via supported client adapters.",
                style: AliceTextStyles.caption,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(8),
      child: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.layers_outlined, size: 18, color: AliceColors.primary),
                  SizedBox(width: 6),
                  Text(
                    "Request Call Stack:",
                    style: AliceTextStyles.titleMedium,
                  ),
                ],
              ),
              InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () => _copyStackTrace(context, stackTraceStr),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.copy_rounded,
                        size: 14,
                        color: AliceColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Copy",
                        style: AliceTextStyles.captionBold.copyWith(
                          color: AliceColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AliceColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AliceColors.divider),
            ),
            child: SelectableText(
              stackTraceStr,
              style: AliceTextStyles.mono.copyWith(
                fontSize: 12,
                color: AliceColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyStackTrace(BuildContext context, String stackTrace) {
    Clipboard.setData(ClipboardData(text: stackTrace));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Call stack copied to clipboard'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
