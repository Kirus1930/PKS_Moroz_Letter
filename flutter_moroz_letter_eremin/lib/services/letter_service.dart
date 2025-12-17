import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/letter_model.dart';

class LetterService {
  static late Box<Letter> _letterBox;
  static late FirebaseFirestore _firestore;
  static const String _boxName = 'letters';

  static Future<void> init() async {
    await Hive.openBox<Letter>(_boxName);
    _letterBox = Hive.box<Letter>(_boxName);
    _firestore = FirebaseFirestore.instance;
  }

  static Future<void> saveLetter(Letter letter) async {
    // Сохраняем локально
    await _letterBox.put(letter.id, letter);
    
    // Сохраняем в Firebase (если есть интернет)
    try {
      await _firestore
          .collection('letters')
          .doc(letter.id)
          .set(letter.toJson());
    } catch (e) {
      print('Ошибка сохранения в Firebase: $e');
    }
  }

  static Future<Letter?> getLetter() async {
    final letters = _letterBox.values.toList();
    return letters.isNotEmpty ? letters.last : null;
  }

  static Future<bool> hasLetter() async {
    return _letterBox.isNotEmpty;
  }

  static Future<void> updateSecretGift(String secretGift) async {
    final letter = await getLetter();
    if (letter != null) {
      final updatedLetter = Letter(
        id: letter.id,
        childName: letter.childName,
        age: letter.age,
        story: letter.story,
        moodEmoji: letter.moodEmoji,
        wishes: letter.wishes,
        categories: letter.categories,
        drawingPath: letter.drawingPath,
        photoPath: letter.photoPath,
        createdAt: letter.createdAt,
        isSent: letter.isSent,
        secretGiftFromParent: secretGift,
      );
      await saveLetter(updatedLetter);
    }
  }

  static Future<void> clearAllData() async {
    await _letterBox.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<List<Letter>> getAllLetters() async {
    return _letterBox.values.toList();
  }
}

// services/parent_auth_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class ParentAuthService {
  static const String _pinKey = 'parent_pin';
  static const String _defaultPin = '1234';

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_pinKey)) {
      await prefs.setString(_pinKey, _defaultPin);
    }
  }

  static Future<bool> isPinSetup() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_pinKey);
  }

  static Future<bool> verifyPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final storedPin = prefs.getString(_pinKey);
    return storedPin == pin;
  }

  static Future<void> setPin(String newPin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, newPin);
  }

  static Future<void> clearPin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinKey);
  }

  static Future<bool> checkAuth() async {
    // В реальном приложении здесь может быть проверка сессии
    return false;
  }
}