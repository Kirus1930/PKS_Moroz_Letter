import 'package:flutter/material.dart';
import 'package:flutter_moroz_letter_eremin/pages/create_letter_page.dart';
import 'package:flutter_moroz_letter_eremin/pages/view_letter_page.dart';
import 'package:flutter_moroz_letter_eremin/pages/parent_section.dart';
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
        ),
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
          ),
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () => _showParentSection(context),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/winter_bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.mail, size: 100, color: Colors.white),
                const SizedBox(height: 20),
                const Text(
                  'Напиши письмо Деду Морозу!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                StreamBuilder<Duration>(
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
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _timer.formatDuration(remaining),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.yellow,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _timer.getDeliveryStatus(remaining),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.8),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      );
                    }
                    return const CircularProgressIndicator();
                  },
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text(
                      'Написать письмо',
                      style: TextStyle(fontSize: 18),
                    ),
                    onPressed: () => _createLetter(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.history),
                    label: const Text(
                      'Мои письма',
                      style: TextStyle(fontSize: 18),
                    ),
                    onPressed: () => _viewLetters(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _useDatabase
                      ? '📁 Данные сохраняются в SQLite'
                      : '💾 Данные хранятся в памяти',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
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
