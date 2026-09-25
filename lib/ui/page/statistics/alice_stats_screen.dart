import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_alice/core/alice_core.dart';
import 'package:flutter_alice/model/alice_http_call.dart';
import 'package:flutter_alice/theme/theme.dart';
import 'package:flutter_alice/ui/page/statistics/model/alice_stats_data.dart';
import 'package:flutter_alice/ui/page/statistics/widgets/stats_endpoints_tab.dart';
import 'package:flutter_alice/ui/page/statistics/widgets/stats_status_breakdown.dart';
import 'package:flutter_alice/ui/page/statistics/widgets/stats_summary_card.dart';

class AliceStatsScreen extends StatefulWidget {
  final AliceCore aliceCore;

  const AliceStatsScreen(this.aliceCore, {super.key});

  @override
  State<AliceStatsScreen> createState() => _AliceStatsScreenState();
}

class _AliceStatsScreenState extends State<AliceStatsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late AliceStatsData _statsData;
  StreamSubscription<List<AliceHttpCall>>? _callsSubscription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _statsData = AliceStatsData.compute(widget.aliceCore.callsSubject.value);

    // Listen to live calls updates without performing calculations in build()
    _callsSubscription = widget.aliceCore.callsSubject.listen((calls) {
      if (mounted) {
        setState(() {
          _statsData = AliceStatsData.compute(calls);
        });
      }
    });
  }

  @override
  void dispose() {
    _callsSubscription?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: aliceTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Statistics"),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              const Tab(text: "Dashboard"),
              Tab(
                text: _statsData.endpointStats.isNotEmpty
                    ? "Endpoints (${_statsData.endpointStats.length})"
                    : "Endpoints",
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildDashboardTab(),
            StatsEndpointsTab(
              endpointStats: _statsData.endpointStats,
              aliceCore: widget.aliceCore,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTab() {
    if (_statsData.totalRequests == 0) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 48, color: AliceColors.grey),
            SizedBox(height: 12),
            Text("No network calls recorded", style: AliceStyles.bodyBold),
            SizedBox(height: 4),
            Text(
              "Statistics will update automatically as calls occur",
              style: AliceStyles.caption,
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        StatsSummaryCard(stats: _statsData),
        const SizedBox(height: 12),
        StatsStatusBreakdown(stats: _statsData),
      ],
    );
  }
}
