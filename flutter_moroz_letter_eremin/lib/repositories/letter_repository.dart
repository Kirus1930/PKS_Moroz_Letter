import 'package:flutter_moroz_letter_eremin/models/letter.dart';
import 'package:flutter_moroz_letter_eremin/services/database_service.dart';
import 'package:flutter_moroz_letter_eremin/services/memory_storage_service.dart';

abstract class LetterRepository {
  Future<int> saveLetter(Letter letter);
  Future<List<Letter>> getAllLetters();
  Future<int> updateLetter(Letter letter);
  Future<int> deleteLetter(int id);
  Future<Letter?> getLetterById(int id);
}

class LetterRepositoryImpl implements LetterRepository {
  final bool useDatabase;

  LetterRepositoryImpl({required this.useDatabase});

  @override
  Future<int> saveLetter(Letter letter) async {
    if (useDatabase && await DatabaseService.isAvailable()) {
      return await DatabaseService.insertLetter(letter);
    } else {
      return await MemoryStorageService().insertLetter(letter);
    }
  }

  @override
  Future<List<Letter>> getAllLetters() async {
    if (useDatabase && await DatabaseService.isAvailable()) {
      return await DatabaseService.getAllLetters();
    } else {
      return await MemoryStorageService().getAllLetters();
    }
  }

  @override
  Future<int> updateLetter(Letter letter) async {
    if (useDatabase && await DatabaseService.isAvailable()) {
      return await DatabaseService.updateLetter(letter);
    } else {
      return await MemoryStorageService().updateLetter(letter);
    }
  }

  @override
  Future<int> deleteLetter(int id) async {
    if (useDatabase && await DatabaseService.isAvailable()) {
      return await DatabaseService.deleteLetter(id);
    } else {
      return await MemoryStorageService().deleteLetter(id);
    }
  }

  @override
  Future<Letter?> getLetterById(int id) async {
    if (useDatabase && await DatabaseService.isAvailable()) {
      final letters = await DatabaseService.getAllLetters();
      return letters.firstWhere((letter) => letter.id == id);
    } else {
      return await MemoryStorageService().getLetterById(id);
    }
  }
}
