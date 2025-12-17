// test/services/letter_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_moroz_letter_eremin/services/letter_service.dart';
import 'package:flutter_moroz_letter_eremin/models/letter_model.dart';

// Генерируем моки
@GenerateMocks([Box, FirebaseFirestore, DocumentReference, CollectionReference])
import 'letter_service_test.mocks.dart';

void main() {
  late MockBox<Letter> mockBox;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockCollection;
  late MockDocumentReference mockDocument;

  setUp(() {
    mockBox = MockBox<Letter>();
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    mockDocument = MockDocumentReference();

    // Настраиваем моки
    when(mockFirestore.collection('letters')).thenReturn(mockCollection);
    when(mockCollection.doc(any)).thenReturn(mockDocument);
  });

  group('LetterService Tests', () {
    test('Save letter locally', () async {
      final letter = Letter(
        id: 'test-id',
        childName: 'Тестовый ребенок',
        age: 10,
        story: 'Тестовая история',
        moodEmoji: '😊',
        wishes: ['желание 1', 'желание 2'],
        categories: ['Игрушки'],
        createdAt: DateTime.now(),
      );

      // Заменяем реальный Hive.box моком
      LetterService.letterBox = mockBox;

      await LetterService.saveLetter(letter);

      verify(mockBox.put(letter.id, letter)).called(1);
    });

    test('Get letter returns last letter', () async {
      final letters = [
        Letter(
          id: '1',
          childName: 'Первый',
          age: 5,
          story: 'Первый ребенок',
          moodEmoji: '😊',
          wishes: [],
          categories: [],
          createdAt: DateTime.now(),
        ),
        Letter(
          id: '2',
          childName: 'Второй',
          age: 7,
          story: 'Второй ребенок',
          moodEmoji: '🎅',
          wishes: ['подарок'],
          categories: ['Игрушки'],
          createdAt: DateTime.now(),
        ),
      ];

      when(mockBox.values).thenReturn(letters);
      LetterService.letterBox = mockBox;

      final result = await LetterService.getLetter();

      expect(result?.id, equals('2'));
      expect(result?.childName, equals('Второй'));
    });

    test('HasLetter returns correct value', () async {
      // Тест с пустой коробкой
      when(mockBox.isEmpty).thenReturn(true);
      LetterService.letterBox = mockBox;

      expect(await LetterService.hasLetter(), isFalse);

      // Тест с непустой коробкой
      when(mockBox.isEmpty).thenReturn(false);
      expect(await LetterService.hasLetter(), isTrue);
    });
  });
}
