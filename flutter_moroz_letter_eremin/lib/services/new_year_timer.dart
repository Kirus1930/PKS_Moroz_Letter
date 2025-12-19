import 'dart:async';

class NewYearTimer {
  final StreamController<Duration> _controller =
      StreamController<Duration>.broadcast();
  Timer? _timer;

  Stream<Duration> get timeRemainingStream => _controller.stream;

  void start() {
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    DateTime newYear;

    if (now.month == 12 && now.day > 31) {
      newYear = DateTime(now.year + 1, 1, 1, 0, 0, 0);
    } else {
      newYear = DateTime(now.year, 12, 31, 0, 0, 0);
    }

    final remaining = newYear.difference(now);
    _controller.add(remaining);
  }

  String formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    return '${days.toString().padLeft(2, '0')}д ${hours.toString().padLeft(2, '0')}ч ${minutes.toString().padLeft(2, '0')}м ${seconds.toString().padLeft(2, '0')}с';
  }

  String getDeliveryStatus(Duration remaining) {
    if (remaining.inDays > 30) {
      return 'Письмо готовится к отправке';
    } else if (remaining.inDays > 7) {
      return 'Письмо в пути';
    } else if (remaining.inDays > 1) {
      return 'Дед Мороз читает письмо';
    } else if (remaining.inHours > 1) {
      return 'Подарки готовятся';
    } else {
      return 'Дед Мороз уже в пути!';
    }
  }

  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
