import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:math_quiz_app/screens/settings_screen.dart';
import 'package:math_quiz_app/services/settings_service.dart';

/// SettingsScreen pops itself on Save, same as real usage (pushed from
/// QuizScreen) — so it needs an actual route beneath it, not to be the
/// app's root route.
Future<void> _openSettings(WidgetTester tester, SettingsService settings) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => SettingsScreen(settings: settings)),
              ),
              child: const Text('Open settings'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.tap(find.text('Open settings'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('turning on a custom limit and saving persists it to the service', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final settings = SettingsService();
    await settings.load();

    await _openSettings(tester, settings);

    expect(find.byType(Slider), findsNothing, reason: 'slider hidden until the switch is on');

    await tester.tap(find.byType(SwitchListTile));
    await tester.pump();
    expect(find.byType(Slider), findsOneWidget);
    expect(find.text('15 seconds'), findsOneWidget, reason: 'defaults to 15s when first enabled');

    await tester.drag(find.byType(Slider), const Offset(-400, 0));
    await tester.pump();

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(settings.customTimeLimitSeconds, isNotNull);
    expect(settings.customTimeLimitSeconds! < 15, isTrue,
        reason: 'dragged left, so it should be lower than the 15s default');
  });

  testWidgets('leaving the switch off and saving clears any existing override', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final settings = SettingsService();
    await settings.setCustomTimeLimit(40);

    await _openSettings(tester, settings);

    expect(find.text('40 seconds'), findsOneWidget, reason: 'shows the existing override on open');

    await tester.tap(find.byType(SwitchListTile));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(settings.customTimeLimitSeconds, isNull);
  });
}
