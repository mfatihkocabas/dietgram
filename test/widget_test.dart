// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:diyetgram/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DiyetgramApp());

    // Verify that our counter starts at 0.
    expect(find.text('Diyetgram'), findsOneWidget);
    expect(find.text('A minimalist approach to diet tracking'), findsOneWidget);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.text('Start Your Journey'));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('Good Morning!'), findsOneWidget);
  });
} 