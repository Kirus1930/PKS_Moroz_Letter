import 'package:flutter/material.dart';
import 'package:flutter_moroz_letter_eremin/pages/create_letter_page.dart';
import 'package:flutter_moroz_letter_eremin/pages/view_letter_page.dart';
import 'package:flutter_moroz_letter_eremin/pages/parent_section.dart';
import 'package:flutter_moroz_letter_eremin/pages/home_page.dart';
import 'package:flutter_moroz_letter_eremin/services/new_year_timer.dart';
import 'package:flutter_moroz_letter_eremin/repositories/letter_repository.dart';
import 'package:flutter_moroz_letter_eremin/services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final NewYearTimer _timer = NewYearTimer();
  late Stream<Duration> _timeStream;
  bool _useDatabase = true;
  late LetterRepository _repository;

  @override
  void initState() {
    super.initState();
    _timer.start();
    _timeStream = _timer.timeRemainingStream;
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _useDatabase = prefs.getBool('use_database') ?? true;
      _repository = LetterRepositoryImpl(useDatabase: _useDatabase);
    });
  }

  Future<void> _toggleDatabase() async {
    setState(() {
      _useDatabase = !_useDatabase;
    });
    await DatabaseService.setUseDatabase(_useDatabase);
    _repository = LetterRepositoryImpl(useDatabase: _useDatabase);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _useDatabase ? 'База данных подключена' : 'Режим без базы данных',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.accentColor,
      ),
    );
  }

  @override
  void dispose() {
    _timer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Письмо Деду Морозу'),
        actions: [
          IconButton(
            icon: Icon(_useDatabase ? Icons.storage : Icons.memory),
            onPressed: _toggleDatabase,
            tooltip: _useDatabase ? 'Использовать БД' : 'Использовать память',
            color: Colors.white,
          ),
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () => _showParentSection(context),
            color: Colors.white,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.lightBlueBackground, Colors.lightBlue[100]!],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.mail,
                    size: 120,
                    color: Color(0xFFFF6B6B),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  'Напиши письмо Деду Морозу!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.blueText,
                    shadows: [
                      Shadow(
                        color: Colors.white.withOpacity(0.8),
                        blurRadius: 2,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: AppTheme.lightRedText.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: StreamBuilder<Duration>(
                    stream: _timeStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final remaining = snapshot.data!;
                        return Column(
                          children: [
                            Text(
                              'До Нового Года осталось:',
                              style: TextStyle(
                                fontSize: 18,
                                color: AppTheme.lightRedText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              _timer.formatDuration(remaining),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accentColor,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              _timer.getDeliveryStatus(remaining),
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.lightRedText,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        );
                      }
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.accentColor,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit, size: 24),
                    label: const Text('Написать письмо'),
                    onPressed: () => _createLetter(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.history, size: 24),
                    label: const Text('Мои письма'),
                    onPressed: () => _viewLetters(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: Colors.blue[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.lightRedText.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    _useDatabase
                        ? '📁 Данные сохраняются в SQLite'
                        : '💾 Данные хранятся в памяти',
                    style: TextStyle(
                      color: AppTheme.lightRedText,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Пусть твои желания сбудутся!',
                  style: TextStyle(
                    color: AppTheme.lightRedText.withOpacity(0.8),
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _createLetter(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateLetterPage(repository: _repository),
      ),
    );
  }

  void _viewLetters(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewLetterPage(repository: _repository),
      ),
    );
  }

  void _showParentSection(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ParentSection()),
    );
  }
}
