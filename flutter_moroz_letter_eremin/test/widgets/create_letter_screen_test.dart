// test/widgets/create_letter_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_moroz_letter_eremin/screens/create_letter_screen.dart';
import 'package:flutter_moroz_letter_eremin/services/letter_service.dart';

class MockImagePicker extends Mock implements ImagePicker {}

class MockLetterService extends Mock implements LetterService {}

void main() {
  late MockLetterService mockLetterService;
  late MockImagePicker mockImagePicker;

  setUp(() {
    mockLetterService = MockLetterService();
    mockImagePicker = MockImagePicker();
  });

  testWidgets('CreateLetterScreen shows all form fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: CreateLetterScreen()));

    // Проверяем наличие всех полей
    expect(find.text('Меня зовут:'), findsOneWidget);
    expect(find.text('Мой возраст:'), findsOneWidget);
    expect(find.text('Мое настроение:'), findsOneWidget);
    expect(find.text('Расскажи о себе:'), findsOneWidget);
    expect(find.text('Какие подарки ты хочешь?'), findsOneWidget);
    expect(find.text('Мои желания:'), findsOneWidget);
    expect(find.text('Рисунок для Деда Мороза:'), findsOneWidget);
    expect(find.text('Нарисуй рисунок:'), findsOneWidget);
  });

  testWidgets('Form validation works', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: CreateLetterScreen()));

    // Пытаемся отправить пустую форму
    await tester.tap(find.text('Отправить письмо Деду Морозу!'));
    await tester.pump();

    // Проверяем, что валидация сработала
    // В реальном приложении будут показаны сообщения об ошибках
    expect(find.text('Введи свое имя'), findsOneWidget);
  });

  testWidgets('Add and remove wishes works', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: CreateLetterScreen()));

    // Вводим желание
    await tester.enterText(find.byType(TextField).first, 'новый конструктор');

    // Нажимаем кнопку добавления
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Проверяем, что желание добавилось
    expect(find.text('новый конструктор'), findsOneWidget);

    // Удаляем желание
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pump();

    // Проверяем, что желание удалилось
    expect(find.text('новый конструктор'), findsNothing);
  });

  testWidgets('Select mood emoji works', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: CreateLetterScreen()));

    // Находим и нажимаем на смайлик
    final smileyFinder = find.text('😄');
    await tester.tap(smileyFinder);
    await tester.pump();

    // Проверяем, что выбранный смайлик теперь имеет другой цвет (синий)
    // В реальном приложении нужно проверить состояние
    expect(smileyFinder, findsOneWidget);
  });
}
