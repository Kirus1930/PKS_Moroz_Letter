import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_moroz_letter_eremin/data/models/letter.dart';
import 'package:flutter_moroz_letter_eremin/data/models/wish.dart';
import 'package:flutter_moroz_letter_eremin/data/repository/letter_repository_sqlite.dart';

@GenerateMocks([LetterDao])
void main() {
  late LetterRepositorySqlite repository;
  late MockLetterDao mockDao;

  setUp(() {
    repository = LetterRepositorySqlite();
    // Здесь нужно настроить моки для DAO
  });

  test('Создание письма без БД', () async {
    final letter = Letter(
      childName: 'Тестовый ребенок',
      age: 8,
      story: 'Тестовая история',
      wishes: [Wish(letterId: 0, title: 'Тестовый подарок', category: 'Тест')],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Принудительно переводим в режим мока
    repository._useMock = true;

    final id = await repository.createLetter(letter);
    expect(id, greaterThan(0));
  });

  test('Получение всех писем', () async {
    repository._useMock = true;

    final letters = await repository.getAllLetters();
    expect(letters, isNotEmpty);
  });

  test('Поиск писем', () async {
    repository._useMock = true;

    // Сначала создаем тестовое письмо
    final letter = Letter(
      childName: 'Иван',
      age: 6,
      story: 'Люблю играть в снежки',
      wishes: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await repository.createLetter(letter);

    // Ищем письмо
    final results = await repository.searchLetters('Иван');
    expect(results, isNotEmpty);
    expect(results[0].childName, contains('Иван'));
  });

  test('Обновление письма', () async {
    repository._useMock = true;

    // Создаем письмо
    final letter = Letter(
      childName: 'Оригинальное имя',
      age: 7,
      story: 'Оригинальная история',
      wishes: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final id = await repository.createLetter(letter);

    // Обновляем
    final updatedLetter = letter.copyWith(id: id, childName: 'Обновленное имя');

    final result = await repository.updateLetter(updatedLetter);
    expect(result, equals(1));

    // Проверяем обновление
    final retrieved = await repository.getLetterById(id);
    expect(retrieved?.childName, equals('Обновленное имя'));
  });

  test('Удаление письма', () async {
    repository._useMock = true;

    // Создаем письмо
    final letter = Letter(
      childName: 'Для удаления',
      age: 5,
      story: 'Тест удаления',
      wishes: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final id = await repository.createLetter(letter);

    // Проверяем, что письмо создано
    var allLetters = await repository.getAllLetters();
    var initialCount = allLetters.length;

    // Удаляем
    final result = await repository.deleteLetter(id);
    expect(result, equals(1));

    // Проверяем удаление
    allLetters = await repository.getAllLetters();
    expect(allLetters.length, equals(initialCount - 1));
  });
}

// Интеграционные тесты с реальной БД
void integrationTests() {
  testWidgets('Интеграционный тест: создание и чтение письма', (
    WidgetTester tester,
  ) async {
    // Создаем временную БД в памяти
    TestWidgetsFlutterBinding.ensureInitialized();

    final repository = LetterRepositorySqlite();

    // Создаем тестовое письмо
    final testLetter = Letter(
      childName: 'Интеграционный тест',
      age: 9,
      story: 'Тестируем интеграцию с БД',
      wishes: [
        Wish(letterId: 0, title: 'Интеграционный подарок', category: 'Тест'),
      ],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Сохраняем в БД
    final id = await repository.createLetter(testLetter);
    expect(id, greaterThan(0));

    // Читаем из БД
    final letters = await repository.getAllLetters();
    expect(letters, isNotEmpty);

    final savedLetter = letters.firstWhere((l) => l.id == id);
    expect(savedLetter.childName, equals('Интеграционный тест'));
    expect(savedLetter.wishes.length, equals(1));
    expect(savedLetter.wishes[0].title, equals('Интеграционный подарок'));
  });
}
