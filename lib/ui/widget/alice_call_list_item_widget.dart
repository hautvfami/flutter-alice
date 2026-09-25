import 'package:flutter/material.dart';
import 'package:flutter_alice/helper/alice_extensions.dart';
import 'package:flutter_alice/model/alice_http_call.dart';
import 'package:flutter_alice/theme/theme.dart';

class AliceCallListItemWidget extends StatelessWidget {
  final AliceHttpCall call;
  final void Function(AliceHttpCall) itemClickAction;

  const AliceCallListItemWidget(this.call, this.itemClickAction, {super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => itemClickAction(call),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMethodAndEndpointRow(context),
                  const SizedBox(height: 4),
                  _buildServerRow(),
                  const SizedBox(height: 4),
                  _buildStatsRow()
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildResponseColumn(context)
          ],
        ),
      ),
    );
  }

  Widget _buildMethodAndEndpointRow(BuildContext context) {
    final Color textColor = call.getEndpointTextColor(context);
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          call.method,
          style: AliceTextStyles.titleMedium.copyWith(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            call.endpoint,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
            style: AliceTextStyles.titleMedium.copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
          ),
        )
      ],
    );
  }

  Widget _buildServerRow() {
    return Row(children: [
      _getSecuredConnectionIcon(call.secure),
      Expanded(
        child: Text(
          call.server,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: AliceTextStyles.body,
        ),
      ),
    ]);
  }

  Widget _buildStatsRow() {
    final requestTime =
        call.request != null ? call.request!.time.formattedTime : "-";
    final requestSize =
        call.request != null ? call.request!.size.toFormattedBytes : "-";
    final responseSize =
        call.response != null ? call.response!.size.toFormattedBytes : "-";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 1,
          child: Text(requestTime, style: AliceTextStyles.caption),
        ),
        Flexible(
          flex: 1,
          child: Text(
            call.duration.toFormattedDuration,
            style: AliceTextStyles.caption,
          ),
        ),
        Flexible(
          flex: 1,
          child: Text(
            "$requestSize / $responseSize",
            style: AliceTextStyles.caption,
          ),
        )
      ],
    );
  }

  Widget _buildResponseColumn(BuildContext context) {
    return AliceStatusBadge(
      text: call.statusText,
      color: call.getStatusColor(context),
      loading: call.loading,
    );
  }

  Widget _getSecuredConnectionIcon(bool secure) {
    final IconData iconData;
    final Color iconColor;
    if (secure) {
      iconData = Icons.lock_outline;
      iconColor = AliceColors.success;
    } else {
      iconData = Icons.lock_open;
      iconColor = AliceColors.error;
    }
    return Padding(
      padding: const EdgeInsets.only(right: 3),
      child: Icon(iconData, color: iconColor, size: 12),
    );
  }
}

