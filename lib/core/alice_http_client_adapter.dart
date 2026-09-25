import 'dart:convert';
import 'dart:io';

import 'package:flutter_alice/core/alice_core.dart';
import 'package:flutter_alice/model/alice_http_call.dart';
import 'package:flutter_alice/model/alice_http_request.dart';
import 'package:flutter_alice/model/alice_http_response.dart';
import 'package:flutter_alice/ui/utils/alice_parser.dart';

class AliceHttpClientAdapter {
  /// AliceCore instance
  final AliceCore aliceCore;

  /// Creates alice http client adapter
  AliceHttpClientAdapter(this.aliceCore);

  /// Handles httpClientRequest and creates http alice call from it
  void onRequest(HttpClientRequest request, {dynamic body}) {
    final call = AliceHttpCall(request.hashCode);
    call.loading = true;
    call.client = "HttpClient (io package)";
    call.method = request.method;
    call.uri = request.uri.toString();
    call.endpoint = request.uri.path.isEmpty ? "/" : request.uri.path;
    call.server = request.uri.host;
    call.secure = request.uri.scheme == "https";

    final httpRequest = AliceHttpRequest();
    httpRequest.stackTrace = StackTrace.current;
    if (body == null) {
      httpRequest.size = 0;
      httpRequest.body = "";
    } else {
      httpRequest.size = utf8.encode(body.toString()).length;
      httpRequest.body = body;
    }
    httpRequest.time = DateTime.now();

    final Map<String, dynamic> headers = {};
    request.headers.forEach((header, values) {
      headers[header] = values.join(', ');
    });
    httpRequest.headers = headers;
    httpRequest.contentType = AliceParser.getContentType(headers);
    httpRequest.cookies = request.cookies;

    call.request = httpRequest;
    call.response = AliceHttpResponse();
    aliceCore.addCall(call);
  }

  /// Handles httpClientRequest and adds response to http alice call
  void onResponse(HttpClientResponse response, HttpClientRequest request,
      {dynamic body}) {
    final httpResponse = AliceHttpResponse();
    httpResponse.status = response.statusCode;

    if (body != null) {
      httpResponse.body = body;
      httpResponse.size = utf8.encode(body.toString()).length;
    } else {
      httpResponse.body = "";
      httpResponse.size = 0;
    }
    httpResponse.time = DateTime.now();
    final Map<String, String> headers = {};
    response.headers.forEach((header, values) {
      headers[header] = values.join(', ');
    });
    httpResponse.headers = headers;
    aliceCore.addResponse(httpResponse, request.hashCode);
  }
}
