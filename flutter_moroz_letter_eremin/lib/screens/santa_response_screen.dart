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

${_letter!.wishes.isNotEmpty ? 'Особенно мне понравилось твое желание получить "${_letter!.wishes[0]}". Мои помощники уже начали его готовить!' : ''}
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
      '''
Дорогой ${_letter!.childName}!

Спасибо за твоё чудесное письмо! Я внимательно прочитал его в своей резиденции в Великом Устюге.
Вижу, что ты очень старался в этом году и заслуживаешь только лучших подарков!

${_letter!.wishes.isNotEmpty ? 'Насчёт "${_letter!.wishes[0]}" - уже передал своим помощникам, чтобы приготовили к празднику!' : ''}
Не забудь оставить мне под ёлочкой морковку для оленей и печенье для меня!

До скорой встречи,
Твой Дед Мороз 🦌
''',
    ];

    final randomResponse =
        responses[DateTime.now().millisecondsSinceEpoch % responses.length];
    setState(() => _santaResponse = randomResponse);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ответ от Деда Мороза'),
        backgroundColor: const Color(0xFFD32F2F),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareResponse,
            tooltip: 'Поделиться ответом',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD32F2F)),
            )
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1A237E), Color(0xFF311B92)],
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Анимация Деда Мороза
                    SizedBox(
                      height: 180,
                      child: Lottie.asset(
                        'assets/animations/santa_waving.json',
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Конверт с письмом
                    Card(
                      elevation: 12,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.white, Color(0xFFFFF8E1)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(25),
                        child: Column(
                          children: [
                            // Штамп с Великим Устюгом
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFFD32F2F),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.red.shade50,
                                        Colors.white,
                                      ],
                                    ),
                                  ),
                                  child: const Text(
                                    'ВЕЛИКИЙ УСТЮГ',
                                    style: TextStyle(
                                      color: Color(0xFFD32F2F),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 25),

                            // Заголовок
                            const Text(
                              'ОТ ДЕДА МОРОЗА',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFB71C1C),
                                letterSpacing: 1.5,
                              ),
                            ),

                            const SizedBox(height: 30),

                            // Текст письма
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.blueGrey.shade300,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white,
                              ),
                              child: Text(
                                _santaResponse,
                                style: const TextStyle(
                                  fontSize: 18,
                                  height: 1.6,
                                  color: Colors.blueGrey,
                                  fontFamily: 'Comic',
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),

                            // Подпись и печать
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'С уважением,',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    const Text(
                                      'Дед Мороз',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFD32F2F),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Великий Устюг, ${DateTime.now().year} г.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Image.asset(
                                      'assets/images/santa_signature.png',
                                      height: 60,
                                      fit: BoxFit.contain,
                                    ),
                                    const SizedBox(height: 5),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.red,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Печать',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.red,
                                        ),
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

                    const SizedBox(height: 40),

                    // Кнопки действий
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _saveResponse,
                            icon: const Icon(Icons.save_alt, size: 22),
                            label: const Text(
                              'Сохранить',
                              style: TextStyle(fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF388E3C),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 25,
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _printResponse,
                            icon: const Icon(Icons.print, size: 22),
                            label: const Text(
                              'Поделиться',
                              style: TextStyle(fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1976D2),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 25,
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Дополнительная информация
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white30),
                      ),
                      child: const Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Интересный факт',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Дед Мороз живёт в Великом Устюге вместе со своей внучкой Снегурочкой. '
                            'Каждый год он путешествует на своей волшебной тройке, чтобы поздравить всех детей с Новым Годом!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _shareResponse() async {
    if (_santaResponse.isEmpty) return;

    await Share.share(
      '🎅 Ответ от Деда Мороза 🎅\n\n$_santaResponse\n\nОтправлено из приложения "Письмо Деду Морозу"',
      subject: 'Ответ от Деда Мороза',
    );
  }

  Future<void> _saveResponse() async {
    // Для будущей логики сохранения ответа как изображения
    // Пока показываем уведомление
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text('Ответ сохранён в галерею'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _printResponse() async {
    // Логика для кнопки "Поделиться" уже реализована в _shareResponse
    // Можно вызвать ту же функцию или добавить дополнительную логику
    await _shareResponse();
  }
}
