import 'package:flutter/material.dart';
import 'package:flutter_alice/model/alice_http_call.dart';
import 'package:flutter_alice/ui/widget/alice_base_mixin.dart';

class AliceCallOverviewWidget extends StatelessWidget with AliceBaseMixin {
  final AliceHttpCall call;

  AliceCallOverviewWidget(this.call);

  AliceHttpCall get _call => call;

  @override
  Widget build(BuildContext context) {
    List<Widget> rows = [];
    rows.add(getListRow("Method: ", _call.method));
    rows.add(getListRow("Server: ", _call.server));
    rows.add(getListRow("Endpoint: ", _call.endpoint));
    rows.add(getListRow("Started:", _call.request!.time.toString()));
    rows.add(getListRow("Finished:", _call.response!.time.toString()));
    rows.add(getListRow("Duration:", formatDuration(_call.duration)));
    rows.add(getListRow("Bytes sent:", formatBytes(_call.request!.size)));
    rows.add(getListRow("Bytes received:", formatBytes(_call.response!.size)));
    rows.add(getListRow("Client:", _call.client));
    rows.add(getListRow("Secure:", _call.secure.toString()));
    return Container(
      padding: const EdgeInsets.all(6),
      child: ListView(children: rows),
    );
  }
}
