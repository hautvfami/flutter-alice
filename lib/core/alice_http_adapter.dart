import 'dart:convert';

import 'package:flutter_alice/core/alice_core.dart';
import 'package:flutter_alice/model/alice_http_call.dart';
import 'package:flutter_alice/model/alice_http_request.dart';
import 'package:flutter_alice/model/alice_http_response.dart';
import 'package:flutter_alice/ui/utils/alice_parser.dart';
import 'package:http/http.dart' as http;

class AliceHttpAdapter {
  /// AliceCore instance
  final AliceCore aliceCore;

  /// Creates alice http adapter
  AliceHttpAdapter(this.aliceCore);

  /// Handles http response. It creates both request and response from http call
  void onResponse(http.Response response, {dynamic body}) {
    final request = response.request;
    if (request == null) {
      return;
    }

    final call = AliceHttpCall(request.hashCode);
    call.loading = false;
    call.client = "HttpClient (http package)";
    call.uri = request.url.toString();
    call.method = request.method;
    call.endpoint = request.url.path.isEmpty ? "/" : request.url.path;
    call.server = request.url.host;
    call.secure = request.url.scheme == "https";

    final httpRequest = AliceHttpRequest();

    if (request is http.Request) {
      httpRequest.body = body ?? request.body;
      httpRequest.size = utf8.encode(httpRequest.body.toString()).length;
      httpRequest.headers = Map<String, dynamic>.from(request.headers);
    } else if (body == null) {
      httpRequest.size = 0;
      httpRequest.body = "";
    } else {
      httpRequest.size = utf8.encode(body.toString()).length;
      httpRequest.body = body;
    }

    httpRequest.time = DateTime.now();
    httpRequest.contentType = AliceParser.getContentType(httpRequest.headers);
    httpRequest.queryParameters = request.url.queryParameters;

    final httpResponse = AliceHttpResponse();
    httpResponse.status = response.statusCode;
    httpResponse.body = response.body;

    httpResponse.size = utf8.encode(response.body).length;
    httpResponse.time = DateTime.now();
    httpResponse.headers = Map<String, String>.from(response.headers);

    call.request = httpRequest;
    call.response = httpResponse;
    call.duration = 0;
    aliceCore.addCall(call);
  }
}
