import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_alice/core/alice_core.dart';
import 'package:flutter_alice/helper/alice_save_helper.dart';
import 'package:flutter_alice/model/alice_http_call.dart';
import 'package:flutter_alice/model/alice_http_request.dart';
import 'package:flutter_alice/ui/utils/alice_theme.dart';
import 'package:flutter_alice/ui/widget/alice_call_error_widget.dart';
import 'package:flutter_alice/ui/widget/alice_call_overview_widget.dart';
import 'package:flutter_alice/ui/widget/alice_call_request_widget.dart';
import 'package:flutter_alice/ui/widget/alice_call_response_widget.dart';
import 'package:share_plus/share_plus.dart';
// import 'package:collection/collection.dart';

class AliceCallDetailsScreen extends StatefulWidget {
  final AliceHttpCall call;
  final AliceCore core;

  AliceCallDetailsScreen(this.call, this.core);

  @override
  State<AliceCallDetailsScreen> createState() => _AliceCallDetailsScreenState();
}

class _AliceCallDetailsScreenState extends State<AliceCallDetailsScreen> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: aliceTheme,
      child: StreamBuilder<List<AliceHttpCall>>(
        stream: widget.core.callsSubject,
        initialData: [widget.call],
        builder: (context, snapshot) {
          if (!snapshot.hasData) return _buildErrorWidget(context);
          final callSns = snapshot.data?.firstWhereOrNull(
            (c) => c.id == widget.call.id,
          );
          if (callSns == null) return _buildErrorWidget(context);

          return _buildMainWidget();
        },
      ),
    );
  }

  Widget _buildMainWidget() {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          key: Key('share_key'),
          onPressed: _onShare,
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : Icon(Icons.share, color: Colors.white),
        ),
        appBar: AppBar(
          centerTitle: true,
          foregroundColor: Colors.white,
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: _tabBars,
          ),
          title: Text('Alice - Call Details'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TabBarView(children: _tabBarViews),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
          SizedBox(height: 16),
          Text(
            "Failed to load data",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> get _tabBars {
    return [
      Tab(icon: Icon(Icons.visibility), text: "Overview"),
      Tab(icon: Icon(Icons.call_made), text: "Request"),
      Tab(icon: Icon(Icons.call_received), text: "Response"),
      Tab(icon: Icon(Icons.error), text: "Error"),
    ];
  }

  List<Widget> get _tabBarViews {
    return [
      AliceCallOverviewWidget(widget.call),
      AliceCallRequestWidget(widget.call.request ?? AliceHttpRequest()),
      AliceCallResponseWidget(widget.call),
      AliceCallErrorWidget(widget.call),
    ];
  }

  Future<void> _onShare() async {
    setState(() => isLoading = true);
    final text = await compute(AliceSaveHelper.buildCallLog, widget.call);
    final data = await compute(utf8.encode, text);

    final XFile file = XFile.fromData(
      data,
      mimeType: 'text/plain',
      name: 'alice.txt',
    );
    final params = ShareParams(
      files: [file],
      text: 'Please check!',
      subject: 'Alice HTTP Call Log',
    );

    await SharePlus.instance.share(params);
    setState(() => isLoading = false);
  }
}
