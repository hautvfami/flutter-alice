import 'dart:io';

import 'package:flutter_alice/model/alice_form_data_file.dart';
import 'package:flutter_alice/model/alice_form_data_field.dart';

class AliceHttpRequest {
  int size = 0;
  DateTime time = DateTime.now();
  Map<String, dynamic> headers = {};
  dynamic body = "";
  String? contentType = "";
  List<Cookie> cookies = [];
  Map<String, dynamic> queryParameters = {};
  List<AliceFormDataFile>? formDataFiles;
  List<AliceFormDataField>? formDataFields;
  StackTrace? stackTrace;

  /// Returns the first application-level frame from stackTrace (excluding Alice, Dio, etc.)
  String? get initiator {
    if (stackTrace == null) return null;
    final lines = stackTrace.toString().split('\n');
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      if (trimmed.contains('flutter_alice') ||
          trimmed.contains('package:dio') ||
          trimmed.contains('package:http') ||
          trimmed.contains('dart:async') ||
          trimmed.contains('dart:io')) {
        continue;
      }
      return trimmed;
    }
    return null;
  }
}

