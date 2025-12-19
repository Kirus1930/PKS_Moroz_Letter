import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_moroz_letter_eremin/pages/home_page.dart';
import 'package:flutter_moroz_letter_eremin/services/database_service.dart';
import 'package:flutter_moroz_letter_eremin/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Инициализация БД (по желанию пользователя)
  final useDatabase = await DatabaseService.shouldUseDatabase();
  if (useDatabase) {
    await DatabaseService.init();
  }

  runApp(const LetterApp());
}

class LetterApp extends StatelessWidget {
  const LetterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Письмо Деду Морозу',
      theme: AppTheme.winterTheme,
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}
