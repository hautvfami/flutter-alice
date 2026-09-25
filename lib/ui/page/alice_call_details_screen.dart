import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_alice/core/alice_core.dart';
import 'package:flutter_alice/helper/alice_extensions.dart';
import 'package:flutter_alice/helper/alice_save_helper.dart';
import 'package:flutter_alice/model/alice_http_call.dart';
import 'package:flutter_alice/model/alice_http_request.dart';
import 'package:flutter_alice/theme/theme.dart';
import 'package:flutter_alice/ui/widget/alice_call_error_widget.dart';
import 'package:flutter_alice/ui/widget/alice_call_overview_widget.dart';
import 'package:flutter_alice/ui/widget/alice_call_request_widget.dart';
import 'package:flutter_alice/ui/widget/alice_call_response_widget.dart';
import 'package:flutter_alice/ui/widget/alice_call_stack_widget.dart';
import 'package:share_plus/share_plus.dart';

class AliceCallDetailsScreen extends StatefulWidget {
  final AliceHttpCall call;
  final AliceCore core;

  const AliceCallDetailsScreen(this.call, this.core, {super.key});

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

          return _buildMainWidget(callSns);
        },
      ),
    );
  }

  Widget _buildMainWidget(AliceHttpCall currentCall) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        floatingActionButton: Builder(
          builder: (fabContext) => FloatingActionButton(
            key: const Key('share_key'),
            backgroundColor: AliceColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(99.0),
            ),
            onPressed: () => _onShare(fabContext, currentCall),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : const Icon(Icons.share, color: Colors.white),
          ),
        ),
        appBar: AppBar(
          centerTitle: true,
          foregroundColor: Colors.white,
          bottom: TabBar(
            tabs: _buildTabBars(currentCall),
          ),
          title: const Text('Alice - Call Details'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TabBarView(children: _buildTabBarViews(currentCall)),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AliceColors.error),
          SizedBox(height: 16),
          Text(
            "Failed to load data",
            style: AliceTextStyles.titleMedium,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTabBars(AliceHttpCall call) {
    final hasError = call.error != null;
    return [
      const Tab(icon: Icon(Icons.visibility), text: "Overview"),
      const Tab(icon: Icon(Icons.call_made), text: "Request"),
      const Tab(icon: Icon(Icons.call_received), text: "Response"),
      Tab(
        icon: Icon(hasError ? Icons.error : Icons.layers_outlined),
        text: hasError ? "Error" : "Call Stack",
      ),
    ];
  }

  List<Widget> _buildTabBarViews(AliceHttpCall currentCall) {
    return [
      AliceCallOverviewWidget(currentCall),
      AliceCallRequestWidget(currentCall.request ?? AliceHttpRequest()),
      AliceCallResponseWidget(currentCall),
      currentCall.error != null
          ? AliceCallErrorWidget(currentCall)
          : AliceCallStackWidget(currentCall),
    ];
  }

  Future<void> _onShare(
    BuildContext btnContext,
    AliceHttpCall currentCall,
  ) async {
    Rect? sharePositionOrigin;
    final box = btnContext.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      sharePositionOrigin = box.localToGlobal(Offset.zero) & box.size;
    }
    if (sharePositionOrigin == null || sharePositionOrigin.isEmpty) {
      final size = MediaQuery.sizeOf(btnContext);
      sharePositionOrigin = Rect.fromLTWH(0, 0, size.width, size.height / 2);
    }

    setState(() => isLoading = true);
    try {
      final text = await compute(AliceSaveHelper.buildCallLog, currentCall);
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
        sharePositionOrigin: sharePositionOrigin,
      );

      await SharePlus.instance.share(params);
    } catch (e) {
      debugPrint("Failed to share call: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }
}
