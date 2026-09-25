import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_alice/core/alice_core.dart';
import 'package:flutter_alice/model/alice_form_data_file.dart';
import 'package:flutter_alice/model/alice_form_data_field.dart';
import 'package:flutter_alice/model/alice_http_call.dart';
import 'package:flutter_alice/model/alice_http_error.dart';
import 'package:flutter_alice/model/alice_http_request.dart';
import 'package:flutter_alice/model/alice_http_response.dart';

class AliceDioInterceptor extends InterceptorsWrapper {
  /// AliceCore instance
  final AliceCore aliceCore;

  /// Creates dio interceptor
  AliceDioInterceptor(this.aliceCore);

  /// Handles dio request and creates alice http call based on it
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final call = AliceHttpCall(options.hashCode);

    final uri = options.uri;
    call.method = options.method;
    call.endpoint = options.uri.path.isEmpty ? "/" : options.uri.path;
    call.server = uri.host;
    call.client = "Dio";
    call.uri = options.uri.toString();
    call.secure = uri.scheme == "https";

    final request = AliceHttpRequest();
    request.stackTrace = StackTrace.current;

    final data = options.data;
    if (data == null) {
      request.size = 0;
      request.body = "";
    } else {
      if (data is FormData) {
        request.body += "Form data";

        if (data.fields.isNotEmpty) {
          request.formDataFields = data.fields
              .map((entry) => AliceFormDataField(entry.key, entry.value))
              .toList();
        }
        if (data.files.isNotEmpty) {
          request.formDataFiles = data.files
              .map((entry) => AliceFormDataFile(
                    entry.value.filename ?? "",
                    entry.value.contentType.toString(),
                    entry.value.length,
                  ))
              .toList();
        }
      } else {
        request.size = utf8.encode(data.toString()).length;
        request.body = data;
      }
    }

    request.time = DateTime.now();
    request.headers = options.headers;
    request.contentType = options.contentType.toString();
    request.queryParameters = options.uri.queryParameters;

    call.request = request;
    call.response = AliceHttpResponse();

    aliceCore.addCall(call);
    handler.next(options);
  }

  /// Handles dio response and adds data to alice http call
  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final httpResponse = _buildResponse(response);
    aliceCore.addResponse(httpResponse, response.requestOptions.hashCode);
    handler.next(response);
  }

  /// Handles error and adds data to alice http call
  @override
  void onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) {
    final httpError = AliceHttpError();
    httpError.error = error.toString();
    httpError.stackTrace = error.stackTrace;

    aliceCore.addError(httpError, error.requestOptions.hashCode);
    final httpResponse = _buildResponse(error.response);
    final responseHashCode =
        error.response?.requestOptions.hashCode ?? error.requestOptions.hashCode;
    aliceCore.addResponse(httpResponse, responseHashCode);
    handler.next(error);
  }

  AliceHttpResponse _buildResponse(Response<dynamic>? response) {
    final httpResponse = AliceHttpResponse();
    httpResponse.time = DateTime.now();
    httpResponse.status = response?.statusCode ?? -1;

    final data = response?.data;
    if (data == null) {
      httpResponse.body = "";
      httpResponse.size = 0;
    } else {
      httpResponse.body = data;
      httpResponse.size = utf8.encode(data.toString()).length;
    }

    final headers = <String, String>{};
    response?.headers.forEach((header, values) {
      headers[header] = values.toString();
    });
    httpResponse.headers = headers;
    return httpResponse;
  }
}
