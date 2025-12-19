import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_moroz_letter_eremin/models/letter.dart';
import 'package:flutter_moroz_letter_eremin/repositories/letter_repository.dart';
import 'package:flutter_moroz_letter_eremin/services/database_service.dart';
import 'package:flutter_moroz_letter_eremin/services/response_generator.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

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
  final String _correctPin = '1234';
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
        SnackBar(
          content: Text(
            'Секретный подарок добавлен',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: $e', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
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
      SnackBar(
        content: Text(
          'Ответ от Деда Мороза создан',
          style: TextStyle(color: Colors.white),
        ),
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
        title: Text(
          'Редактировать письмо',
          style: TextStyle(color: AppTheme.blueText),
        ),
        backgroundColor: Colors.white,
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: TextStyle(color: AppTheme.lightRedText),
                decoration: InputDecoration(
                  labelText: 'Имя ребенка',
                  labelStyle: TextStyle(color: AppTheme.lightRedText),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ageController,
                style: TextStyle(color: AppTheme.lightRedText),
                decoration: InputDecoration(
                  labelText: 'Возраст',
                  labelStyle: TextStyle(color: AppTheme.lightRedText),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: storyController,
                style: TextStyle(color: AppTheme.lightRedText),
                decoration: InputDecoration(
                  labelText: 'Рассказ',
                  labelStyle: TextStyle(color: AppTheme.lightRedText),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Отмена',
              style: TextStyle(color: AppTheme.lightRedText),
            ),
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
                SnackBar(
                  content: Text(
                    'Письмо обновлено',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
            ),
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
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.lock,
                      size: 80,
                      color: AppTheme.lightRedText,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Родительский раздел',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.blueText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Введите PIN-код для доступа',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.lightRedText,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _pinController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      style: TextStyle(color: AppTheme.lightRedText),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                        labelText: 'PIN',
                        labelStyle: TextStyle(color: AppTheme.lightRedText),
                        prefixIcon: Icon(
                          Icons.password,
                          color: AppTheme.lightRedText,
                        ),
                        errorText: _errorMessage.isNotEmpty
                            ? _errorMessage
                            : null,
                        errorStyle: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _authenticate,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                      backgroundColor: AppTheme.accentColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Войти',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Подсказка: PIN-код - 1234',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.lightRedText.withOpacity(0.7),
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.lightBlueBackground, Colors.lightBlue[100]!],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                border: Border(bottom: BorderSide(color: Colors.blue[200]!)),
              ),
              child: Row(
                children: [
                  Icon(Icons.family_restroom, color: AppTheme.lightRedText),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Найдено писем: ${_letters.length}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.blueText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoading)
              Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: AppTheme.accentColor),
                ),
              )
            else if (_letters.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.mail_outline,
                        size: 80,
                        color: AppTheme.lightRedText.withOpacity(0.5),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Писем пока нет',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppTheme.lightRedText,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _loadLetters,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentColor,
                        ),
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
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: Colors.white.withOpacity(0.95),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.blue[100],
                                    child: Text(
                                      letter.childName.isNotEmpty
                                          ? letter.childName[0].toUpperCase()
                                          : '?',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.blueText,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          letter.childName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: AppTheme.lightRedText,
                                          ),
                                        ),
                                        Text(
                                          'Возраст: ${letter.age}',
                                          style: TextStyle(
                                            color: AppTheme.lightRedText
                                                .withOpacity(0.9),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton(
                                    icon: Icon(
                                      Icons.more_vert,
                                      color: AppTheme.lightRedText,
                                    ),
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.edit,
                                              size: 20,
                                              color: AppTheme.lightRedText,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Редактировать',
                                              style: TextStyle(
                                                color: AppTheme.lightRedText,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'response',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.mail,
                                              size: 20,
                                              color: AppTheme.lightRedText,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Создать ответ',
                                              style: TextStyle(
                                                color: AppTheme.lightRedText,
                                              ),
                                            ),
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
                              const SizedBox(height: 12),
                              Text(
                                'Рассказ:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.blueText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppTheme.lightRedText.withOpacity(
                                      0.3,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  letter.story,
                                  style: TextStyle(
                                    color: AppTheme.lightRedText,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Желания:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.blueText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ...letter.wishes
                                  .map(
                                    (wish) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      margin: const EdgeInsets.only(bottom: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: AppTheme.lightRedText
                                              .withOpacity(0.3),
                                        ),
                                      ),
                                      child: Text(
                                        '• $wish',
                                        style: TextStyle(
                                          color: AppTheme.lightRedText,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              const SizedBox(height: 12),
                              Text(
                                'Отправлено: ${_dateFormat.format(letter.createdAt)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.lightRedText.withOpacity(0.6),
                                ),
                              ),
                              if (letter.hasResponse) ...[
                                const SizedBox(height: 12),
                                Text(
                                  'Ответ:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.blueText,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.green[200]!,
                                    ),
                                  ),
                                  child: Text(
                                    letter.responseText!,
                                    style: TextStyle(color: Colors.green[900]),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _secretGiftController,
                                      style: TextStyle(
                                        color: AppTheme.lightRedText,
                                      ),
                                      decoration: InputDecoration(
                                        labelText: 'Добавить секретный подарок',
                                        labelStyle: TextStyle(
                                          color: AppTheme.lightRedText,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: BorderSide(
                                            color: AppTheme.lightRedText
                                                .withOpacity(0.5),
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
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
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
