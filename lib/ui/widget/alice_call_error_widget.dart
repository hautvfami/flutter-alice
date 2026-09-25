import 'package:flutter/material.dart';
import 'package:flutter_alice/model/alice_http_call.dart';
import 'package:flutter_alice/theme/theme.dart';
import 'package:flutter_alice/ui/widget/alice_base_mixin.dart';

class AliceCallErrorWidget extends StatelessWidget with AliceBaseMixin {
  final AliceHttpCall call;

  const AliceCallErrorWidget(this.call, {super.key});

  @override
  Widget build(BuildContext context) {
    final error = call.error;
    if (error != null) {
      final List<Widget> rows = [];
      final dynamic err = error.error;
      final String errorText = err != null ? err.toString() : "Error is empty";
      rows.add(getListRow("Error:", errorText));

      if (error.stackTrace != null) {
        rows.add(const SizedBox(height: 8));
        rows.add(getListRow("Stack trace:", error.stackTrace.toString()));
      }

      return Container(
        padding: const EdgeInsets.all(6),
        child: ListView(children: rows),
      );
    } else {
      return const Center(
        child: Text("Nothing to display here", style: AliceStyles.caption),
      );
    }
  }
}
