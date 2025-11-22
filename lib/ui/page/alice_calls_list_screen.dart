import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_alice/core/alice_core.dart';
// import 'package:flutter_alice/helper/alice_alert_helper.dart';
import 'package:flutter_alice/model/alice_http_call.dart';
// import 'package:flutter_alice/model/alice_menu_item.dart';
import 'package:flutter_alice/ui/page/alice_about.dart';
import 'package:flutter_alice/ui/page/alice_call_details_screen.dart';
import 'package:flutter_alice/ui/page/alice_logs_screen.dart';
import 'package:flutter_alice/ui/utils/alice_constants.dart';
import 'package:flutter_alice/ui/utils/alice_theme.dart';
import 'package:flutter_alice/ui/widget/alice_call_list_item_widget.dart';
import 'package:flutter_alice/ui/widget/alice_logs_widget.dart';
// import 'package:flutter_alice/ui/widget/alice_menu_dialog.dart';

// import 'alice_stats_screen.dart';

class AliceCallsListScreen extends StatefulWidget {
  final AliceCore _aliceCore;

  AliceCallsListScreen(this._aliceCore);

  @override
  State<AliceCallsListScreen> createState() => _AliceCallsListScreenState();
}

class _AliceCallsListScreenState extends State<AliceCallsListScreen> {
  AliceCore get aliceCore => widget._aliceCore;
  bool _searchEnabled = false;
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: aliceTheme,
      child: Scaffold(
        appBar: AppBar(
          title: _buildTitle(),
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
              GestureDetector(
                onTap: () {
                  aliceCore.push((context) => AliceLogsScreen(aliceCore));
                },
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.15,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.all(
                      Radius.circular(16.0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                        child: Text(
                          '>Console:',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(child: AliceLogsWidget(aliceCore: aliceCore)),
                    ],
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
  }

  Widget _buildSearchButton() {
    return IconButton(
      icon: Icon(Icons.search_rounded),
      onPressed: _onSearchClicked,
    );
  }

  void _onSearchClicked() {
    setState(() {
      _searchEnabled = !_searchEnabled;
      if (!_searchEnabled) _textController.text = "";
    });
  }

  Widget _buildMenuButton() {
    return IconButton(
      onPressed: () {
        aliceCore.push((context) => AliceAbout());
        // showDialog(
        //   context: context,
        //   builder: (_) => AliceMenuDialog(
        //     onMenuItemSelected: _onMenuItemSelected,
        //   ),
        // );
      },
      icon: Icon(CupertinoIcons.settings),
    );
  }

  Widget _buildTitle() {
    if (!_searchEnabled) return Text("Alice - Inspector");

    return TextField(
      controller: _textController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: "Search http request...",
        hintStyle: TextStyle(fontSize: 16.0, color: Colors.white),
        // border: InputBorder,
      ),
      onTapOutside: (event) => FocusScope.of(context).unfocus(),
      style: TextStyle(fontSize: 16.0),
      onChanged: (_) => setState(() {}),
    );
  }

  // void _onMenuItemSelected(AliceMenuItem menuItem) {
  //   if (menuItem.title == "Delete") _showRemoveDialog();
  //   if (menuItem.title == "Stats") {
  //     aliceCore.push((context) => AliceStatsScreen(aliceCore));
  //   }
  //   if (menuItem.title == "About") {
  //     aliceCore.push((context) => AliceAbout());
  //   }
  // }

  Widget _buildCallsListWrapper() {
    return StreamBuilder<List<AliceHttpCall>>(
      stream: aliceCore.callsSubject,
      builder: (context, snapshot) {
        List<AliceHttpCall> calls = snapshot.data ?? <AliceHttpCall>[];
        final query = _textController.text.trim();

        if (query.isNotEmpty) {
          calls = calls
              .where(
                  (e) => e.endpoint.toLowerCase().contains(query.toLowerCase()))
              .toList();
        }

        if (calls.isEmpty) return _buildEmptyWidget();

        return _buildCallsListWidget(calls);
      },
    );
  }

  Widget _buildEmptyWidget() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: AliceConstants.orange),
            const SizedBox(height: 6),
            Text("There are no calls to show", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "• Check if you send any http request",
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "• Check your Alice configuration",
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "• Check search filters",
                  style: TextStyle(fontSize: 12),
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
      separatorBuilder: (_, __) => Divider(height: 1, color: Colors.black12),
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

  // void _showRemoveDialog() {
  //   AliceAlertHelper.showAlert(
  //     context,
  //     "Delete calls",
  //     "Do you want to delete http calls?",
  //     firstButtonTitle: "No",
  //     firstButtonAction: () => {},
  //     secondButtonTitle: "Yes",
  //     secondButtonAction: aliceCore.clears,
  //   );
  // }
}
