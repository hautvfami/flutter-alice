import 'package:flutter/material.dart';
import 'package:flutter_alice/core/alice_inspector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExpandableFab', () {
    testWidgets('renders bigButton and opens on long press', (tester) async {
      bool openState = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpandableFab(
              distance: 80.0,
              onOpenChanged: (val) => openState = val,
              bigButton: const Text('FAB'),
              children: [
                ActionButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('FAB'), findsOneWidget);
      expect(openState, isFalse);

      // Long press triggers toggle
      await tester.longPress(find.text('FAB'));
      await tester.pumpAndSettle();

      expect(openState, isTrue);
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('ActionButton triggers onPressed callback', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpandableFab(
              distance: 80.0,
              initialOpen: true,
              bigButton: const Text('FAB'),
              children: [
                ActionButton(
                  icon: const Icon(Icons.star),
                  onPressed: () => pressed = true,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star), findsOneWidget);
      await tester.tap(find.byIcon(Icons.star));
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
    });
  });

  group('AliceInspector', () {
    testWidgets('renders child and floating inspector button', (tester) async {
      final navKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        AliceInspector(
          navigatorKey: navKey,
          child: MaterialApp(
            navigatorKey: navKey,
            home: const Scaffold(
              body: Text('App Content'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('App Content'), findsOneWidget);
      expect(find.byType(ExpandableFab), findsOneWidget);
    });
  });
}
