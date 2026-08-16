import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:math_quiz_app/main.dart';

void main() {
  testWidgets('shows the login screen on a fresh install', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MathQuizApp());
    await tester.pumpAndSettle();

    expect(find.text('Log in'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Username'), findsOneWidget);
  });
}
