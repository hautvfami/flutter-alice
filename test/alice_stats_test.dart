import 'package:flutter/material.dart';
import 'package:flutter_alice/core/alice_core.dart';
import 'package:flutter_alice/model/alice_http_call.dart';
import 'package:flutter_alice/model/alice_http_request.dart';
import 'package:flutter_alice/model/alice_http_response.dart';
import 'package:flutter_alice/ui/page/statistics/alice_stats_screen.dart';
import 'package:flutter_alice/ui/page/statistics/model/alice_stats_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AliceStatsData - compute', () {
    test('computes empty calls list correctly', () {
      final data = AliceStatsData.compute([]);
      expect(data.totalRequests, 0);
      expect(data.errorRate, 0.0);
      expect(data.slowestCalls, isEmpty);
      expect(data.endpointStats, isEmpty);
      expect(data.hasHighErrorRate, isFalse);
    });

    test('computes metrics, slowest calls, and endpoint aggregation', () {
      final call1 = AliceHttpCall(1)
        ..method = 'GET'
        ..endpoint = '/users'
        ..server = 'api.com'
        ..duration = 300
        ..loading = false
        ..secure = true
        ..request = (AliceHttpRequest()..size = 100)
        ..response = (AliceHttpResponse()
          ..status = 200
          ..size = 2048);

      final call2 = AliceHttpCall(2)
        ..method = 'GET'
        ..endpoint = '/users'
        ..server = 'api.com'
        ..duration = 2500 // Slow request (>2000ms)
        ..loading = false
        ..secure = false // Unsecured
        ..request = (AliceHttpRequest()..size = 100)
        ..response = (AliceHttpResponse()
          ..status = 500 // Server error
          ..size = 512);

      final call3 = AliceHttpCall(3)
        ..method = 'GET'
        ..endpoint = '/users'
        ..server = 'api.com'
        ..duration = 200
        ..loading = false
        ..secure = true
        ..request = (AliceHttpRequest()..size = 100)
        ..response = (AliceHttpResponse()
          ..status = 200
          ..size = 1024);

      final call4 = AliceHttpCall(4)
        ..method = 'POST'
        ..endpoint = '/login'
        ..server = 'api.com'
        ..duration = 150
        ..loading = false
        ..secure = true
        ..request = (AliceHttpRequest()..size = 500)
        ..response = (AliceHttpResponse()
          ..status = 200
          ..size = 300);

      final data = AliceStatsData.compute([call1, call2, call3, call4]);

      // Totals
      expect(data.totalRequests, 4);
      expect(data.successRequests, 3);
      expect(data.errorRequests, 1);
      expect(data.errorRate, 25.0); // 1/4 = 25%
      expect(data.hasHighErrorRate, isTrue); // > 10%
      expect(data.hasUnsecuredRequests, isTrue); // call2 is unsecured
      expect(data.hasSlowRequests, isTrue); // call2 duration 2500ms

      // Slowest calls sorted descending
      expect(data.slowestCalls.first.id, 2);
      expect(data.slowestCalls.first.duration, 2500);

      // Endpoint stats
      expect(data.endpointStats.length, 2); // GET /users and POST /login
      final usersEp =
          data.endpointStats.firstWhere((e) => e.endpoint == '/users');
      expect(usersEp.count, 3);
      expect(usersEp.isDuplicateWarning, isTrue); // count >= 3
      expect(usersEp.errorCount, 1);
      expect(usersEp.avgDuration, (300 + 2500 + 200) ~/ 3);
    });
  });

  group('AliceStatsScreen', () {
    testWidgets('renders 3 tabs and switches between them', (tester) async {
      final core = AliceCore();
      final navKey = GlobalKey<NavigatorState>();
      core.setNavigatorKey(navKey);

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navKey,
          home: AliceStatsScreen(core),
        ),
      );

      // Verify tabs exist
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Endpoints'), findsOneWidget);

      // Tap Endpoints tab
      await tester.tap(find.text('Endpoints'));
      await tester.pumpAndSettle();
      expect(find.text('No endpoints recorded yet'), findsOneWidget);
    });
  });
}
