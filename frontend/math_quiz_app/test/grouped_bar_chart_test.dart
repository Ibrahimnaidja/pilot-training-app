import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:math_quiz_app/widgets/grouped_bar_chart.dart';

void main() {
  testWidgets('hovering over a bar shows a tooltip with its category, period, and value',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GroupedBarChart(
            categories: ['Alpha', 'Beta'],
            periods: ['Jan', 'Feb', 'Mar'],
            values: [
              [10, 20, 30],
              [15, 25, 35],
            ],
            unitLabel: 'units',
          ),
        ),
      ),
    );
    await tester.pump();

    // One tooltip region per category x period cell.
    expect(find.byType(Tooltip), findsNWidgets(6));

    const expectedMessage = 'Beta, Feb: 25 units';
    final targetFinder = find.byWidgetPredicate((w) => w is Tooltip && w.message == expectedMessage);
    expect(targetFinder, findsOneWidget, reason: 'expected a tooltip region carrying the Beta/Feb/25 value');

    final rect = tester.getRect(targetFinder);
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await tester.pump();

    await gesture.moveTo(rect.center);
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(find.text(expectedMessage), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });
}
