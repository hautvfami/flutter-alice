import 'package:flutter/material.dart';
// import 'package:flutter_alice/model/alice_http_call.dart';
import 'package:flutter_alice/model/alice_http_request.dart';
import 'package:flutter_alice/ui/widget/alice_base_mixin.dart';

class AliceCallRequestWidget extends StatelessWidget with AliceBaseMixin {
  final AliceHttpRequest request;

  AliceCallRequestWidget(this.request);

  @override
  Widget build(BuildContext context) {
    List<Widget> rows = [];
    rows.add(getListRow("Started:", request.time.toString()));
    rows.add(getListRow("Bytes sent:", formatBytes(request.size)));
    rows.add(getListRow("Content type:", getContentType(request.headers)!));

    var body = request.body;
    String? bodyContent = "Body is empty";
    if (body != null) {
      bodyContent = formatBody(body, getContentType(request.headers));
    }
    rows.add(getListRow("Body:", bodyContent!));
    var formDataFields = request.formDataFields;
    if (formDataFields?.isNotEmpty == true) {
      rows.add(getListRow("Form data fields: ", ""));
      formDataFields!.forEach(
        (field) {
          rows.add(getListRow("   • ${field.name}:", "${field.value}"));
        },
      );
    }
    var formDataFiles = request.formDataFiles;
    if (formDataFiles?.isNotEmpty == true) {
      rows.add(getListRow("Form data files: ", ""));
      formDataFiles!.forEach(
        (field) {
          rows.add(getListRow("   • ${field.fileName}:",
              "${field.contentType} / ${field.length} B"));
        },
      );
    }

    var headers = request.headers;
    var headersContent = "Headers are empty";
    if (headers.length > 0) {
      headersContent = "";
    }
    rows.add(getListRow("Headers: ", headersContent));
    request.headers.forEach((header, value) {
      rows.add(getListRow("   • $header:", value.toString()));
    });

    print("qr: ${request.queryParameters}");
    var queryParameters = request.queryParameters;
    var queryParametersContent = "Query parameters are empty";
    if (queryParameters.length > 0) {
      queryParametersContent = "";
    }
    rows.add(getListRow("Query Parameters: ", queryParametersContent));
    request.queryParameters.forEach((query, value) {
      rows.add(getListRow("   • $query:", value.toString()));
    });

    return Container(
      padding: const EdgeInsets.all(6),
      child: ListView(children: rows),
    );
  }
}
