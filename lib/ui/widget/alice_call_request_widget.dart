import 'package:flutter/material.dart';
import 'package:flutter_alice/helper/alice_extensions.dart';
import 'package:flutter_alice/model/alice_http_request.dart';
import 'package:flutter_alice/ui/widget/alice_base_mixin.dart';

class AliceCallRequestWidget extends StatelessWidget with AliceBaseMixin {
  final AliceHttpRequest request;

  const AliceCallRequestWidget(this.request, {super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> rows = [];
    rows.add(getListRow("Started:", request.time.formattedTime));
    rows.add(getListRow("Bytes sent:", request.size.toFormattedBytes));
    rows.add(getListRow("Content type:", getContentType(request.headers) ?? "Unknown"));

    final body = request.body;
    String? bodyContent = "Body is empty";
    if (body != null) {
      bodyContent = formatBody(body, getContentType(request.headers));
    }
    rows.add(getListRow("Body:", bodyContent ?? "Body is empty"));

    final formDataFields = request.formDataFields;
    if (formDataFields != null && formDataFields.isNotEmpty) {
      rows.add(getListRow("Form data fields: ", ""));
      for (final field in formDataFields) {
        rows.add(getListRow("   • ${field.name}:", field.value));
      }
    }

    final formDataFiles = request.formDataFiles;
    if (formDataFiles != null && formDataFiles.isNotEmpty) {
      rows.add(getListRow("Form data files: ", ""));
      for (final field in formDataFiles) {
        rows.add(getListRow("   • ${field.fileName}:",
            "${field.contentType} / ${field.length} B"));
      }
    }

    rows.addAll(buildMapRows("Headers", request.headers));
    rows.addAll(buildMapRows("Query Parameters", request.queryParameters));

    return Container(
      padding: const EdgeInsets.all(6),
      child: ListView(children: rows),
    );
  }
}
