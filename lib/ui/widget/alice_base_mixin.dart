import 'package:flutter/material.dart';
import 'package:flutter_alice/helper/alice_convert_helper.dart';
import 'package:flutter_alice/theme/alice_widgets.dart';
import 'package:flutter_alice/ui/utils/alice_parser.dart';

mixin AliceBaseMixin {
  Widget getListRow(String name, String value) {
    return AliceListRow(name: name, value: value);
  }

  String formatBytes(int bytes) => AliceConvertHelper.formatBytes(bytes);

  String formatDuration(int duration) =>
      AliceConvertHelper.formatTime(duration);

  String? formatBody(dynamic body, String? contentType) =>
      AliceParser.formatBody(body, contentType);

  String? getContentType(Map<String, dynamic>? headers) =>
      AliceParser.getContentType(headers);

  List<Widget> buildMapRows(
    String title,
    Map<String, dynamic>? map, {
    String? emptyText,
  }) {
    final rows = <Widget>[];
    final isEmpty = map == null || map.isEmpty;
    rows.add(
      getListRow("$title: ", isEmpty ? (emptyText ?? "$title are empty") : ""),
    );
    if (!isEmpty) {
      map.forEach((key, value) {
        rows.add(getListRow("   • $key:", value.toString()));
      });
    }
    return rows;
  }
}
