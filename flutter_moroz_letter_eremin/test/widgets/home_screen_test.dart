// test/widgets/home_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_moroz_letter_eremin/screens/home_screen.dart';
import 'package:flutter_moroz_letter_eremin/services/letter_service.dart';

class MockLetterService extends Mock implements LetterService {}

void main() {
  late MockLetterService mockLetterService;

  setUp(() {
    mockLetterService = MockLetterService();
  });

  testWidgets('HomeScreen shows all main buttons', (WidgetTester tester) async {
    // Настраиваем мок, чтобы возвращал false (нет письма)
    when(mockLetterService.hasLetter()).thenAnswer((_) async => false);

    await tester.pumpWidget(MaterialApp(home: HomeScreen()));

    // Проверяем наличие заголовка
    expect(find.text('Письмо Деду Морозу'), findsOneWidget);

    // Проверяем наличие всех кнопок
    expect(find.text('Написать письмо'), findsOneWidget);
    expect(find.text('Отследить доставку'), findsOneWidget);
    expect(find.text('Ответ от Деда Мороза'), findsOneWidget);
    expect(find.text('Для родителей'), findsOneWidget);
  });

  testWidgets('New Year timer shows correct time', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: HomeScreen()));

    // Проверяем наличие таймера
    expect(find.text('До Нового Года осталось:'), findsOneWidget);

    // Проверяем, что отображаются дни, часы и минуты
    expect(find.textContaining('дней'), findsOneWidget);
    expect(find.textContaining('часов'), findsOneWidget);
    expect(find.textContaining('минут'), findsOneWidget);
  });

  testWidgets('Navigate to CreateLetterScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(),
        routes: {
          '/create-letter': (context) => Scaffold(
            appBar: AppBar(title: Text('Создание письма')),
            body: Container(),
          ),
        },
      ),
    );

    // Нажимаем кнопку "Написать письмо"
    await tester.tap(find.text('Написать письмо'));
    await tester.pumpAndSettle();

    // Проверяем, что перешли на экран создания письма
    expect(find.text('Создание письма'), findsOneWidget);
  });
}
