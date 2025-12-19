import 'package:flutter/material.dart';

class AppTheme {
  // Основные цвета
  static final Color lightBlueBackground = Colors.lightBlue[50]!;
  static final Color lightRedText = Color(0xFFFF8A8A); // Светло-красный
  static final Color blueText = Colors.blue[800]!;
  static final Color accentColor = Color(
    0xFFFF6B6B,
  ); // Яркий красный для акцентов

  static final ThemeData winterTheme = ThemeData(
    // Основные цвета
    primarySwatch: Colors.blue,
    primaryColor: Colors.blue[800],
    hintColor: accentColor,
    scaffoldBackgroundColor: lightBlueBackground, // Светло-голубой фон
    // Шрифты
    fontFamily: 'Roboto',

    // Текстовая тема
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: blueText, // Темно-синий для заголовков
      ),
      displayMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: blueText,
      ),
      displaySmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: blueText,
      ),
      bodyLarge: TextStyle(
        fontSize: 18,
        color: lightRedText, // Светло-красный для основного текста
      ),
      bodyMedium: TextStyle(fontSize: 16, color: lightRedText),
      bodySmall: TextStyle(fontSize: 14, color: lightRedText),
      labelLarge: TextStyle(
        fontSize: 16,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),

    // Кнопки
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: accentColor, // Красные кнопки
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    ),

    // Поля ввода
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: lightRedText.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: lightRedText, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: lightRedText.withOpacity(0.5)),
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.9),
      labelStyle: TextStyle(color: lightRedText, fontSize: 16),
      hintStyle: TextStyle(color: lightRedText.withOpacity(0.7)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),

    // Карточки
    cardTheme: CardThemeData(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white.withOpacity(0.95),
      surfaceTintColor: Colors.transparent,
      margin: const EdgeInsets.all(8),
    ),

    // Аппбар
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue[800],
      foregroundColor: Colors.white,
      elevation: 4,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),

    // Плавающая кнопка действия
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accentColor,
      foregroundColor: Colors.white,
      elevation: 6,
    ),

    // Иконки
    iconTheme: IconThemeData(color: blueText, size: 24),

    // Диалоги
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
    ),

    // ЛистТайлы
    listTileTheme: ListTileThemeData(
      tileColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
  );
}
