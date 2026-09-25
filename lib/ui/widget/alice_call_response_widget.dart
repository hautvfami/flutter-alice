import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_alice/core/alice_core.dart';
import 'package:flutter_alice/helper/alice_extensions.dart';
import 'package:flutter_alice/helper/alice_json_viewer.dart';
import 'package:flutter_alice/model/alice_http_call.dart';
import 'package:flutter_alice/theme/theme.dart';
import 'package:flutter_alice/ui/widget/alice_base_mixin.dart';

class AliceCallResponseWidget extends StatefulWidget {
  final AliceHttpCall call;

  const AliceCallResponseWidget(this.call, {super.key});

  @override
  State<StatefulWidget> createState() => _AliceCallResponseWidgetState();
}

class _AliceCallResponseWidgetState extends State<AliceCallResponseWidget>
    with AliceBaseMixin {
  static const _imageContentType = "image";
  static const _jsonContentType = "json";
  static const _xmlContentType = "xml";
  static const _textContentType = "text";

  static const _kLargeOutputSize = 100000;
  bool _showLargeBody = false;
  bool _showUnsupportedBody = false;

  AliceHttpCall get _call => widget.call;

  @override
  Widget build(BuildContext context) {
    if (!_call.loading && _call.response != null) {
      final List<Widget> rows = [];
      rows.addAll(_buildGeneralDataRows());
      rows.addAll(_buildHeadersRows());
      rows.addAll(_buildBodyRows());

      return Container(
        padding: const EdgeInsets.all(6),
        child: ListView(children: rows),
      );
    } else {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 8),
            Text("Awaiting response...")
          ],
        ),
      );
    }
  }

  List<Widget> _buildGeneralDataRows() {
    final List<Widget> rows = [];
    final response = _call.response;
    if (response == null) return rows;

    rows.add(getListRow("Received:", response.time.formattedTime));
    rows.add(getListRow("Bytes received:", response.size.toFormattedBytes));
    rows.add(getListRow("Status:", _call.statusText));
    return rows;
  }

  List<Widget> _buildHeadersRows() {
    return buildMapRows("Headers", _call.response?.headers);
  }

  List<Widget> _buildBodyRows() {
    final List<Widget> rows = [];
    if (_isImageResponse()) {
      rows.addAll(_buildImageBodyRows());
    } else if (_isTextResponse()) {
      if (_isLargeResponseBody()) {
        rows.addAll(_buildLargeBodyTextRows());
      } else {
        rows.addAll(_buildTextBodyRows());
      }
    } else {
      rows.addAll(_buildUnknownBodyRows());
    }

    return rows;
  }

  List<Widget> _buildImageBodyRows() {
    return [
      Column(
        children: [
          const Row(
            children: [
              Text(
                "Body: Image",
                style: AliceStyles.bodyBold,
              )
            ],
          ),
          const SizedBox(height: 8),
          Image.network(
            _call.uri,
            fit: BoxFit.fill,
            headers: _buildRequestHeaders(),
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      )
    ];
  }

  List<Widget> _buildLargeBodyTextRows() {
    final List<Widget> rows = [];
    if (_showLargeBody) {
      return _buildTextBodyRows();
    } else {
      rows.add(getListRow("Body:",
          "Too large to show (${_call.response?.body.toString().length ?? 0} Bytes)"));
      rows.add(const SizedBox(height: 8));
      rows.add(
        AliceButton(
          text: "Show body",
          onPressed: () {
            setState(() {
              _showLargeBody = true;
            });
          },
        ),
      );
      rows.add(const SizedBox(height: 8));
      rows.add(
        Text(
          "Warning! It will take some time to render output.",
          style: AliceStyles.caption.copyWith(color: AliceColors.warning),
        ),
      );
    }
    return rows;
  }

  List<Widget> _buildTextBodyRows() {
    final List<Widget> rows = [];
    final headers = _call.response?.headers;
    final bodyContent = formatBody(
      _call.response?.body,
      getContentType(headers),
    ) ?? "";

    if ((_getContentTypeOfResponse() ?? "").toLowerCase().contains(_jsonContentType)) {
      try {
        final dynamic json = jsonDecode(bodyContent);
        rows.add(
          InkWell(
            onTap: () => AliceCore.inst.push(
              (_) => AliceJsonViewer(jsonObj: json),
            ),
            child: getListRow("Body:", bodyContent),
          ),
        );
        return rows;
      } catch (_) {
        // If parsing json fails, fall back to plain text
      }
    }
    rows.add(getListRow("Body:", bodyContent));
    return rows;
  }

  List<Widget> _buildUnknownBodyRows() {
    final List<Widget> rows = [];
    final headers = _call.response?.headers;
    final contentType = getContentType(headers) ?? "<unknown>";

    if (_showUnsupportedBody || _call.response?.body == '') {
      final bodyContent = formatBody(
        _call.response?.body,
        getContentType(headers),
      ) ?? "";
      final widget = getListRow("Body:", bodyContent);
      rows.add(widget);
    } else {
      rows.add(
        getListRow(
          "Body:",
          "Unsupported body. Alice can render image/text body. "
              "Response has Content-Type: $contentType which can't be handled. "
              "You can try button below to try render body as text.",
        ),
      );
      rows.add(
        AliceButton(
          text: "Show unsupported body",
          onPressed: () => setState(() => _showUnsupportedBody = true),
        ),
      );
    }
    return rows;
  }

  Map<String, String> _buildRequestHeaders() {
    final Map<String, String> requestHeaders = {};
    if (_call.request?.headers != null) {
      requestHeaders.addAll(
        _call.request!.headers.map((k, v) => MapEntry(k, v.toString())),
      );
    }
    return requestHeaders;
  }

  bool _isImageResponse() {
    return (_getContentTypeOfResponse() ?? "")
        .toLowerCase()
        .contains(_imageContentType);
  }

  bool _isTextResponse() {
    final String responseContentTypeLowerCase =
        (_getContentTypeOfResponse() ?? "").toLowerCase();

    return responseContentTypeLowerCase.contains(_jsonContentType) ||
        responseContentTypeLowerCase.contains(_xmlContentType) ||
        responseContentTypeLowerCase.contains(_textContentType);
  }

  String? _getContentTypeOfResponse() {
    return getContentType(_call.response?.headers);
  }

  bool _isLargeResponseBody() {
    return _call.response?.body != null &&
        _call.response!.body.toString().length > _kLargeOutputSize;
  }
}
