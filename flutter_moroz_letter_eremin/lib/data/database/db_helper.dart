import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static const _dbName = 'santa_letters.db';
  static const _dbVersion = 2; // Версия 2 добавляет колонку is_favorite

  static Database? _db;
  static bool _isInitialized = false;

  // Таблицы
  static const lettersTable = 'letters';
  static const wishesTable = 'wishes';

  static Future<Database> get database async {
    if (_db != null) return _db!;

    try {
      _db = await _initDatabase();
      return _db!;
    } catch (e) {
      // Если не удалось инициализировать SQLite, работаем без БД
      print('Не удалось инициализировать БД: $e');
      _isInitialized = false;
      throw Exception('БД недоступна');
    }
  }

  static Future<bool> get isAvailable async {
    if (!_isInitialized) {
      try {
        await database;
        _isInitialized = true;
      } catch (_) {
        return false;
      }
    }
    return true;
  }

  static Future<Database> _initDatabase() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(docsDir.path, _dbName);

    return await openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async {
        // Включаем поддержку внешних ключей
        await db.execute('PRAGMA foreign_keys = ON;');
      },
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Таблица писем
    await db.execute('''
      CREATE TABLE $lettersTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        child_name TEXT NOT NULL,
        age INTEGER NOT NULL,
        story TEXT NOT NULL,
        drawing_path TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        is_sent INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_letters_created_at 
      ON $lettersTable(created_at DESC)
    ''');

    await db.execute('''
      CREATE INDEX idx_letters_favorite 
      ON $lettersTable(is_favorite)
    ''');

    // Таблица желаний
    await db.execute('''
      CREATE TABLE $wishesTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        letter_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        FOREIGN KEY(letter_id) REFERENCES $lettersTable(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_wishes_letter_id 
      ON $wishesTable(letter_id)
    ''');
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    for (var version = oldVersion + 1; version <= newVersion; version++) {
      switch (version) {
        case 2:
          // Добавляем колонку is_favorite
          await db.execute('''
            ALTER TABLE $lettersTable 
            ADD COLUMN is_favorite INTEGER NOT NULL DEFAULT 0
          ''');
          await db.execute('''
            CREATE INDEX idx_letters_favorite 
            ON $lettersTable(is_favorite)
          ''');
          break;
        // Добавьте другие миграции здесь
      }
    }
  }

  static Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
      _isInitialized = false;
    }
  }

  // Метод для отладки: получить путь к файлу БД
  static Future<String> getDatabasePath() async {
    final docsDir = await getApplicationDocumentsDirectory();
    return p.join(docsDir.path, _dbName);
  }
}
