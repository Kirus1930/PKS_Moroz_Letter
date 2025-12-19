import 'letter_repository.dart';
import '../models/letter.dart';
import '../database/db_helper.dart';
import '../database/letter_dao.dart';

class LetterRepositorySqlite implements LetterRepository {
  LetterDao? _dao;
  bool _useMock = false;
  final List<Letter> _mockLetters = [];

  @override
  Future<bool> isDatabaseAvailable() async {
    try {
      return await DBHelper.isAvailable;
    } catch (_) {
      _useMock = true;
      return false;
    }
  }

  Future<LetterDao> _getDao() async {
    if (_dao == null) {
      final db = await DBHelper.database;
      _dao = LetterDao(db);
    }
    return _dao!;
  }

  @override
  Future<int> createLetter(Letter letter) async {
    if (_useMock) {
      final mockId = _mockLetters.length + 1;
      _mockLetters.add(letter.copyWith(id: mockId));
      return mockId;
    }

    try {
      final dao = await _getDao();
      return await dao.insertLetter(letter);
    } catch (e) {
      _useMock = true;
      return await createLetter(letter); // Рекурсивно с моком
    }
  }

  @override
  Future<List<Letter>> getAllLetters() async {
    if (_useMock) {
      return List.from(_mockLetters);
    }

    try {
      final dao = await _getDao();
      return await dao.getAllLetters();
    } catch (e) {
      _useMock = true;
      return getMockLetters();
    }
  }

  @override
  Future<List<Letter>> getFavoriteLetters() async {
    final allLetters = await getAllLetters();
    return allLetters.where((letter) => letter.isFavorite).toList();
  }

  @override
  Future<Letter?> getLetterById(int id) async {
    final allLetters = await getAllLetters();
    return allLetters.firstWhere((letter) => letter.id == id);
  }

  @override
  Future<int> updateLetter(Letter letter) async {
    if (_useMock) {
      final index = _mockLetters.indexWhere((l) => l.id == letter.id);
      if (index != -1) {
        _mockLetters[index] = letter;
        return 1;
      }
      return 0;
    }

    try {
      final dao = await _getDao();
      return await dao.updateLetter(letter);
    } catch (e) {
      _useMock = true;
      return await updateLetter(letter);
    }
  }

  @override
  Future<int> deleteLetter(int id) async {
    if (_useMock) {
      final initialLength = _mockLetters.length;
      _mockLetters.removeWhere((letter) => letter.id == id);
      return initialLength - _mockLetters.length;
    }

    try {
      final dao = await _getDao();
      return await dao.deleteLetter(id);
    } catch (e) {
      _useMock = true;
      return await deleteLetter(id);
    }
  }

  @override
  Future<List<Letter>> searchLetters(String query) async {
    if (_useMock) {
      return _mockLetters.where((letter) {
        return letter.childName.toLowerCase().contains(query.toLowerCase()) ||
            letter.story.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }

    try {
      final dao = await _getDao();
      return await dao.searchLetters(query);
    } catch (e) {
      _useMock = true;
      return searchLetters(query);
    }
  }

  @override
  Future<List<Letter>> getMockLetters() {
    return Future.value([
      Letter(
        id: 1,
        childName: 'Аня',
        age: 7,
        story: 'Я хорошо училась в школе и помогала маме',
        wishes: [
          Wish(letterId: 1, title: 'Кукла', category: 'Игрушки'),
          Wish(letterId: 1, title: 'Книга сказок', category: 'Книги'),
        ],
        createdAt: DateTime.now().subtract(Duration(days: 2)),
        updatedAt: DateTime.now().subtract(Duration(days: 2)),
      ),
      Letter(
        id: 2,
        childName: 'Миша',
        age: 5,
        story: 'Я убирал свои игрушки и слушался родителей',
        wishes: [Wish(letterId: 2, title: 'Конструктор', category: 'Игрушки')],
        createdAt: DateTime.now().subtract(Duration(days: 1)),
        updatedAt: DateTime.now().subtract(Duration(days: 1)),
        isFavorite: true,
      ),
    ]);
  }
}
