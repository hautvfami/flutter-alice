import 'dart:convert';

import 'package:flutter_alice/model/alice_http_error.dart';
import 'package:flutter_alice/model/alice_http_request.dart';
import 'package:flutter_alice/model/alice_http_response.dart';

class AliceHttpCall {
  final int id;
  String client = "";
  bool loading = true;
  bool secure = false;
  String method = "";
  String endpoint = "";
  String server = "";
  String uri = "";
  int duration = 0;

  AliceHttpRequest? request;
  AliceHttpResponse? response;
  AliceHttpError? error;

  AliceHttpCall(this.id);

  void setResponse(AliceHttpResponse response) {
    this.response = response;
    loading = false;
  }

  String getCurlCommand() {
    var compressed = false;
    final buffer = StringBuffer("curl -X $method");
    final headers = Map<String, dynamic>.from(request?.headers ?? {});
    headers.remove('content-length');
    headers.forEach((key, value) {
      if ("Accept-Encoding" == key && "gzip" == value) {
        compressed = true;
      }
      buffer.write(" -H '$key: $value'");
    });

    final body = request?.body;
    if (body != null && body != '') {
      final String requestBody = jsonEncode(body);
      buffer.write(" --data \$'${requestBody.replaceAll("\n", "\\n")}'");
    }

    final formDataFields = request?.formDataFields;
    if (formDataFields != null && formDataFields.isNotEmpty) {
      for (final field in formDataFields) {
        buffer.write(" --form '${field.name}=${field.value}'");
      }
    }

    final formDataFiles = request?.formDataFiles;
    if (formDataFiles != null && formDataFiles.isNotEmpty) {
      for (final field in formDataFiles) {
        buffer.write(" --form '${field.fileName}=@${field.fileName}'");
      }
    }

    if (compressed) {
      buffer.write(" --compressed");
    }

    final targetUrl = uri.isNotEmpty
        ? uri
        : '${secure ? "https://" : "http://"}$server$endpoint';
    buffer.write(" '$targetUrl'");

    return buffer.toString();
  }
}
