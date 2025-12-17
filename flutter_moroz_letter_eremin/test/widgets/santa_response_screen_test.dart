// test/widgets/santa_response_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_moroz_letter_eremin/screens/santa_response_screen.dart';
import 'package:flutter_moroz_letter_eremin/services/letter_service.dart';
import 'package:flutter_moroz_letter_eremin/models/letter_model.dart';

class MockLetterService extends Mock implements LetterService {}

void main() {
  late MockLetterService mockLetterService;

  setUp(() {
    mockLetterService = MockLetterService();
  });

  testWidgets('SantaResponseScreen shows loading initially', (
    WidgetTester tester,
  ) async {
    // Настраиваем мок, чтобы возвращал null (имитируем загрузку)
    when(mockLetterService.getLetter()).thenAnswer((_) async => null);

    await tester.pumpWidget(MaterialApp(home: SantaResponseScreen()));

    // Проверяем наличие индикатора загрузки
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('SantaResponseScreen shows letter when loaded', (
    WidgetTester tester,
  ) async {
    final testLetter = Letter(
      id: '1',
      childName: 'Анна',
      age: 7,
      story: 'Я была хорошей',
      moodEmoji: '😊',
      wishes: ['кукла', 'книга'],
      categories: ['Игрушки'],
      createdAt: DateTime.now(),
      isSent: true,
    );

    when(mockLetterService.getLetter()).thenAnswer((_) async => testLetter);

    await tester.pumpWidget(MaterialApp(home: SantaResponseScreen()));

    // Ждем загрузки
    await tester.pumpAndSettle();

    // Проверяем, что отображается ответ
    expect(find.text('ОТ ДЕДА МОРОЗА'), findsOneWidget);
    expect(find.text('Анна'), findsOneWidget);
  });

  testWidgets('Share button is present', (WidgetTester tester) async {
    final testLetter = Letter(
      id: '1',
      childName: 'Максим',
      age: 5,
      story: 'Тест',
      moodEmoji: '⭐',
      wishes: ['машинка'],
      categories: ['Игрушки'],
      createdAt: DateTime.now(),
    );

    when(mockLetterService.getLetter()).thenAnswer((_) async => testLetter);

    await tester.pumpWidget(MaterialApp(home: SantaResponseScreen()));

    await tester.pumpAndSettle();

    // Проверяем наличие кнопки поделиться
    expect(find.byIcon(Icons.share), findsOneWidget);
  });
}
