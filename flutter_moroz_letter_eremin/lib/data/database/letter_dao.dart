import 'package:sqflite/sqflite.dart';
import '../models/letter.dart';
import '../models/wish.dart';
import 'db_helper.dart';

class LetterDao {
  final Database db;

  LetterDao(this.db);

  Future<int> insertLetter(Letter letter) async {
    final db = await DBHelper.database;

    return await db.transaction((txn) async {
      // Вставляем письмо
      final letterId = await txn.insert(
        DBHelper.lettersTable,
        letter.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      // Вставляем желания
      final batch = txn.batch();
      for (final wish in letter.wishes) {
        final wishMap = wish.toMap()..['letter_id'] = letterId;
        batch.insert(DBHelper.wishesTable, wishMap);
      }
      await batch.commit(noResult: true);

      return letterId;
    });
  }

  Future<List<Letter>> getAllLetters() async {
    final db = await DBHelper.database;
    final lettersMaps = await db.query(
      DBHelper.lettersTable,
      orderBy: 'created_at DESC',
    );

    final letters = <Letter>[];
    for (final letterMap in lettersMaps) {
      final letter = Letter.fromMap(letterMap);
      // Загружаем желания для этого письма
      final wishes = await _getWishesForLetter(letter.id!);
      letters.add(letter.copyWith(wishes: wishes));
    }

    return letters;
  }

  Future<List<Wish>> _getWishesForLetter(int letterId) async {
    final db = await DBHelper.database;
    final wishesMaps = await db.query(
      DBHelper.wishesTable,
      where: 'letter_id = ?',
      whereArgs: [letterId],
    );

    return wishesMaps.map((map) => Wish.fromMap(map)).toList();
  }

  Future<int> updateLetter(Letter letter) async {
    final db = await DBHelper.database;

    return await db.transaction((txn) async {
      // Обновляем письмо
      final result = await txn.update(
        DBHelper.lettersTable,
        letter.toMap(),
        where: 'id = ?',
        whereArgs: [letter.id],
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      // Удаляем старые желания и вставляем новые
      await txn.delete(
        DBHelper.wishesTable,
        where: 'letter_id = ?',
        whereArgs: [letter.id],
      );

      final batch = txn.batch();
      for (final wish in letter.wishes) {
        final wishMap = wish.toMap()..['letter_id'] = letter.id;
        batch.insert(DBHelper.wishesTable, wishMap);
      }
      await batch.commit(noResult: true);

      return result;
    });
  }

  Future<int> deleteLetter(int id) async {
    final db = await DBHelper.database;
    return await db.delete(
      DBHelper.lettersTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Letter>> searchLetters(String query) async {
    final db = await DBHelper.database;
    final lettersMaps = await db.rawQuery(
      '''
      SELECT * FROM ${DBHelper.lettersTable} 
      WHERE child_name LIKE ? OR story LIKE ?
      ORDER BY created_at DESC
    ''',
      ['%$query%', '%$query%'],
    );

    final letters = <Letter>[];
    for (final letterMap in lettersMaps) {
      final letter = Letter.fromMap(letterMap);
      final wishes = await _getWishesForLetter(letter.id!);
      letters.add(letter.copyWith(wishes: wishes));
    }

    return letters;
  }
}
