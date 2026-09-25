import 'package:flutter/material.dart';
import 'package:flutter_alice/helper/alice_extensions.dart';
import 'package:flutter_alice/theme/theme.dart';
import 'package:flutter_alice/ui/page/statistics/model/alice_stats_data.dart';

/// Card grid displaying core KPIs (Total, Latency, Data, and Methods).
class StatsSummaryCard extends StatelessWidget {
  final AliceStatsData stats;

  const StatsSummaryCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRequestsOverviewCard(context),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildLatencyCard(context)),
              const SizedBox(width: 12),
              Expanded(child: _buildDataTransferCard(context)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildMethodsAndSecurityCard(context),
      ],
    );
  }

  Widget _buildRequestsOverviewCard(BuildContext context) {
    final errorColor = stats.hasHighErrorRate
        ? AliceColors.error
        : (stats.errorRequests > 0 ? AliceColors.warning : AliceColors.success);

    return Container(
      decoration: BoxDecoration(
        color: AliceColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AliceColors.divider),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Total Requests", style: AliceTextStyles.caption),
                  const SizedBox(height: 4),
                  Text(
                    "${stats.totalRequests}",
                    style: AliceTextStyles.titleLarge.copyWith(fontSize: 28),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: errorColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: errorColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      stats.errorRequests > 0
                          ? Icons.error_outline
                          : Icons.check_circle_outline,
                      size: 16,
                      color: errorColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "${stats.errorRate.toStringAsFixed(1)}% Error",
                      style: AliceTextStyles.captionBold.copyWith(
                        color: errorColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat(
                "Success",
                "${stats.successRequests}",
                AliceColors.success,
              ),
              _buildMiniStat(
                "Pending",
                "${stats.pendingRequests}",
                AliceColors.warning,
              ),
              _buildMiniStat(
                "Redirect",
                "${stats.redirectionRequests}",
                AliceColors.info,
              ),
              _buildMiniStat(
                "Error",
                "${stats.errorRequests}",
                AliceColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLatencyCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AliceColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AliceColors.divider),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.timer_outlined, size: 16, color: AliceColors.grey),
              SizedBox(width: 6),
              Text("Latency", style: AliceTextStyles.caption),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            stats.avgDuration.toFormattedDuration,
            style: AliceTextStyles.titleMedium.copyWith(fontSize: 20),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                "Min: ",
                style: AliceTextStyles.caption.copyWith(
                  fontSize: 11,
                  color: AliceColors.grey,
                ),
              ),
              Expanded(
                child: Text(
                  stats.minDuration.toFormattedDuration,
                  style: AliceTextStyles.captionBold.copyWith(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Text(
                "Max: ",
                style: AliceTextStyles.caption.copyWith(
                  fontSize: 11,
                  color: AliceColors.grey,
                ),
              ),
              Expanded(
                child: Text(
                  stats.maxDuration.toFormattedDuration,
                  style: AliceTextStyles.captionBold.copyWith(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataTransferCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AliceColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AliceColors.divider),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.swap_vert, size: 16, color: AliceColors.grey),
              SizedBox(width: 6),
              Text("Data Transfer", style: AliceTextStyles.caption),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            (stats.bytesSent + stats.bytesReceived).toFormattedBytes,
            style: AliceTextStyles.titleMedium.copyWith(fontSize: 20),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                "▲ ",
                style: AliceTextStyles.caption.copyWith(
                  fontSize: 11,
                  color: AliceColors.info,
                ),
              ),
              Expanded(
                child: Text(
                  stats.bytesSent.toFormattedBytes,
                  style: AliceTextStyles.caption.copyWith(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Text(
                "▼ ",
                style: AliceTextStyles.caption.copyWith(
                  fontSize: 11,
                  color: AliceColors.success,
                ),
              ),
              Expanded(
                child: Text(
                  stats.bytesReceived.toFormattedBytes,
                  style: AliceTextStyles.caption.copyWith(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMethodsAndSecurityCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AliceColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AliceColors.divider),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              const Text("HTTP Methods & Protocol",
                  style: AliceTextStyles.caption),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    stats.hasUnsecuredRequests
                        ? Icons.lock_open
                        : Icons.lock_outline,
                    size: 14,
                    color: stats.hasUnsecuredRequests
                        ? AliceColors.error
                        : AliceColors.success,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    stats.hasUnsecuredRequests
                        ? "${stats.unsecuredCount} HTTP Unsecured"
                        : "${stats.securedCount} HTTPS",
                    style: AliceTextStyles.caption.copyWith(
                      color: stats.hasUnsecuredRequests
                          ? AliceColors.error
                          : AliceColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMethodPill("GET", stats.getCount, Colors.blue),
              _buildMethodPill("POST", stats.postCount, Colors.green),
              _buildMethodPill("PUT", stats.putCount, Colors.orange),
              _buildMethodPill("DELETE", stats.deleteCount, Colors.red),
              if (stats.patchCount > 0)
                _buildMethodPill("PATCH", stats.patchCount, Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AliceTextStyles.bodyBold.copyWith(color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AliceTextStyles.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMethodPill(String method, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        "$method: $count",
        style: AliceTextStyles.captionBold.copyWith(color: color),
      ),
    );
  }
}
