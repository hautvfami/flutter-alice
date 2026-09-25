import 'package:flutter/material.dart';
import 'package:flutter_alice/core/alice_core.dart';
import 'package:flutter_alice/helper/alice_alert_helper.dart';
import 'package:flutter_alice/model/alice_calls_filter.dart';
import 'package:flutter_alice/model/alice_http_call.dart';
import 'package:flutter_alice/model/alice_menu_item.dart';
import 'package:flutter_alice/theme/theme.dart';
import 'package:flutter_alice/ui/page/alice_about.dart';
import 'package:flutter_alice/ui/page/alice_call_details_screen.dart';
import 'package:flutter_alice/ui/page/alice_logs_screen.dart';
import 'package:flutter_alice/ui/page/statistics/alice_stats_screen.dart';
import 'package:flutter_alice/ui/widget/alice_call_list_item_widget.dart';
import 'package:flutter_alice/ui/widget/alice_logs_widget.dart';
import 'package:flutter_alice/ui/widget/alice_menu_dialog.dart';
import 'package:flutter_alice/ui/widget/alice_search_bottom_sheet.dart';

class AliceCallsListScreen extends StatefulWidget {
  final AliceCore _aliceCore;

  const AliceCallsListScreen(this._aliceCore, {super.key});

  @override
  State<AliceCallsListScreen> createState() => _AliceCallsListScreenState();
}

class _AliceCallsListScreenState extends State<AliceCallsListScreen> {
  AliceCore get aliceCore => widget._aliceCore;

  AliceCallsFilter _filter = AliceCallsFilter.empty;
  final ValueNotifier<int> _filteredCountNotifier = ValueNotifier<int>(0);

  @override
  void dispose() {
    _filteredCountNotifier.dispose();
    super.dispose();
  }

