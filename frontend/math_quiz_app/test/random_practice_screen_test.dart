import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:math_quiz_app/screens/random_practice_screen.dart';
import 'package:math_quiz_app/services/settings_service.dart';

/// Reads the current problem's expression and returns the correct answer.
int _correctAnswerFor(WidgetTester tester) {
  final expression = tester.widget<Text>(find.textContaining(' = ?')).data!;
  final body = expression.substring(0, expression.length - ' = ?'.length);
  final isSubtraction = body.contains('−');
  final parts = body.split(isSubtraction ? '−' : '+').map((p) => int.parse(p.trim())).toList();
  return isSubtraction ? parts[0] - parts[1] : parts[0] + parts[1];
}

const _lengthPresets = [5, 10, 20, 50];

Future<void> _startSequence(WidgetTester tester, {int length = 5}) async {
  // Never calls .load(), so customTimeLimitSeconds stays null and the
  // screen falls back to its own 5s default — exactly what these tests assert on.
  await tester.pumpWidget(MaterialApp(home: RandomPracticeScreen(settings: SettingsService())));
  await tester.pump();

  if (_lengthPresets.contains(length)) {
    await tester.tap(find.widgetWithText(ChoiceChip, '$length'));
  } else {
    await tester.tap(find.widgetWithText(ChoiceChip, 'Custom'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), '$length');
  }
  await tester.pump();
  await tester.tap(find.widgetWithText(FilledButton, 'Start'));
  await tester.pump();
}

void main() {
  testWidgets(
      'answering with Enter instantly advances without revealing whether it was correct',
      (WidgetTester tester) async {
    await _startSequence(tester, length: 5);

    expect(find.text('Question 1 of 5'), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus, isTrue,
        reason: 'answer field should be focused without clicking it');

    final answer = _correctAnswerFor(tester);
    await tester.enterText(find.byType(TextField), '$answer');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    // Moved on immediately — no separate "Next" step, and no correct/incorrect reveal.
    expect(find.text('Question 2 of 5'), findsOneWidget);
    expect(find.textContaining('Correct'), findsNothing);
    expect(find.textContaining('Not quite'), findsNothing);
    expect(tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus, isTrue,
        reason: 'focus should return to the field for the next question automatically');

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a wrong answer also advances silently, with no reveal until the summary',
      (WidgetTester tester) async {
    await _startSequence(tester, length: 5);

    await tester.enterText(find.byType(TextField), '-9999');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(find.text('Question 2 of 5'), findsOneWidget);
    expect(find.textContaining('Correct'), findsNothing);
    expect(find.textContaining('Not quite'), findsNothing);
    expect(find.textContaining('wrong'), findsNothing);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('finishes a sequence and shows score, accuracy, and average response time',
      (WidgetTester tester) async {
    await _startSequence(tester, length: 3);

    for (var i = 0; i < 3; i++) {
      final answer = _correctAnswerFor(tester);
      await tester.enterText(find.byType(TextField), '$answer');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
    }

    expect(find.text('Sequence complete'), findsOneWidget);
    expect(find.text('3 / 3'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    expect(find.textContaining('s'), findsWidgets); // avg-time stat block
    expect(find.text('Perfect score — every answer was correct.'), findsOneWidget);
  });

  testWidgets('lets you review which questions were answered wrong', (WidgetTester tester) async {
    await _startSequence(tester, length: 1);

    await tester.enterText(find.byType(TextField), '-9999');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(find.text('Sequence complete'), findsOneWidget);
    expect(find.text('0 / 1'), findsOneWidget);
    expect(find.text('Questions you missed (1)'), findsOneWidget);
    expect(find.textContaining('You answered -9999'), findsOneWidget);
  });

  testWidgets('a timeout also advances automatically and is reflected in the summary',
      (WidgetTester tester) async {
    await _startSequence(tester, length: 1);

    await tester.pump(const Duration(seconds: 5));
    await tester.pump();

    expect(find.text('Sequence complete'), findsOneWidget);
    expect(find.text('0 / 1'), findsOneWidget);
    expect(find.text('Questions you missed (1)'), findsOneWidget);
    expect(find.textContaining('Timed out'), findsOneWidget);
  });

  testWidgets('rejects a non-numeric answer without advancing', (WidgetTester tester) async {
    await _startSequence(tester, length: 5);

    await tester.enterText(find.byType(TextField), 'abc');
    await tester.tap(find.widgetWithText(FilledButton, 'Check'));
    await tester.pump();

    expect(find.text('Enter a whole number'), findsOneWidget);
    expect(find.text('Question 1 of 5'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a custom time limit from settings overrides the 5s default', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final settings = SettingsService();
    await settings.setCustomTimeLimit(17);

    await tester.pumpWidget(MaterialApp(home: RandomPracticeScreen(settings: settings)));
    await tester.pump();
    await tester.tap(find.widgetWithText(ChoiceChip, '5'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Start'));
    await tester.pump();

    expect(find.text('17 s left'), findsOneWidget);
    expect(find.text('5 s left'), findsNothing);

    await tester.pumpWidget(const SizedBox());
  });
}
