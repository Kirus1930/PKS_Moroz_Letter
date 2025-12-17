import 'package:flutter/material.dart';
import '../services/parent_auth_service.dart';
import '../services/letter_service.dart';
import '../models/letter_model.dart';

class ParentSectionScreen extends StatefulWidget {
  const ParentSectionScreen({super.key});

  @override
  _ParentSectionScreenState createState() => _ParentSectionScreenState();
}

class _ParentSectionScreenState extends State<ParentSectionScreen> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _secretGiftController = TextEditingController();
  bool _isAuthenticated = false;
  bool _isPinSetup = false;
  Letter? _letter;

  @override
  void initState() {
    super.initState();
    _checkAuth();
    _loadLetter();
  }

  Future<void> _checkAuth() async {
    final isSetup = await ParentAuthService.isPinSetup();
    final isAuthenticated = await ParentAuthService.checkAuth();

    setState(() {
      _isPinSetup = isSetup;
      _isAuthenticated = isAuthenticated;
    });
  }

  Future<void> _loadLetter() async {
    final letter = await LetterService.getLetter();
    setState(() => _letter = letter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Родительский раздел'),
        backgroundColor: Colors.purple,
      ),
      body: _isPinSetup && !_isAuthenticated
          ? _buildPinScreen()
          : _buildParentSection(),
    );
  }

  Widget _buildPinScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 80, color: Colors.purple),
            const SizedBox(height: 20),
            const Text(
              'Введите PIN-код',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              child: TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                textAlign: TextAlign.center,
                maxLength: 4,
                decoration: InputDecoration(
                  hintText: '0000',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verifyPin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
              child: const Text('Войти'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _setupNewPin,
              child: const Text('Забыли PIN? Установить новый'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParentSection() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Приветствие
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(
                  Icons.family_restroom,
                  size: 50,
                  color: Colors.purple,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Родительский раздел',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _letter != null
                      ? 'Письмо от ${_letter!.childName}'
                      : 'Письмо ещё не написано',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Просмотр письма
        if (_letter != null) _buildLetterPreview(),

        const SizedBox(height: 20),

        // Секретный подарок
        _buildSecretGiftSection(),

        const SizedBox(height: 20),

        // Настройки ответа
        _buildResponseSettings(),

        const SizedBox(height: 20),

        // Настройки безопасности
        _buildSecuritySettings(),
      ],
    );
  }

  Widget _buildLetterPreview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Письмо от ребёнка:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Имя'),
              subtitle: Text(_letter!.childName),
            ),
            ListTile(
              leading: const Icon(Icons.cake),
              title: const Text('Возраст'),
              subtitle: Text('${_letter!.age} лет'),
            ),
            ListTile(
              leading: const Icon(Icons.emoji_emotions),
              title: const Text('Настроение'),
              subtitle: Text(_letter!.moodEmoji),
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Рассказ о себе'),
              subtitle: Text(_letter!.story),
            ),
            ListTile(
              leading: const Icon(Icons.card_giftcard),
              title: const Text('Желания'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _letter!.wishes
                    .map((wish) => Text('• $wish'))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecretGiftSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Секретный подарок от родителей:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Этот подарок появится в ответе Деда Мороза',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _secretGiftController,
              decoration: InputDecoration(
                labelText: 'Описание подарка',
                hintText: 'Например: конструктор LEGO или кукла',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _saveSecretGift,
                ),
              ),
            ),
            if (_letter?.secretGiftFromParent != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'Текущий подарок: ${_letter!.secretGiftFromParent}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Настройки ответа Деда Мороза:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            // Время ответа
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('Время ответа'),
              subtitle: const Text('Через 1 день после отправки'),
              trailing: Switch(value: true, onChanged: (value) {}),
            ),

            // Персонализация
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Персонализированный ответ'),
              subtitle: const Text('Использовать имя и желания'),
              trailing: Switch(value: true, onChanged: (value) {}),
            ),

            // Шаблоны ответов
            const ListTile(
              leading: Icon(Icons.email),
              title: Text('Шаблоны ответов'),
              subtitle: Text('Выбрать стиль письма'),
              trailing: Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Настройки безопасности:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Изменить PIN-код'),
              subtitle: const Text('Установить новый код доступа'),
              onTap: _changePin,
            ),

            ListTile(
              leading: const Icon(Icons.cloud_off),
              title: const Text('Оффлайн режим'),
              subtitle: const Text('Работа без интернета'),
              trailing: Switch(value: true, onChanged: (value) {}),
            ),

            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Удалить данные'),
              subtitle: const Text('Очистить все письма и настройки'),
              onTap: _clearData,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _verifyPin() async {
    final isValid = await ParentAuthService.verifyPin(_pinController.text);

    if (isValid) {
      setState(() => _isAuthenticated = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Неверный PIN-код'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _setupNewPin() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Установить новый PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: const InputDecoration(
                hintText: 'Новый PIN (4 цифры)',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: const InputDecoration(hintText: 'Повторите PIN'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              // Здесь будет сохранение нового PIN
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('PIN успешно изменён'),
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

  Future<void> _saveSecretGift() async {
    if (_secretGiftController.text.isNotEmpty && _letter != null) {
      await LetterService.updateSecretGift(_secretGiftController.text);
      await _loadLetter();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Секретный подарок сохранён'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _changePin() async {
    await _setupNewPin();
  }

  Future<void> _clearData() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить все данные?'),
        content: const Text(
          'Это действие нельзя отменить. Все письма и настройки будут удалены.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              await LetterService.clearAllData();
              await ParentAuthService.clearPin();
              Navigator.pop(context);
              setState(() {
                _letter = null;
                _isAuthenticated = false;
                _isPinSetup = false;
              });
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
