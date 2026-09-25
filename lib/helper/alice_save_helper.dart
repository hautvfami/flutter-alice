import 'dart:convert';

import 'package:flutter_alice/helper/alice_extensions.dart';
import 'package:flutter_alice/model/alice_http_call.dart';
import 'package:flutter_alice/ui/utils/alice_parser.dart';

class AliceSaveHelper {
  AliceSaveHelper._();

  static const _encoder = JsonEncoder.withIndent('  ');

  static String _buildAliceLog() {
    final stringBuffer = StringBuffer();
    stringBuffer.writeln("Alice - HTTP Inspector");
    stringBuffer.writeln("Generated: ${DateTime.now().toIso8601String()}");
    stringBuffer.writeln();
    return stringBuffer.toString();
  }

  static String _buildCallLog(AliceHttpCall call) {
    final stringBuffer = StringBuffer();
    stringBuffer.writeln("===========================================");
    stringBuffer.writeln("Id: ${call.id}");
    stringBuffer.writeln("============================================");
    stringBuffer.writeln("--------------------------------------------");
    stringBuffer.writeln("General data");
    stringBuffer.writeln("--------------------------------------------");
    stringBuffer.writeln("Server: ${call.server} ");
    stringBuffer.writeln("Method: ${call.method} ");
    stringBuffer.writeln("Endpoint: ${call.endpoint} ");
    stringBuffer.writeln("Client: ${call.client} ");
    stringBuffer.writeln("Duration: ${call.duration.toFormattedDuration}");
    stringBuffer.writeln("Secured connection: ${call.secure}");
    stringBuffer.writeln("Completed: ${!call.loading} ");
    stringBuffer.writeln("--------------------------------------------");
    stringBuffer.writeln("Request");
    stringBuffer.writeln("--------------------------------------------");
    if (call.request != null) {
      stringBuffer.writeln("Request time: ${call.request!.time}");
      stringBuffer.writeln("Request content type: ${call.request!.contentType}");
      stringBuffer.writeln("Request cookies: ${_encoder.convert(call.request!.cookies)}");
      stringBuffer.writeln("Request headers: ${_encoder.convert(call.request!.headers)}");
      stringBuffer.writeln("Request size: ${call.request!.size.toFormattedBytes}");
      stringBuffer.writeln(
          "Request body: ${AliceParser.formatBody(call.request!.body, AliceParser.getContentType(call.request!.headers))}");
      if (call.request!.initiator != null) {
        stringBuffer.writeln("Initiator: ${call.request!.initiator}");
      }
    }
    stringBuffer.writeln("--------------------------------------------");
    stringBuffer.writeln("Response");
    stringBuffer.writeln("--------------------------------------------");
    if (call.response != null) {
      stringBuffer.writeln("Response time: ${call.response!.time}");
      stringBuffer.writeln("Response status: ${call.response!.status}");
      stringBuffer.writeln("Response size: ${call.response!.size.toFormattedBytes}");
      stringBuffer.writeln("Response headers: ${_encoder.convert(call.response!.headers)}");
      stringBuffer.writeln(
          "Response body: ${AliceParser.formatBody(call.response!.body, AliceParser.getContentType(call.response!.headers))}");
    }
    if (call.error != null) {
      stringBuffer.writeln("--------------------------------------------");
      stringBuffer.writeln("Error");
      stringBuffer.writeln("--------------------------------------------");
      stringBuffer.writeln("Error: ${call.error!.error}");
      if (call.error!.stackTrace != null) {
        stringBuffer.writeln("Error stacktrace: ${call.error!.stackTrace}");
      }
    }
    stringBuffer.writeln("--------------------------------------------");
    stringBuffer.writeln("Curl");
    stringBuffer.writeln("--------------------------------------------");
    stringBuffer.writeln(call.getCurlCommand());
    stringBuffer.writeln();
    stringBuffer.writeln("==============================================");
    stringBuffer.writeln();

    return stringBuffer.toString();
  }

  static Future<String> buildCallLog(AliceHttpCall call) async {
    try {
      return _buildAliceLog() + _buildCallLog(call);
    } catch (exception) {
      return "Failed to generate call log";
    }
  }
}
