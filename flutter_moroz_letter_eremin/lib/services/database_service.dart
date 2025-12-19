import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/letter.dart';

class DatabaseService {
  static const String _dbName = 'letters.db';
  static const int _dbVersion = 1;
  static Database? _database;

  static Future<void> init() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final dbPath = p.join(documentsDirectory.path, _dbName);

    _database = await openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('use_database', true);
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE letters(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        child_name TEXT NOT NULL,
        age INTEGER NOT NULL,
        story TEXT NOT NULL,
        wishes TEXT NOT NULL,
        drawing_path TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        is_sent INTEGER NOT NULL DEFAULT 0,
        has_response INTEGER NOT NULL DEFAULT 0,
        response_text TEXT,
        response_date INTEGER
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_letters_created_at ON letters(created_at DESC)
    ''');
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      // Миграции для будущих версий
    }
  }

  static Future<bool> isAvailable() async {
    return _database != null;
  }

  static Future<bool> shouldUseDatabase() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('use_database') ?? true;
  }

  static Future<void> setUseDatabase(bool use) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('use_database', use);
  }

  // CRUD операции
  static Future<int> insertLetter(Letter letter) async {
    if (_database == null) throw Exception('Database not initialized');
    return await _database!.insert('letters', letter.toMap());
  }

  static Future<List<Letter>> getAllLetters() async {
    if (_database == null) throw Exception('Database not initialized');
    final List<Map<String, dynamic>> maps = await _database!.query(
      'letters',
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Letter.fromMap(map)).toList();
  }

  static Future<int> updateLetter(Letter letter) async {
    if (_database == null) throw Exception('Database not initialized');
    return await _database!.update(
      'letters',
      letter.toMap(),
      where: 'id = ?',
      whereArgs: [letter.id],
    );
  }

  static Future<int> deleteLetter(int id) async {
    if (_database == null) throw Exception('Database not initialized');
    return await _database!.delete('letters', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
