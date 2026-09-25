import 'package:flutter/material.dart';
import 'package:flutter_alice/core/alice_core.dart';
import 'package:flutter_alice/theme/theme.dart';
import 'package:flutter_alice/ui/widget/alice_logs_widget.dart';

class AliceLogsScreen extends StatelessWidget {
  final AliceCore aliceCore;

  const AliceLogsScreen(
    this.aliceCore, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: aliceTheme,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: const Text('Console'),
          elevation: 0.0,
          scrolledUnderElevation: 0.0,
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Clear logs',
              onPressed: aliceCore.clearLogs,
            ),
          ],
        ),
        body: AliceLogsWidget(aliceCore: aliceCore),
      ),
    );
  }
}
