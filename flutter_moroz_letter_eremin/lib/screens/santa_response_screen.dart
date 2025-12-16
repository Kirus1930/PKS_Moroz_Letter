import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';
import '../services/letter_service.dart';
import '../models/letter_model.dart';

class SantaResponseScreen extends StatefulWidget {
  const SantaResponseScreen({super.key});

  @override
  _SantaResponseScreenState createState() => _SantaResponseScreenState();
}

class _SantaResponseScreenState extends State<SantaResponseScreen> {
  Letter? _letter;
  String _santaResponse = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLetterAndGenerateResponse();
  }

  Future<void> _loadLetterAndGenerateResponse() async {
    _letter = await LetterService.getLetter();
    if (_letter != null) {
      _generateSantaResponse();
    }
    setState(() => _isLoading = false);
  }

  void _generateSantaResponse() {
    if (_letter == null) return;

    final responses = [
      '''
Привет, ${_letter!.childName}!

Я, Дед Мороз, получил твое письмо и очень рад, что ты такой хороший ребёнок!
${_letter!.age} лет - отличный возраст для новых приключений!

${_letter!.wishes.isNotEmpty ? 'Особенно мне понравилось твое желание получить "${_letter!.wishes[0]}". Мои эльфы уже начали его готовить!' : ''}
${_letter!.secretGiftFromParent != null ? 'А ещё я узнал, что ты очень хочешь ${_letter!.secretGiftFromParent}. Постараюсь выполнить и это желание!' : ''}

Продолжай хорошо себя вести, помогай родителям и учись на отлично!
Увидимся в Новом Году!

С любовью,
Твой Дед Мороз 🎅
''',
      '''
Здравствуй, дорогой ${_letter!.childName}!

Как приятно получить письмо от такого замечательного ребёнка!
Твой рассказ о том, что ${_letter!.story.length > 50 ? _letter!.story.substring(0, 50) + '...' : _letter!.story} очень тронул меня.

${_letter!.wishes.length > 1 ? 'Насчёт "${_letter!.wishes[1]}" - это отличный выбор! Обязательно привезу.' : ''}
Твоё настроение ${_letter!.moodEmoji} говорит о том, что ты ждёшь праздник с нетерпением!

Жди меня в новогоднюю ночь!
Твой Дед Мороз ⭐
''',
    ];

    final randomResponse = responses[DateTime.now().second % responses.length];
    setState(() => _santaResponse = randomResponse);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ответ от Деда Мороза'),
        backgroundColor: Colors.red,
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: _shareResponse),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/santa_background.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Анимация Деда Мороза
                    SizedBox(
                      height: 200,
                      child: Lottie.asset(
                        'assets/animations/santa_waving.json',
                      ),
                    ),

                    // Конверт
                    Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.white, Color(0xFFFFF3E0)],
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        padding: const EdgeInsets.all(25),
                        child: Column(
                          children: [
                            // Штамп
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.red,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    'СЕВЕРНЫЙ ПОЛЮС',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Заголовок
                            const Text(
                              'ОТ ДЕДА МОРОЗА',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),

                            const SizedBox(height: 30),

                            // Текст письма
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.blueGrey.shade200,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _santaResponse,
                                style: const TextStyle(
                                  fontSize: 18,
                                  height: 1.5,
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),

                            // Подпись
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Image.asset(
                                      'assets/images/santa_signature.png',
                                      height: 50,
                                    ),
                                    const SizedBox(height: 5),
                                    const Text(
                                      'Дед Мороз',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Кнопки
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _saveResponse,
                          icon: const Icon(Icons.save),
                          label: const Text('Сохранить'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _printResponse,
                          icon: const Icon(Icons.print),
                          label: const Text('Распечатать'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Сертификат
                    _buildCertificate(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCertificate() {
    return GestureDetector(
      onTap: _showCertificate,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              const Icon(Icons.card_giftcard, size: 40, color: Colors.green),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Сертификат помощника Деда Мороза',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Нажмите, чтобы посмотреть',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _shareResponse() async {
    await Share.share(
      'Посмотрите, какой ответ я получил от Деда Мороза!\n\n$_santaResponse',
      subject: 'Ответ от Деда Мороза',
    );
  }

  Future<void> _saveResponse() async {
    // Здесь будет сохранение в галерею
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ответ сохранён в галерею!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _printResponse() async {
    // Здесь будет логика печати
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Готово к печати!')));
  }

  void _showCertificate() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue[50]!, Colors.white],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🎅 СЕРТИФИКАТ 🎅',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Награждается\n${_letter?.childName ?? 'Дорогой друг'}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'за отличное поведение в этом году\nи веру в новогоднее чудо!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              Image.asset('assets/images/santa_stamp.png', height: 100),
              const SizedBox(height: 20),
              const Text(
                'Северный Полюс, ${DateTime.now().year} г.',
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
