import '../models/letter.dart';

abstract class LetterRepository {
  Future<bool> isDatabaseAvailable();

  Future<int> createLetter(Letter letter);
  Future<List<Letter>> getAllLetters();
  Future<List<Letter>> getFavoriteLetters();
  Future<Letter?> getLetterById(int id);
  Future<int> updateLetter(Letter letter);
  Future<int> deleteLetter(int id);
  Future<List<Letter>> searchLetters(String query);

  // Метод для работы без БД
  Future<List<Letter>> getMockLetters();
}
