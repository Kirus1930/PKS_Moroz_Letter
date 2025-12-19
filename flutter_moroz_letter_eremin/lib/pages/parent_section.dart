import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_moroz_letter_eremin/models/letter.dart';
import 'package:flutter_moroz_letter_eremin/repositories/letter_repository.dart';
import 'package:flutter_moroz_letter_eremin/services/database_service.dart';
import 'package:flutter_moroz_letter_eremin/services/response_generator.dart';
import 'package:intl/intl.dart';

class ParentSection extends StatefulWidget {
  const ParentSection({super.key});

  @override
  State<ParentSection> createState() => _ParentSectionState();
}

class _ParentSectionState extends State<ParentSection> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _secretGiftController = TextEditingController();
  bool _isAuthenticated = false;
  String _errorMessage = '';
  List<Letter> _letters = [];
  late LetterRepository _repository;
  final String _correctPin = '1234'; // Простой PIN для демонстрации
  bool _isLoading = false;
  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _initRepository();
  }

  Future<void> _initRepository() async {
    final useDatabase = await DatabaseService.shouldUseDatabase();
    setState(() {
      _repository = LetterRepositoryImpl(useDatabase: useDatabase);
    });
  }

  Future<void> _loadLetters() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final letters = await _repository.getAllLetters();
      setState(() {
        _letters = letters;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _authenticate() {
    final enteredPin = _pinController.text.trim();

    if (enteredPin.isEmpty) {
      setState(() {
        _errorMessage = 'Введите PIN-код';
      });
      return;
    }

    if (enteredPin == _correctPin) {
      setState(() {
        _isAuthenticated = true;
        _errorMessage = '';
      });
      _loadLetters();
      _pinController.clear();
    } else {
      setState(() {
        _errorMessage = 'Неверный PIN-код';
      });
    }
  }

  Future<void> _addSecretGift(int letterId) async {
    final secretGift = _secretGiftController.text.trim();
    if (secretGift.isEmpty) {
      return;
    }

    try {
      final letter = _letters.firstWhere((l) => l.id == letterId);
      final updatedWishes = List<String>.from(letter.wishes)
        ..add('Секретный подарок: $secretGift');
      final updatedLetter = letter.copyWith(wishes: updatedWishes);

      await _repository.updateLetter(updatedLetter);
      await _loadLetters();
      _secretGiftController.clear();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Секретный подарок добавлен'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _generateResponseManually(Letter letter) async {
    final responseText = ResponseGenerator.generateResponse(letter);
    final updatedLetter = letter.copyWith(
      hasResponse: true,
      responseText: responseText,
      responseDate: DateTime.now(),
    );

    await _repository.updateLetter(updatedLetter);
    await _loadLetters();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ответ от Деда Мороза создан'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _editLetter(Letter letter) async {
    final nameController = TextEditingController(text: letter.childName);
    final ageController = TextEditingController(text: letter.age.toString());
    final storyController = TextEditingController(text: letter.story);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редактировать письмо'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Имя ребенка'),
              ),
              TextField(
                controller: ageController,
                decoration: const InputDecoration(labelText: 'Возраст'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: storyController,
                decoration: const InputDecoration(labelText: 'Рассказ'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedLetter = letter.copyWith(
                childName: nameController.text,
                age: int.tryParse(ageController.text) ?? letter.age,
                story: storyController.text,
                updatedAt: DateTime.now(),
              );

              await _repository.updateLetter(updatedLetter);
              await _loadLetters();

              if (!mounted) return;

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Письмо обновлено'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _logout() {
    setState(() {
      _isAuthenticated = false;
      _pinController.clear();
      _letters.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Родительский раздел'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue, Colors.purple],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock, size: 80, color: Colors.white),
                  const SizedBox(height: 20),
                  const Text(
                    'Родительский раздел',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Введите PIN-код для доступа',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      labelText: 'PIN',
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(
                        Icons.password,
                        color: Colors.white70,
                      ),
                      errorText: _errorMessage.isNotEmpty
                          ? _errorMessage
                          : null,
                      errorStyle: const TextStyle(color: Colors.yellow),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _authenticate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Войти', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Подсказка: PIN-код - 1234',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Родительский раздел'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Выйти',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border(bottom: BorderSide(color: Colors.blue.shade200)),
            ),
            child: Row(
              children: [
                const Icon(Icons.family_restroom, color: Colors.blue),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Найдено писем: ${_letters.length}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            )
          else if (_letters.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.mail_outline,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Писем пока нет',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: _loadLetters,
                      child: const Text('Обновить'),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _letters.length,
                itemBuilder: (context, index) {
                  final letter = _letters[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.blue.shade100,
                                child: Text(
                                  letter.childName.isNotEmpty
                                      ? letter.childName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      letter.childName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text('Возраст: ${letter.age}'),
                                  ],
                                ),
                              ),
                              PopupMenuButton(
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 20),
                                        SizedBox(width: 8),
                                        Text('Редактировать'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'response',
                                    child: Row(
                                      children: [
                                        Icon(Icons.mail, size: 20),
                                        SizedBox(width: 8),
                                        Text('Создать ответ'),
                                      ],
                                    ),
                                  ),
                                ],
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _editLetter(letter);
                                  } else if (value == 'response') {
                                    _generateResponseManually(letter);
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Рассказ:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(letter.story),
                          const SizedBox(height: 10),
                          const Text(
                            'Желания:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ...letter.wishes
                              .map((wish) => Text('• $wish'))
                              .toList(),
                          const SizedBox(height: 10),
                          Text(
                            'Отправлено: ${_dateFormat.format(letter.createdAt)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          if (letter.hasResponse) ...[
                            const SizedBox(height: 10),
                            const Text(
                              'Ответ:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.only(top: 5),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.green.shade200,
                                ),
                              ),
                              child: Text(letter.responseText!),
                            ),
                          ],
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _secretGiftController,
                                  decoration: InputDecoration(
                                    labelText: 'Добавить секретный подарок',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () => _addSecretGift(letter.id!),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Добавить'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
