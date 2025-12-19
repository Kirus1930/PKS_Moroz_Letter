import 'package:flutter/material.dart';
import 'data/repository/letter_repository_sqlite.dart';
import 'features/letter/letter_list_screen.dart';
import 'theme/app_theme.dart';

class SantaLetterApp extends StatelessWidget {
  final LetterRepositorySqlite repository;

  const SantaLetterApp({super.key}) : repository = LetterRepositorySqlite();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Письмо Деду Морозу',
      theme: AppTheme.winterTheme,
      home: FutureBuilder<bool>(
        future: repository.isDatabaseAvailable(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final isDbAvailable = snapshot.data ?? false;

          return LetterListScreen(
            repository: repository,
            isDatabaseAvailable: isDbAvailable,
          );
        },
      ),
    );
  }
}
