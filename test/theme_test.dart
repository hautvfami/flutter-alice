import 'package:flutter/material.dart';
import 'package:flutter_alice/theme/theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AliceColors', () {
    test('primary colors are correctly defined', () {
      expect(AliceColors.primary, const Color(0xff05c46b));
      expect(AliceColors.primaryDark, const Color(0xff048a4b));
      expect(AliceColors.primaryLight, const Color(0xffe8f8f0));
    });

    test('semantic status colors are properly defined', () {
      expect(AliceColors.success, const Color(0xff05c46b));
      expect(AliceColors.error, const Color(0xffff3f34));
      expect(AliceColors.warning, const Color(0xffffa801));
      expect(AliceColors.info, const Color(0xff0fbcf9));
      expect(AliceColors.grey, const Color(0xff808e9b));
    });

    test('statusBadgeBg creates translucent color with alpha 28', () {
      const color = Color(0xff05c46b);
      final badgeBg = AliceColors.statusBadgeBg(color);
      expect(badgeBg.a, closeTo(28 / 255, 0.01));
    });
  });

  group('AliceTheme', () {
    test('aliceTheme is configured with Material 3 and proper schemes', () {
      expect(aliceTheme.useMaterial3, isTrue);
      expect(aliceTheme.colorScheme.primary, AliceColors.primary);
      expect(aliceTheme.scaffoldBackgroundColor, AliceColors.background);
      expect(aliceTheme.appBarTheme.backgroundColor, AliceColors.primary);
      expect(aliceTheme.dividerTheme.color, AliceColors.divider);
    });
  });

  group('AliceWidgets', () {
    testWidgets('AliceStatusBadge renders text and custom color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AliceStatusBadge(text: '200 OK', color: AliceColors.success),
          ),
        ),
      );

      expect(find.text('200 OK'), findsOneWidget);
    });

    testWidgets('AliceStatusBadge renders progress indicator when loading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AliceStatusBadge(
              text: '0',
              color: AliceColors.grey,
              loading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('AliceButton renders and fires onPressed callback', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AliceButton(
              text: 'Click Me',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Click Me'), findsOneWidget);
      await tester.tap(find.text('Click Me'));
      expect(pressed, isTrue);
    });

    testWidgets('AliceListRow renders name and value properly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AliceListRow(name: 'Method:', value: 'GET'),
          ),
        ),
      );

      expect(find.byType(RichText), findsOneWidget);
    });
  });
}
