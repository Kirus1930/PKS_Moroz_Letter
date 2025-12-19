import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/letter.dart';
import '../repositories/letter_repository.dart';

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
          const SnackBar(
            content: Text('Письмо отправлено Деду Морозу!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Новое письмо')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Твоё имя',
                  icon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите своё имя';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: 'Возраст',
                  icon: Icon(Icons.cake),
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
              TextFormField(
                controller: _storyController,
                decoration: const InputDecoration(
                  labelText: 'Расскажи о себе',
                  icon: Icon(Icons.book),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Расскажи что-нибудь о себе';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text('Твои желания:', style: TextStyle(fontSize: 16)),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _wishController,
                      decoration: const InputDecoration(
                        hintText: 'Добавить желание',
                      ),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.add), onPressed: _addWish),
                ],
              ),
              ...wishes.asMap().entries.map((entry) {
                final index = entry.key;
                final wish = entry.value;
                return ListTile(
                  title: Text(wish),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () => _removeWish(index),
                  ),
                );
              }).toList(),
              const SizedBox(height: 20),
              if (_drawing != null) Image.file(_drawing!, height: 200),
              ElevatedButton.icon(
                icon: const Icon(Icons.photo),
                label: const Text('Добавить рисунок'),
                onPressed: _pickImage,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submitLetter,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  'Отправить письмо Деду Морозу',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
