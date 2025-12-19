import 'package:flutter_moroz_letter_eremin/models/letter.dart';

class MemoryStorageService {
  static final MemoryStorageService _instance =
      MemoryStorageService._internal();
  factory MemoryStorageService() => _instance;
  MemoryStorageService._internal();

  final List<Letter> _letters = [];
  int _nextId = 1;

  Future<int> insertLetter(Letter letter) async {
    final newLetter = letter.copyWith(id: _nextId++);
    _letters.add(newLetter);
    return newLetter.id!;
  }

  Future<List<Letter>> getAllLetters() async {
    return List.from(_letters); // Возвращаем копию
  }

  Future<int> updateLetter(Letter letter) async {
    final index = _letters.indexWhere((l) => l.id == letter.id);
    if (index != -1) {
      _letters[index] = letter;
      return 1;
    }
    return 0;
  }

  Future<int> deleteLetter(int id) async {
    final initialLength = _letters.length;
    _letters.removeWhere((letter) => letter.id == id);
    return initialLength - _letters.length;
  }

  Future<void> clear() async {
    _letters.clear();
    _nextId = 1;
  }

  Future<Letter?> getLetterById(int id) async {
    try {
      return _letters.firstWhere((letter) => letter.id == id);
    } catch (e) {
      return null;
    }
  }
}
