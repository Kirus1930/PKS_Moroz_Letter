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
