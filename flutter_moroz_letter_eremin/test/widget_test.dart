import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_moroz_letter_eremin/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const LetterApp());

    expect(find.text('Письмо Деду Морозу'), findsOneWidget);
  });
}
