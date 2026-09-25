import 'package:flutter_alice/helper/alice_extensions.dart';
import 'package:flutter_alice/model/alice_http_call.dart';
import 'package:flutter_alice/model/alice_http_request.dart';
import 'package:flutter_alice/model/alice_http_response.dart';
import 'package:flutter_alice/model/alice_menu_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AliceExtensions - Int', () {
    test('toFormattedBytes formats correctly', () {
      expect(0.toFormattedBytes, '0 B');
      expect(500.toFormattedBytes, '500 B');
      expect(1000.toFormattedBytes, '1000 B');
      expect(1024.toFormattedBytes, '1.02 kB');
      expect((1024 * 1024).toFormattedBytes, '1.05 MB');
    });

    test('toFormattedDuration formats milliseconds correctly', () {
      expect(0.toFormattedDuration, '0 ms');
      expect(450.toFormattedDuration, '450 ms');
      expect(1000.toFormattedDuration, '1000 ms');
    });
  });

  group('AliceExtensions - Iterable', () {
    test('firstWhereOrNull finds element or returns null', () {
      final list = [1, 2, 3, 4, 5];
      expect(list.firstWhereOrNull((x) => x == 3), 3);
      expect(list.firstWhereOrNull((x) => x == 99), isNull);
    });
  });

  group('AliceHttpCall - cURL Generation', () {
    test('generates valid curl with method, headers, and body', () {
      final call = AliceHttpCall(1);
      call.method = 'POST';
      call.server = 'api.example.com';
      call.endpoint = '/v1/users';
      call.client = 'Alice';
      call.uri = 'https://api.example.com/v1/users';

      final request = AliceHttpRequest();
      request.headers = {
        'Authorization': 'Bearer test-token',
        'Content-Type': 'application/json',
      };
      request.body = '{"name":"John"}';
      call.request = request;

      final curl = call.getCurlCommand();
      expect(curl, contains("curl -X POST"));
      expect(curl, contains("'https://api.example.com/v1/users'"));
      expect(curl, contains("-H 'Authorization: Bearer test-token'"));
      expect(curl, contains("-H 'Content-Type: application/json'"));
      expect(curl, contains("--data"));
    });

    test('statusText returns correct string', () {
      final call = AliceHttpCall(2);
      expect(call.statusText, '???');

      call.loading = false;
      call.response = AliceHttpResponse()..status = 200;
      expect(call.statusText, '200');

      call.response = AliceHttpResponse()..status = 404;
      expect(call.statusText, '404');

      call.response = AliceHttpResponse()..status = -1;
      expect(call.statusText, 'ERR');
    });
  });

  group('AliceMenuItem & AliceMenuAction', () {
    test('AliceMenuAction enum has clear, stats, and about', () {
      expect(AliceMenuAction.values.length, 3);
      expect(AliceMenuAction.values, contains(AliceMenuAction.clear));
      expect(AliceMenuAction.values, contains(AliceMenuAction.stats));
      expect(AliceMenuAction.values, contains(AliceMenuAction.about));
    });
  });
}
