import 'dart:convert';

class AliceParser {
  AliceParser._();

  static const String _emptyBody = "Body is empty";
  static const String _unknownContentType = "Unknown";
  static const String _jsonContentTypeSmall = "content-type";
  static const String _jsonContentTypeBig = "Content-Type";
  static const String _stream = "Stream";
  static const String _applicationJson = "application/json";
  static const String _parseFailedText = "Failed to parse ";
  static const JsonEncoder encoder = JsonEncoder.withIndent('  ');

  static String? _parseJson(dynamic json) {
    try {
      return encoder.convert(json);
    } catch (exception) {
      return json?.toString();
    }
  }

  static dynamic _decodeJson(dynamic body) {
    try {
      return json.decode(body.toString());
    } catch (exception) {
      return body;
    }
  }

  static String? formatBody(dynamic body, String? contentType) {
    try {
      if (body == null) return _emptyBody;
      String? bodyContent = _emptyBody;

      if (contentType == null ||
          !contentType.toLowerCase().contains(_applicationJson)) {
        final bodyTemp = body.toString();
        if (bodyTemp.isNotEmpty) bodyContent = bodyTemp;
      } else {
        if (body is String && body.contains("\n")) {
          bodyContent = body;
        } else {
          if (body is String) {
            if (body.isNotEmpty) {
              bodyContent = _parseJson(_decodeJson(body));
            }
          } else if (body is Stream) {
            bodyContent = _stream;
          } else {
            bodyContent = _parseJson(body);
          }
        }
      }

      return bodyContent;
    } catch (exception) {
      return "$_parseFailedText$body";
    }
  }

  static String? getContentType(Map<String, dynamic>? headers) {
    if (headers != null) {
      if (headers.containsKey(_jsonContentTypeSmall)) {
        return headers[_jsonContentTypeSmall]?.toString();
      }
      if (headers.containsKey(_jsonContentTypeBig)) {
        return headers[_jsonContentTypeBig]?.toString();
      }
    }
    return _unknownContentType;
  }

  static ({int color, String message}) logParser(String data) {
    if (data.startsWith('0X') && data.length >= 10) {
      final colorString = data.substring(0, 10);
      final message = data.substring(10);
      final color = int.tryParse(colorString) ?? 0xFFFFFFFF;
      return (color: color, message: message);
    }
    return (color: 0xFFFFFFFF, message: data);
  }
}
