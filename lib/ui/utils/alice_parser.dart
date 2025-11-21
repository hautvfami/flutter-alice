import 'dart:convert';

class AliceParser {
  static const String _emptyBody = "Body is empty";
  static const String _unknownContentType = "Unknown";
  static const String _jsonContentTypeSmall = "content-type";
  static const String _jsonContentTypeBig = "Content-Type";
  static const String _stream = "Stream";
  static const String _applicationJson = "application/json";
  static const String _parseFailedText = "Failed to parse ";
  static final JsonEncoder encoder = new JsonEncoder.withIndent('  ');

  static String? _parseJson(dynamic json) {
    try {
      return encoder.convert(json);
    } catch (exception) {
      return json;
    }
  }

  static dynamic _decodeJson(dynamic body) {
    try {
      return json.decode(body);
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
        if (bodyTemp.length > 0) bodyContent = bodyTemp;
      } else {
        if (body is String && body.contains("\n")) {
          bodyContent = body;
        } else {
          if (body is String) {
            if (body.length != 0) {
              //body is minified json, so decode it to a map and let the encoder pretty print this map
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
      return _parseFailedText + body.toString();
    }
  }

  static String? getContentType(Map<String, dynamic>? headers) {
    if (headers != null) {
      if (headers.containsKey(_jsonContentTypeSmall)) {
        return headers[_jsonContentTypeSmall];
      }
      if (headers.containsKey(_jsonContentTypeBig)) {
        return headers[_jsonContentTypeBig];
      }
    }
    return _unknownContentType;
  }

  static ({int color, String message}) logParser(String data) {
    if (data.startsWith('0X')) {
      final colorString = data.substring(0, 10);
      final message = data.substring(10);
      final color = int.parse(colorString);
      return (color: color, message: message);
    }
    return (color: 0XFFFFFFFF, message: data);
  }
}
