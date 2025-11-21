import 'package:flutter/material.dart';
import 'package:flutter_alice/core/alice_core.dart';
import 'package:flutter_alice/ui/utils/alice_parser.dart';

class AliceLogsWidget extends StatelessWidget {
  const AliceLogsWidget({
    super.key,
    required this.aliceCore,
  });

  final AliceCore aliceCore;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<String>>(
      stream: aliceCore.logsStream,
      builder: (context, snapshot) {
        final logs = snapshot.data ?? [];
        return SafeArea(
          child: ListView.separated(
            padding: EdgeInsets.all(8),
            reverse: true,
            itemBuilder: (_, i) {
              final log = AliceParser.logParser(logs[i]);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  log.message,
                  style: TextStyle(fontSize: 12, color: Color(log.color)),
                ),
              );
            },
            separatorBuilder: (_, i) => Divider(
              height: 1,
              color: Colors.white24,
            ),
            itemCount: logs.length,
          ),
        );
      },
    );
  }
}
