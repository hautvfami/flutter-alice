import 'package:flutter/material.dart';
import 'package:flutter_alice/theme/theme.dart';
import 'package:flutter_alice/ui/page/statistics/model/alice_stats_data.dart';

/// Visual status code distribution bar, code breakdown list, and early warning alerts.
class StatsStatusBreakdown extends StatelessWidget {
  final AliceStatsData stats;

  const StatsStatusBreakdown({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEarlyWarningAlerts(context),
        Container(
          decoration: BoxDecoration(
            color: AliceColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AliceColors.divider),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("HTTP Status Distribution",
                  style: AliceStyles.caption),
              const SizedBox(height: 12),
              _buildSegmentedProgressBar(),
              const SizedBox(height: 16),
              _buildStatusCodesList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEarlyWarningAlerts(BuildContext context) {
    final alerts = <Widget>[];

    if (stats.hasHighErrorRate) {
      alerts.add(
        _buildAlertBanner(
          icon: Icons.warning_amber_rounded,
          color: AliceColors.error,
          title: "High Error Rate Detected",
          description:
              "${stats.errorRate.toStringAsFixed(1)}% of all network calls failed. Check server status or parameters.",
        ),
      );
    }

    if (stats.hasUnsecuredRequests) {
      alerts.add(
        _buildAlertBanner(
          icon: Icons.no_encryption_outlined,
          color: AliceColors.warning,
          title: "Unsecured HTTP Traffic",
          description:
              "${stats.unsecuredCount} request(s) sent over plaintext HTTP. Consider enforcing HTTPS.",
        ),
      );
    }

    if (stats.hasSlowRequests) {
      alerts.add(
        _buildAlertBanner(
          icon: Icons.speed,
          color: AliceColors.warning,
          title: "Slow Latency Spike",
          description:
              "Slowest response took ${stats.maxDuration} ms. Check the Slowest tab to investigate.",
        ),
      );
    }

    if (stats.hasHeavyPayloads) {
      alerts.add(
        _buildAlertBanner(
          icon: Icons.data_usage,
          color: AliceColors.info,
          title: "Heavy Payload Detected",
          description:
              "${stats.heavyPayloadCount} response(s) exceeded 1MB. Optimize payload sizes for mobile performance.",
        ),
      );
    }

    if (alerts.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(children: alerts),
    );
  }

  Widget _buildAlertBanner({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AliceStyles.bodyBold.copyWith(
                    color: color,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AliceStyles.caption.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedProgressBar() {
    final total = stats.totalRequests;
    if (total == 0) {
      return Container(
        height: 10,
        decoration: BoxDecoration(
          color: AliceColors.divider,
          borderRadius: BorderRadius.circular(5),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: SizedBox(
        height: 10,
        child: Row(
          children: [
            if (stats.successRequests > 0)
              Expanded(
                flex: stats.successRequests,
                child: Container(color: AliceColors.success),
              ),
            if (stats.redirectionRequests > 0)
              Expanded(
                flex: stats.redirectionRequests,
                child: Container(color: AliceColors.info),
              ),
            if (stats.errorRequests > 0)
              Expanded(
                flex: stats.errorRequests,
                child: Container(color: AliceColors.error),
              ),
            if (stats.pendingRequests > 0)
              Expanded(
                flex: stats.pendingRequests,
                child: Container(color: AliceColors.warning),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCodesList() {
    if (stats.statusCodes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text("No status codes recorded", style: AliceStyles.caption),
      );
    }

    final sortedCodes = stats.statusCodes.keys.toList()..sort();

    return Column(
      children: sortedCodes.map((code) {
        final count = stats.statusCodes[code] ?? 0;
        final percentage =
            stats.totalRequests > 0 ? (count / stats.totalRequests) * 100 : 0.0;
        final color = _getStatusColor(code);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "$code",
                  style: AliceStyles.captionBold.copyWith(color: color),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getStatusName(code),
                  style: AliceStyles.body.copyWith(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                "$count (${percentage.toStringAsFixed(1)}%)",
                style: AliceStyles.captionBold,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getStatusColor(int code) {
    if (code >= 200 && code < 300) return AliceColors.success;
    if (code >= 300 && code < 400) return AliceColors.info;
    if (code >= 400 && code < 500) return AliceColors.warning;
    if (code >= 500) return AliceColors.error;
    return AliceColors.grey;
  }

  String _getStatusName(int code) {
    return switch (code) {
      200 => "OK",
      201 => "Created",
      204 => "No Content",
      301 => "Moved Permanently",
      302 => "Found",
      304 => "Not Modified",
      400 => "Bad Request",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      405 => "Method Not Allowed",
      408 => "Request Timeout",
      422 => "Unprocessable Entity",
      429 => "Too Many Requests",
      500 => "Internal Server Error",
      502 => "Bad Gateway",
      503 => "Service Unavailable",
      504 => "Gateway Timeout",
      _ => "HTTP $code",
    };
  }
}
