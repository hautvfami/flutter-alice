import 'package:flutter/material.dart';
import 'package:flutter_alice/core/alice_core.dart';
import 'package:flutter_alice/ui/widget/alice_logs_widget.dart';

class AliceLogsScreen extends StatelessWidget {
  final AliceCore aliceCore;
  const AliceLogsScreen(
    this.aliceCore, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        title: Text('Alice Logs'),
        actions: [
          IconButton(
            icon: Icon(Icons.recycling),
            onPressed: aliceCore.clearLogs,
          ),
        ],
      ),
      body: Container(
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
    );
  }
}
