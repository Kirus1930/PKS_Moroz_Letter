import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/letter.dart';
import '../repositories/letter_repository.dart';
import '../theme/app_theme.dart';

class CreateLetterPage extends StatefulWidget {
  final LetterRepository repository;

  const CreateLetterPage({super.key, required this.repository});

  @override
  State<CreateLetterPage> createState() => _CreateLetterPageState();
}

class _CreateLetterPageState extends State<CreateLetterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _storyController = TextEditingController();
  final TextEditingController _wishController = TextEditingController();

  List<String> wishes = [];
  File? _drawing;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _drawing = File(image.path);
      });
    }
  }

  void _addWish() {
    if (_wishController.text.isNotEmpty) {
      setState(() {
        wishes.add(_wishController.text);
        _wishController.clear();
      });
    }
  }

  void _removeWish(int index) {
    setState(() {
      wishes.removeAt(index);
    });
  }

  Future<void> _submitLetter() async {
    if (_formKey.currentState!.validate()) {
      final letter = Letter(
        childName: _nameController.text,
        age: int.parse(_ageController.text),
        story: _storyController.text,
        wishes: wishes,
        drawingPath: _drawing?.path,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      try {
        await widget.repository.saveLetter(letter);

        if (!mounted) return;

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Письмо отправлено Деду Морозу!',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: AppTheme.accentColor,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Новое письмо')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.lightBlueBackground, Colors.lightBlue[100]!],
          ),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Имя
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    controller: _nameController,
                    style: TextStyle(
                      color: AppTheme.lightRedText,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Твоё имя',
                      labelStyle: TextStyle(color: AppTheme.lightRedText),
                      icon: Icon(Icons.person, color: AppTheme.lightRedText),
                      border: InputBorder.none,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите своё имя';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Возраст
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    controller: _ageController,
                    style: TextStyle(
                      color: AppTheme.lightRedText,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Возраст',
                      labelStyle: TextStyle(color: AppTheme.lightRedText),
                      icon: Icon(Icons.cake, color: AppTheme.lightRedText),
                      border: InputBorder.none,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите возраст';
                      }
                      final age = int.tryParse(value);
                      if (age == null || age < 1 || age > 15) {
                        return 'Введите возраст от 1 до 15';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Рассказ о себе
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    controller: _storyController,
                    style: TextStyle(
                      color: AppTheme.lightRedText,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Расскажи о себе',
                      labelStyle: TextStyle(color: AppTheme.lightRedText),
                      icon: Icon(Icons.book, color: AppTheme.lightRedText),
                      border: InputBorder.none,
                      alignLabelWithHint: true,
                    ),
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Расскажи что-нибудь о себе';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Желания
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Твои желания:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.lightRedText,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _wishController,
                              style: TextStyle(
                                color: AppTheme.lightRedText,
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Добавить желание...',
                                hintStyle: TextStyle(
                                  color: AppTheme.lightRedText.withOpacity(0.7),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: AppTheme.lightRedText.withOpacity(
                                      0.5,
                                    ),
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _addWish,
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(12),
                              backgroundColor: AppTheme.accentColor,
                            ),
                            child: const Icon(Icons.add, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (wishes.isNotEmpty) ...[
                        Column(
                          children: wishes.asMap().entries.map((entry) {
                            final index = entry.key;
                            final wish = entry.value;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppTheme.lightRedText.withOpacity(0.3),
                                ),
                              ),
                              child: ListTile(
                                title: Text(
                                  wish,
                                  style: TextStyle(
                                    color: AppTheme.lightRedText,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.remove,
                                    color: AppTheme.lightRedText,
                                  ),
                                  onPressed: () => _removeWish(index),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ] else ...[
                        Text(
                          'Пока нет желаний. Добавь первое!',
                          style: TextStyle(
                            color: AppTheme.lightRedText.withOpacity(0.7),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Рисунок
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Рисунок для Деда Мороза:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.lightRedText,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_drawing != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.lightRedText.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              _drawing!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.photo, size: 24),
                        label: const Text('Добавить рисунок'),
                        onPressed: _pickImage,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          backgroundColor: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Кнопка отправки
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentColor.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _submitLetter,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: AppTheme.accentColor,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Отправить письмо Деду Морозу',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
