import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_moroz_letter_eremin/models/letter_model.dart';

void main() {
  group('Letter Model Tests', () {
    test('Letter fromJson and toJson', () {
      final letter = Letter(
        id: '1',
        childName: 'Анна',
        age: 7,
        story: 'Я хорошо училась',
        moodEmoji: '😊',
        wishes: ['кукла', 'конструктор'],
        categories: ['Игрушки', 'Книги'],
        drawingPath: '/path/to/drawing.png',
        photoPath: '/path/to/photo.jpg',
        createdAt: DateTime(2024, 12, 15),
        isSent: true,
        secretGiftFromParent: 'велосипед',
      );

      final json = letter.toJson();
      final restoredLetter = Letter.fromJson(json);

      expect(restoredLetter.id, equals(letter.id));
      expect(restoredLetter.childName, equals(letter.childName));
      expect(restoredLetter.age, equals(letter.age));
      expect(restoredLetter.story, equals(letter.story));
      expect(restoredLetter.moodEmoji, equals(letter.moodEmoji));
      expect(restoredLetter.wishes, equals(letter.wishes));
      expect(restoredLetter.categories, equals(letter.categories));
      expect(restoredLetter.drawingPath, equals(letter.drawingPath));
      expect(restoredLetter.photoPath, equals(letter.photoPath));
      expect(restoredLetter.isSent, equals(letter.isSent));
      expect(
        restoredLetter.secretGiftFromParent,
        equals(letter.secretGiftFromParent),
      );
    });

    test('Letter with null optional fields', () {
      final letter = Letter(
        id: '2',
        childName: 'Максим',
        age: 5,
        story: 'Я слушался родителей',
        moodEmoji: '⭐',
        wishes: ['машинка'],
        categories: ['Игрушки'],
        createdAt: DateTime(2024, 12, 16),
        isSent: false,
      );

      expect(letter.drawingPath, isNull);
      expect(letter.photoPath, isNull);
      expect(letter.secretGiftFromParent, isNull);
    });

    test('Letter with empty lists', () {
      final letter = Letter(
        id: '3',
        childName: 'София',
        age: 8,
        story: '',
        moodEmoji: '🎄',
        wishes: [],
        categories: [],
        createdAt: DateTime(2024, 12, 17),
      );

      expect(letter.wishes, isEmpty);
      expect(letter.categories, isEmpty);
    });
  });
}
