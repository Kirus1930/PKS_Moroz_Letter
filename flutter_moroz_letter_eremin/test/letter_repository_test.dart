import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_moroz_letter_eremin/models/letter.dart';
import 'package:flutter_moroz_letter_eremin/repositories/letter_repository.dart';
import 'package:flutter_moroz_letter_eremin/services/memory_storage_service.dart';

void main() {
  group('Memory Storage Service Tests', () {
    late MemoryStorageService service;

    setUp(() {
      service = MemoryStorageService();
    });

    test('Insert and retrieve letter', () async {
      final letter = Letter(
        childName: 'Аня',
        age: 7,
        story: 'Я была хорошей',
        wishes: ['Кукла', 'Книга'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final id = await service.insertLetter(letter);
      expect(id, 1);

      final letters = await service.getAllLetters();
      expect(letters.length, 1);
      expect(letters[0].childName, 'Аня');
      expect(letters[0].id, 1);
    });

    test('Update letter', () async {
      final letter = Letter(
        childName: 'Иван',
        age: 8,
        story: 'История',
        wishes: ['Машинка'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final id = await service.insertLetter(letter);
      final updatedLetter = letter.copyWith(id: id, childName: 'Иван Петров');

      final result = await service.updateLetter(updatedLetter);
      expect(result, 1);

      final letters = await service.getAllLetters();
      expect(letters[0].childName, 'Иван Петров');
    });

    test('Delete letter', () async {
      final letter = Letter(
        childName: 'Мария',
        age: 6,
        story: 'Тест',
        wishes: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final id = await service.insertLetter(letter);
      final result = await service.deleteLetter(id);
      expect(result, 1);

      final letters = await service.getAllLetters();
      expect(letters.length, 0);
    });

    test('Get letter by id', () async {
      final letter1 = Letter(
        childName: 'Первый',
        age: 5,
        story: 'Первый',
        wishes: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final letter2 = Letter(
        childName: 'Второй',
        age: 6,
        story: 'Второй',
        wishes: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final id1 = await service.insertLetter(letter1);
      await service.insertLetter(letter2);

      final retrieved = await service.getLetterById(id1);
      expect(retrieved?.childName, 'Первый');
    });
  });

  group('Letter Repository Tests', () {
    test('Repository with memory storage', () async {
      final repository = LetterRepositoryImpl(useDatabase: false);

      final letter = Letter(
        childName: 'Тест',
        age: 9,
        story: 'Тестовая история',
        wishes: ['Тестовое желание'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final id = await repository.saveLetter(letter);
      expect(id, 1);

      final letters = await repository.getAllLetters();
      expect(letters.length, 1);
      expect(letters[0].childName, 'Тест');
    });
  });
}
