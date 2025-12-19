import 'package:intl/intl.dart';
import '../models/letter.dart';

class ResponseGenerator {
  static final List<String> _greetings = [
    'Дорогой',
    'Любимый',
    'Уважаемый',
    'Добрый',
  ];

  static final List<String> _responses = [
    'Я получил твоё письмо и очень рад, что ты написал мне!',
    'Твоё письмо дошло до моей резиденции в Великом Устюге!',
    'Мои помощники уже читают твоё письмо и готовятся к исполнению желаний!',
    'Я прочитал твоё письмо и улыбнулся - ты такой хороший ребёнок!',
  ];

  static final List<String> _wishResponses = [
    'Особенно мне понравилось твоё желание получить',
    'Я обязательно посмотрю, что можно сделать с',
    'Мои помощники уже ищут для тебя',
    'Я постараюсь исполнить твоё желание получить',
  ];

  static final List<String> _endings = [
    'Готовь носочек для подарков!',
    'Не забывай вести себя хорошо до Нового Года!',
    'Жди меня в новогоднюю ночь!',
    'До скорой встречи!',
  ];

  static String generateResponse(Letter letter) {
    final random = DateTime.now().microsecond;
    final greeting = _greetings[random % _greetings.length];
    final response = _responses[(random ~/ 10) % _responses.length];
    final wishResponse =
        _wishResponses[(random ~/ 100) % _wishResponses.length];
    final ending = _endings[(random ~/ 1000) % _endings.length];

    String wishesText = '';
    if (letter.wishes.isNotEmpty) {
      final wish = letter.wishes.first;
      wishesText = '$wishResponse "$wish".';
    }

    final now = DateTime.now();
    final dateFormat = DateFormat('dd MMMM yyyy', 'ru_RU');

    return '''
$greeting ${letter.childName}!

$response $wishesText

Ты написал, что: "${letter.story.substring(0, letter.story.length > 50 ? 50 : letter.story.length)}..."

Я уже начал готовить подарки! Помни, что самое главное - быть добрым и помогать родителям.

$ending

С уважением,
Дед Мороз

${dateFormat.format(now)}
Резиденция Деда Мороза, Великий Устюг
''';
  }
}
