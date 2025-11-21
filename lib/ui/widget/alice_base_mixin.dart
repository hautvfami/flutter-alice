import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_alice/helper/alice_convert_helper.dart';
import 'package:flutter_alice/ui/utils/alice_parser.dart';

mixin AliceBaseMixin {
  final JsonEncoder encoder = new JsonEncoder.withIndent('  ');

  Widget getListRow(String name, String value) {
    return RichText(
        text: TextSpan(
      children: [
        TextSpan(
          text: name == 'Body:' ? '$name\n' : '$name\t\t\t',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        TextSpan(
          text: '$value',
          style: TextStyle(color: Colors.black),
        ),
      ],
    ));
  }

  String formatBytes(int bytes) => AliceConvertHelper.formatBytes(bytes);

  String formatDuration(int duration) =>
      AliceConvertHelper.formatTime(duration);

  String? formatBody(dynamic body, String? contentType) =>
      AliceParser.formatBody(body, contentType);

  String? getContentType(Map<String, dynamic>? headers) =>
      AliceParser.getContentType(headers);
}
