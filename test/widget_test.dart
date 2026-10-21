import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Basic sanity test', (final WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('Personal Finances'),
        ),
      ),
    );

    expect(find.text('Personal Finances'), findsOneWidget);
  });
}