  void _openSearchBottomSheet(int totalCount) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => AliceSearchBottomSheet(
        initialFilter: _filter,
        totalCount: totalCount,
        filteredCountNotifier: _filteredCountNotifier,
        onFilterChanged: (newFilter) {
          setState(() {
            _filter = newFilter;
          });
        },
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _filter = AliceCallsFilter.empty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return Theme(
      data: aliceTheme,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text("Alice - Inspector"),
          centerTitle: true,
          actions: [
            _buildSearchButton(),
            _buildMenuButton(),
          ],
        ),
        body: Column(
          children: [
            Expanded(child: _buildCallsListWrapper()),
            if (aliceCore.logs.isNotEmpty)
              _buildBottomConsolePreview(height),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomConsolePreview(double height) {
    return GestureDetector(
      onTap: () {
        aliceCore.push((context) => AliceLogsScreen(aliceCore));
      },
      child: Container(
        height: height * 0.15,
        decoration: BoxDecoration(
          color: AliceColors.primary,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(left: 16.0, top: 4),
              child: Text(
                '> Console',
                style: AliceTextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(child: AliceLogsWidget(aliceCore: aliceCore)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    return IconButton(
      icon: Badge(
        isLabelVisible: _filter.hasActiveFilters,
        backgroundColor: AliceColors.warning,
        smallSize: 8,
        child: const Icon(Icons.search_rounded),
      ),
      tooltip: "Search & Filter",
      onPressed: () {
        final totalCalls = aliceCore.callsSubject.value.length;
        _openSearchBottomSheet(totalCalls);
      },
    );
  }

  Widget _buildMenuButton() {
    return IconButton(
      icon: const Icon(Icons.more_vert),
      onPressed: () {
        showDialog<void>(
          context: context,
          builder: (_) => AliceMenuDialog(
            onMenuItemSelected: _onMenuItemSelected,
          ),
        );
      },
    );
  }

  void _onMenuItemSelected(AliceMenuItem menuItem) {
    switch (menuItem.action) {
      case AliceMenuAction.clear:
        _showRemoveDialog();
      case AliceMenuAction.stats:
        aliceCore.push((context) => AliceStatsScreen(aliceCore));
      case AliceMenuAction.about:
        aliceCore.push((context) => const AliceAbout());
    }
  }

  bool _matchesCall(AliceHttpCall call, AliceCallsFilter filter) {
    if (filter.method != 'ALL') {
      if (call.method.toUpperCase() != filter.method) return false;
    }

    if (filter.status != 'ALL') {
      final status = call.response?.status ?? 0;
      final hasError = call.error != null;
      switch (filter.status) {
        case '2xx':
          if (status < 200 || status >= 300) return false;
          break;
        case '3xx':
          if (status < 300 || status >= 400) return false;
          break;
        case '4xx':
          if (status < 400 || status >= 500) return false;
          break;
        case '5xx':
          if (status < 500 || status >= 600) return false;
          break;
        case 'Error':
          if (!hasError && status < 400) return false;
          break;
      }
    }

    if (filter.query.isNotEmpty) {
      final q = filter.query.toLowerCase();
      final endpointMatch = call.endpoint.toLowerCase().contains(q);
      final serverMatch = call.server.toLowerCase().contains(q);
      final methodMatch = call.method.toLowerCase().contains(q);
      final uriMatch = call.uri.toLowerCase().contains(q);
      final statusMatch = call.response?.status.toString().contains(q) ?? false;
      final errorMatch =
          call.error?.error?.toString().toLowerCase().contains(q) ?? false;

      if (!endpointMatch &&
          !serverMatch &&
          !methodMatch &&
          !uriMatch &&
          !statusMatch &&
          !errorMatch) {
        return false;
      }
    }

    return true;
  }

  Widget _buildCallsListWrapper() {
    return StreamBuilder<List<AliceHttpCall>>(
      stream: aliceCore.callsSubject,
      builder: (context, snapshot) {
        final List<AliceHttpCall> allCalls = snapshot.data ?? <AliceHttpCall>[];
        if (allCalls.isEmpty) return _buildEmptyWidget();

        final filteredCalls =
            allCalls.where((call) => _matchesCall(call, _filter)).toList();

        // Update the notifier asynchronously to avoid build-phase notifications
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _filteredCountNotifier.value != filteredCalls.length) {
            _filteredCountNotifier.value = filteredCalls.length;
          }
        });

        if (filteredCalls.isEmpty) {
          return _buildNoSearchResultsWidget();
        }

        return _buildCallsListWidget(filteredCalls);
      },
    );
  }

  Widget _buildNoSearchResultsWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off_rounded,
              color: AliceColors.warning,
              size: 48,
            ),
            const SizedBox(height: 12),
            const Text(
              "No matching calls found",
              style: AliceTextStyles.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _filter.query.isNotEmpty
                  ? "No results for '${_filter.query}' with current filters"
                  : "No calls match the selected status/method filter",
              style: AliceTextStyles.caption,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text("Reset Filters"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AliceColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _resetFilters,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: AliceColors.warning, size: 48),
            SizedBox(height: 12),
            Text(
              "There are no calls to show",
              style: AliceTextStyles.titleLarge,
            ),
            SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "• Check if you send any http request",
                  style: AliceTextStyles.caption,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4),
                Text(
                  "• Check your Alice configuration",
                  style: AliceTextStyles.caption,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4),
                Text(
                  "• Check search filters",
                  style: AliceTextStyles.caption,
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallsListWidget(List<AliceHttpCall> calls) {
    return ListView.separated(
      itemCount: calls.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, index) {
        return AliceCallListItemWidget(
          calls[index],
          (call) => aliceCore.push(
            (context) => AliceCallDetailsScreen(call, aliceCore),
          ),
        );
      },
    );
  }

  void _showRemoveDialog() {
    AliceAlertHelper.showAlert(
      context,
      "Delete calls",
      "Do you want to delete all http calls?",
      firstButtonTitle: "No",
      firstButtonAction: () {},
      secondButtonTitle: "Yes",
      secondButtonAction: aliceCore.clears,
    );
  }
}

