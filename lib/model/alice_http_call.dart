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

  AliceHttpCall(this.id) {
    loading = true;
  }

  setResponse(AliceHttpResponse response) {
    this.response = response;
    loading = false;
  }

  String getCurlCommand() {
    var compressed = false;
    var curlCmd = "curl";
    curlCmd += " -X " + method;
    var headers = request!.headers;
    headers..remove('content-length');
    headers.forEach((key, value) {
      if ("Accept-Encoding" == key && "gzip" == value) {
        compressed = true;
      }
      curlCmd += " -H \'$key: $value\'";
    });

    if (request?.body != null && request?.body != '') {
      String? requestBody = jsonEncode(request?.body);
      // try to keep to a single line and use a subshell to preserve any line breaks
      curlCmd += " --data \$'" + requestBody.replaceAll("\n", "\\n") + "'";
    }

    if (request?.formDataFields != null) {
      var formDataFields = request?.formDataFields;
      if (formDataFields != null && formDataFields.isNotEmpty) {
        formDataFields.forEach((field) {
          curlCmd += " --form \'${field.name}=${field.value}\'";
        });
      }
    }

    if (request?.formDataFiles != null) {
      var formDataFiles = request?.formDataFiles;
      if (formDataFiles != null && formDataFiles.isNotEmpty) {
        formDataFiles.forEach((field) {
          curlCmd += " --form \'${field.fileName}=@${field.fileName}\'";
        });
      }
    }

    String query = '';
    if (request?.queryParameters != null) {
      var queryParams = request?.queryParameters;
      if (queryParams != null && queryParams.isNotEmpty) {
        query += "?";
        query += queryParams.entries
            .map((e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
            .join('&');
      }
    }

    curlCmd += ((compressed) ? " --compressed " : " ") +
        "\'${secure ? 'https://' : 'http://'}$server$endpoint$query\'";

    return curlCmd;
  }
}
