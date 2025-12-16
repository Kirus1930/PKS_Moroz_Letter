import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/letter_model.dart';
import '../services/letter_service.dart';

class CreateLetterScreen extends StatefulWidget {
  const CreateLetterScreen({super.key});

  @override
  _CreateLetterScreenState createState() => _CreateLetterScreenState();
}

class _CreateLetterScreenState extends State<CreateLetterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _storyController = TextEditingController();

  String _selectedMood = '😊';
  List<String> _selectedCategories = [];
  List<String> _wishes = [];
  final TextEditingController _wishController = TextEditingController();

  File? _drawingFile;
  File? _photoFile;

  final List<String> _moodOptions = [
    '😊',
    '😄',
    '😍',
    '🤩',
    '🥳',
    '🎁',
    '⭐',
    '🎄',
  ];
  final List<String> _categoryOptions = [
    'Игрушки',
    'Книги',
    'Сладости',
    'Одежда',
    'Гаджеты',
    'Спорт',
    'Творчество',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _storyController.dispose();
    _wishController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Напиши письмо Деду Морозу'),
        backgroundColor: Colors.red,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/paper_texture.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок
                Center(
                  child: Text(
                    '✉️ Мое письмо Деду Морозу ✉️',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Имя
                _buildTextField(
                  controller: _nameController,
                  label: 'Меня зовут:',
                  hint: 'Введи свое имя',
                  icon: Icons.person,
                  validator: (value) =>
                      value!.isEmpty ? 'Введи свое имя' : null,
                ),

                // Возраст
                _buildTextField(
                  controller: _ageController,
                  label: 'Мой возраст:',
                  hint: 'Сколько тебе лет?',
                  icon: Icons.cake,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) return 'Введи свой возраст';
                    final age = int.tryParse(value);
                    if (age == null || age < 1 || age > 15) {
                      return 'Введи правильный возраст (1-15)';
                    }
                    return null;
                  },
                ),

                // Настроение
                _buildMoodSelector(),

                // Рассказ о себе
                _buildTextField(
                  controller: _storyController,
                  label: 'Расскажи о себе:',
                  hint: 'Чем увлекаешься? Был ли хорошим в этом году?',
                  icon: Icons.star,
                  maxLines: 4,
                  validator: (value) =>
                      value!.isEmpty ? 'Расскажи о себе' : null,
                ),

                // Категории желаний
                _buildCategorySelector(),

                // Список желаний
                _buildWishesList(),

                // Рисунок
                _buildDrawingSection(),

                // Фото
                _buildPhotoSection(),

                // Кнопка отправки
                const SizedBox(height: 40),
                Center(
                  child: ElevatedButton(
                    onPressed: _sendLetter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Отправить письмо Деду Морозу!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: Colors.blue),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(15),
            ),
            validator: validator,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMoodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Мое настроение:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _moodOptions.length,
            itemBuilder: (context, index) {
              final mood = _moodOptions[index];
              return GestureDetector(
                onTap: () => setState(() => _selectedMood = mood),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _selectedMood == mood ? Colors.blue : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: Center(
                    child: Text(mood, style: const TextStyle(fontSize: 24)),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Какие подарки ты хочешь?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _categoryOptions.map((category) {
            final isSelected = _selectedCategories.contains(category);
            return FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedCategories.add(category);
                  } else {
                    _selectedCategories.remove(category);
                  }
                });
              },
              backgroundColor: Colors.white,
              selectedColor: Colors.green[100],
              checkmarkColor: Colors.green,
              labelStyle: TextStyle(
                color: isSelected ? Colors.green : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildWishesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Мои желания:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
        const SizedBox(height: 8),

        // Поле для ввода желания
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _wishController,
                decoration: InputDecoration(
                  hintText: 'Добавить желание...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.green),
              onPressed: _addWish,
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Список желаний
        if (_wishes.isNotEmpty)
          ..._wishes.asMap().entries.map((entry) {
            final index = entry.key;
            final wish = entry.value;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: ListTile(
                leading: const Icon(Icons.star, color: Colors.amber),
                title: Text(wish),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeWish(index),
                ),
              ),
            );
          }),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDrawingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Рисунок для Деда Мороза:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _takePhoto,
              icon: const Icon(Icons.photo_camera),
              label: const Text('Сделать фото'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: _pickPhoto,
              icon: const Icon(Icons.photo_library),
              label: const Text('Выбрать из галереи'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            ),
          ],
        ),

        if (_photoFile != null)
          Container(
            margin: const EdgeInsets.only(top: 10),
            height: 150,
            child: Image.file(_photoFile!),
          ),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Нарисуй рисунок:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
        const SizedBox(height: 8),

        ElevatedButton.icon(
          onPressed: _startDrawing,
          icon: const Icon(Icons.brush),
          label: const Text('Начать рисовать'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
        ),

        if (_drawingFile != null)
          Container(
            margin: const EdgeInsets.only(top: 10),
            height: 150,
            child: Image.file(_drawingFile!),
          ),

        const SizedBox(height: 20),
      ],
    );
  }

  void _addWish() {
    final wish = _wishController.text.trim();
    if (wish.isNotEmpty) {
      setState(() {
        _wishes.add(wish);
        _wishController.clear();
      });
    }
  }

  void _removeWish(int index) {
    setState(() {
      _wishes.removeAt(index);
    });
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _photoFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _photoFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _startDrawing() async {
    // Здесь можно открыть экран рисования
    // Для простоты просто создаем пустой файл
    // В реальном приложении здесь должен быть полноценный экран рисования
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Рисовальщик'),
        content: const Text('Здесь будет экран для рисования'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendLetter() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выбери хотя бы одну категорию подарков')),
      );
      return;
    }
    if (_wishes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Добавь хотя бы одно желание')),
      );
      return;
    }

    final letter = Letter(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      childName: _nameController.text,
      age: int.parse(_ageController.text),
      story: _storyController.text,
      moodEmoji: _selectedMood,
      wishes: _wishes,
      categories: _selectedCategories,
      drawingPath: _drawingFile?.path,
      photoPath: _photoFile?.path,
      createdAt: DateTime.now(),
      isSent: true,
    );

    await LetterService.saveLetter(letter);

    // Показать анимацию отправки
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animations/sending_letter.json',
                height: 150,
              ),
              const SizedBox(height: 20),
              const Text(
                'Письмо отправлено Деду Морозу!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text('Скоро получишь ответ!'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Закрыть диалог
                  Navigator.pop(context); // Вернуться на главный экран
                },
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
