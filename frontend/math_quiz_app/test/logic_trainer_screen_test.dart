import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:math_quiz_app/screens/logic_trainer_screen.dart';
import 'package:math_quiz_app/services/api_client.dart';
import 'package:math_quiz_app/services/settings_service.dart';
import 'package:math_quiz_app/widgets/data_table_grid.dart';
import 'package:math_quiz_app/widgets/grouped_bar_chart.dart';
import 'package:math_quiz_app/widgets/shape_diagram.dart';

/// Never calls .load(), so customTimeLimitSeconds stays null and every
/// screen falls back to its own per-category default — exactly what these
/// tests assert on.
LogicTrainerScreen _screen() =>
    LogicTrainerScreen(api: ApiClient(baseUrl: 'http://127.0.0.1:1'), settings: SettingsService());

/// The screen calls the backend to record attempts and load stats; in these
/// tests there's no live server, so those calls fail and are caught (the
/// screen is written to keep working locally either way) — this exercises
/// exactly that resilience along with the on-device generation/UI/timer logic.
Future<void> _selectCategory(WidgetTester tester, String label) async {
  await tester.tap(find.byKey(const Key('logic-category-dropdown')));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
}

void main() {
  testWidgets('number sequence: a wrong answer shows feedback and still advances',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: _screen()));
    await tester.pump();
    await _selectCategory(tester, 'Number sequences');

    expect(find.text('20 s left'), findsOneWidget);
    expect(find.textContaining(', ?'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '-999999');
    await _tapVisible(tester, find.widgetWithText(FilledButton, 'Check'));
    await tester.pump();

    expect(find.textContaining('Not quite'), findsOneWidget);

    await _tapVisible(tester, find.widgetWithText(FilledButton, 'Next'));
    await tester.pump();

    expect(find.text('20 s left'), findsOneWidget);
    expect(find.textContaining('Not quite'), findsNothing);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('verbal reasoning: renders tappable options and completes a Check/Next round',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: _screen()));
    await tester.pump();
    await _selectCategory(tester, 'Verbal reasoning');

    expect(find.text('30 s left'), findsOneWidget);
    final optionButtons = find.byWidgetPredicate((w) => w is InkWell);
    expect(optionButtons, findsWidgets);

    await _tapVisible(tester, optionButtons.first);
    await tester.pump();
    await _tapVisible(tester, find.widgetWithText(FilledButton, 'Check'));
    await tester.pump();

    expect(find.textContaining('Correct!').evaluate().isNotEmpty || find.text('Not quite.').evaluate().isNotEmpty,
        isTrue);

    await _tapVisible(tester, find.widgetWithText(FilledButton, 'Next'));
    await tester.pump();
    expect(find.text('30 s left'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('choosing no option and pressing Check shows an inline error', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: _screen()));
    await tester.pump();
    await _selectCategory(tester, 'Verbal reasoning');

    await _tapVisible(tester, find.widgetWithText(FilledButton, 'Check'));
    await tester.pump();

    expect(find.text('Choose an option first'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('diagrammatic reasoning: renders example frames and shape options',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: _screen()));
    await tester.pump();
    await _selectCategory(tester, 'Diagrammatic reasoning');

    expect(find.text('45 s left'), findsOneWidget);
    expect(find.byType(ShapeDiagram), findsWidgets);

    final optionButtons = find.byWidgetPredicate((w) => w is InkWell);
    await _tapVisible(tester, optionButtons.first);
    await tester.pump();
    await _tapVisible(tester, find.widgetWithText(FilledButton, 'Check'));
    await tester.pump();

    expect(find.widgetWithText(FilledButton, 'Next'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('data interpretation: renders a chart or a table (either presentation style) and completes a round',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: _screen()));
    await tester.pump();
    await _selectCategory(tester, 'Data interpretation');

    expect(find.text('45 s left'), findsOneWidget);
    final isChart = find.byType(GroupedBarChart).evaluate().isNotEmpty;
    final isTable = find.byType(DataTableGrid).evaluate().isNotEmpty;
    expect(isChart || isTable, isTrue, reason: 'expected either the chart or the table widget to render');
    expect(isChart && isTable, isFalse, reason: 'only one presentation style should render at a time');

    final optionButtons = find.byWidgetPredicate((w) => w is InkWell);
    await _tapVisible(tester, optionButtons.first);
    await tester.pump();
    await _tapVisible(tester, find.widgetWithText(FilledButton, 'Check'));
    await tester.pump();

    expect(find.widgetWithText(FilledButton, 'Next'), findsOneWidget);
    expect(find.textContaining('Correct!').evaluate().isNotEmpty || find.text('Not quite.').evaluate().isNotEmpty,
        isTrue);

    await _tapVisible(tester, find.widgetWithText(FilledButton, 'Next'));
    await tester.pump();
    expect(find.text('45 s left'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('switching category mid-session loads a fresh puzzle with that timing',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: _screen()));
    await tester.pump();

    await _selectCategory(tester, 'Number sequences');
    expect(find.text('20 s left'), findsOneWidget);

    await _selectCategory(tester, 'Diagrammatic reasoning');
    expect(find.text('45 s left'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a custom time limit from settings overrides every category\'s own default',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final settings = SettingsService();
    await settings.setCustomTimeLimit(12);

    await tester.pumpWidget(
      MaterialApp(home: LogicTrainerScreen(api: ApiClient(baseUrl: 'http://127.0.0.1:1'), settings: settings)),
    );
    await tester.pump();

    await _selectCategory(tester, 'Number sequences');
    expect(find.text('12 s left'), findsOneWidget);
    expect(find.text('20 s left'), findsNothing);

    await _selectCategory(tester, 'Diagrammatic reasoning');
    expect(find.text('12 s left'), findsOneWidget);
    expect(find.text('45 s left'), findsNothing);

    await tester.pumpWidget(const SizedBox());
  });
}
