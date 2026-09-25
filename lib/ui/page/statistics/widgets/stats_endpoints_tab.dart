import 'package:flutter/material.dart';
import 'package:flutter_alice/core/alice_core.dart';
import 'package:flutter_alice/helper/alice_extensions.dart';
import 'package:flutter_alice/theme/theme.dart';
import 'package:flutter_alice/ui/page/alice_call_details_screen.dart';
import 'package:flutter_alice/ui/page/statistics/model/alice_stats_data.dart';

enum EndpointSortMode {
  mostFrequent,
  slowest,
  mostErrors,
}

/// Flat, high-density list of unique endpoints with threshold-based severity alerts.
class StatsEndpointsTab extends StatefulWidget {
  final List<AliceEndpointStats> endpointStats;
  final AliceCore aliceCore;

  const StatsEndpointsTab({
    super.key,
    required this.endpointStats,
    required this.aliceCore,
  });

  @override
  State<StatsEndpointsTab> createState() => _StatsEndpointsTabState();
}

class _StatsEndpointsTabState extends State<StatsEndpointsTab> {
  EndpointSortMode _sortMode = EndpointSortMode.mostFrequent;

  List<AliceEndpointStats> get _sortedEndpoints {
    final list = List<AliceEndpointStats>.from(widget.endpointStats);
    switch (_sortMode) {
      case EndpointSortMode.mostFrequent:
        list.sort((a, b) => b.count.compareTo(a.count));
      case EndpointSortMode.slowest:
        list.sort((a, b) => b.avgDuration.compareTo(a.avgDuration));
      case EndpointSortMode.mostErrors:
        list.sort((a, b) {
          final cmp = b.errorCount.compareTo(a.errorCount);
          return cmp != 0 ? cmp : b.count.compareTo(a.count);
        });
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.endpointStats.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.api_outlined, size: 48, color: AliceColors.grey),
            SizedBox(height: 12),
            Text("No endpoints recorded yet", style: AliceTextStyles.bodyBold),
          ],
        ),
      );
    }

    final endpoints = _sortedEndpoints;

    return Column(
      children: [
        _buildSortBar(),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            itemCount: endpoints.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final ep = endpoints[index];
              return _buildFlatEndpointRow(ep);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSortBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "${widget.endpointStats.length} Unique Endpoints",
            style: AliceTextStyles.captionBold,
          ),
          Row(
            children: [
              const Text("Sort: ", style: AliceTextStyles.caption),
              const SizedBox(width: 4),
              _buildSortChip("Frequent", EndpointSortMode.mostFrequent),
              const SizedBox(width: 6),
              _buildSortChip("Slowest", EndpointSortMode.slowest),
              const SizedBox(width: 6),
              _buildSortChip("Errors", EndpointSortMode.mostErrors),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, EndpointSortMode mode) {
    final isSelected = _sortMode == mode;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        setState(() {
          _sortMode = mode;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected
              ? AliceColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AliceColors.primary : AliceColors.divider,
          ),
        ),
        child: Text(
          label,
          style: AliceTextStyles.caption.copyWith(
            color:
                isSelected ? AliceColors.primaryDark : AliceColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildFlatEndpointRow(AliceEndpointStats ep) {
    final severity = switch (_sortMode) {
      EndpointSortMode.mostFrequent => ep.frequencySeverity,
      EndpointSortMode.slowest => ep.latencySeverity,
      EndpointSortMode.mostErrors => ep.errorSeverity,
    };

    final hasErrors = ep.errorCount > 0;
    final avgColor = _getDurationColor(ep.avgDuration);

    return Ink(
      decoration: BoxDecoration(
        color: severity.backgroundColor,
        border: severity != AliceSeverity.none
            ? Border(
                left: BorderSide(
                  color: severity.color,
                  width: 4,
                ),
              )
            : null,
      ),
      child: InkWell(
        onTap: () {
          if (ep.calls.isNotEmpty) {
            widget.aliceCore.push(
              (_) => AliceCallDetailsScreen(ep.calls.last, widget.aliceCore),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Row 1: Method, Call count / Frequency warning, Errors, Severity Tag, Avg Duration
              Row(
                children: [
                  Text(
                    ep.method.toUpperCase(),
                    style: AliceTextStyles.captionBold.copyWith(
                      color: _getMethodColor(ep.method),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildCallCountText(ep),
                  if (hasErrors) ...[
                    const SizedBox(width: 8),
                    Text(
                      "•  ${ep.errorCount} err",
                      style: AliceTextStyles.captionBold.copyWith(
                        color: AliceColors.error,
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (severity != AliceSeverity.none) ...[
                    _buildSeverityTag(severity),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    ep.avgDuration.toFormattedDuration,
                    style: AliceTextStyles.monoBold.copyWith(
                      color: severity != AliceSeverity.none &&
                              _sortMode == EndpointSortMode.slowest
                          ? severity.color
                          : avgColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),

              // Row 2: Endpoint path
              Text(
                ep.endpoint.isEmpty ? "/" : ep.endpoint,
                style: AliceTextStyles.bodyBold.copyWith(fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),

              // Row 3: Server domain, Min/Max latency range, Total payload
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "${ep.server}  •  Min: ${ep.minDuration.toFormattedDuration} / Max: ${ep.maxDuration.toFormattedDuration}",
                      style: AliceTextStyles.caption.copyWith(fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    ep.totalBytes.toFormattedBytes,
                    style: AliceTextStyles.caption.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCallCountText(AliceEndpointStats ep) {
    if (_sortMode == EndpointSortMode.mostFrequent) {
      final severity = ep.frequencySeverity;
      final text = switch (severity) {
        AliceSeverity.urgent => "🚨 ${ep.count} calls",
        AliceSeverity.high => "⚠️ ${ep.count} calls",
        AliceSeverity.warning => "⚠️ ${ep.count} calls",
        AliceSeverity.none => "${ep.count} call${ep.count > 1 ? 's' : ''}",
      };
      final color = switch (severity) {
        AliceSeverity.urgent => AliceColors.error,
        AliceSeverity.high => const Color(0xffe55039),
        AliceSeverity.warning => AliceColors.warning,
        AliceSeverity.none => AliceColors.grey,
      };
      return Text(
        text,
        style: AliceTextStyles.captionBold.copyWith(color: color),
      );
    } else {
      return Text(
        "${ep.count} call${ep.count > 1 ? 's' : ''}",
        style: AliceTextStyles.captionBold.copyWith(
          color: ep.isDuplicateWarning ? AliceColors.warning : AliceColors.grey,
        ),
      );
    }
  }

  Widget _buildSeverityTag(AliceSeverity severity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: severity.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        severity.label,
        style: AliceTextStyles.captionBold.copyWith(
          color: severity.color,
          fontSize: 9,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _getDurationColor(int duration) {
    if (duration >= 2000) return AliceColors.error;
    if (duration >= 800) return AliceColors.warning;
    return AliceColors.success;
  }

  Color _getMethodColor(String method) {
    return switch (method.toUpperCase()) {
      "GET" => Colors.blue,
      "POST" => Colors.green,
      "PUT" => Colors.orange,
      "DELETE" => Colors.red,
      "PATCH" => Colors.purple,
      _ => AliceColors.grey,
    };
  }
}
