import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_alice/helper/alice_extensions.dart';
import 'package:flutter_alice/model/alice_http_call.dart';
import 'package:flutter_alice/theme/theme.dart';
import 'package:flutter_alice/ui/widget/alice_base_mixin.dart';

class AliceCallOverviewWidget extends StatelessWidget with AliceBaseMixin {
  final AliceHttpCall call;

  const AliceCallOverviewWidget(this.call, {super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> rows = [];
    rows.add(getListRow("Method: ", call.method));
    rows.add(getListRow("Server: ", call.server));
    rows.add(getListRow("Endpoint: ", call.endpoint));
    rows.add(getListRow("Started:", call.request?.time.formattedTime ?? "-"));
    rows.add(getListRow("Finished:", call.response?.time.formattedTime ?? "-"));
    rows.add(getListRow("Duration:", call.duration.toFormattedDuration));
    rows.add(getListRow("Bytes sent:", (call.request?.size ?? 0).toFormattedBytes));
    rows.add(getListRow("Bytes received:", (call.response?.size ?? 0).toFormattedBytes));
    rows.add(getListRow("Client:", call.client));
    rows.add(getListRow("Secure:", call.secure.toString()));
    rows.add(_buildCurlRow(context));

    return Container(
      padding: const EdgeInsets.all(6),
      child: ListView(children: rows),
    );
  }

  Widget _buildCurlRow(BuildContext context) {
    final curl = call.getCurlCommand();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "cURL:",
                style: AliceStyles.bodyBold,
              ),
              GestureDetector(
                onTap: () => _copyCurl(context, curl),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                        style: AliceStyles.captionBold.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => _copyCurl(context, curl),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AliceColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AliceColors.divider),
              ),
              child: SelectableText(
                curl,
                style: AliceStyles.mono.s12
                    .copyWith(color: AliceColors.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyCurl(BuildContext context, String curl) {
    Clipboard.setData(ClipboardData(text: curl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('cURL copied to clipboard'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}



