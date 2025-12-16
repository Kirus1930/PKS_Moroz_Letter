import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/letter_service.dart';

class DeliveryTrackingScreen extends StatefulWidget {
  const DeliveryTrackingScreen({super.key});

  @override
  _DeliveryTrackingScreenState createState() => _DeliveryTrackingScreenState();
}

class _DeliveryTrackingScreenState extends State<DeliveryTrackingScreen> {
  late DateTime _newYear;
  late Duration _timeLeft;
  int _currentStep = 0;

  final List<String> _steps = [
    'Письмо создано',
    'Письмо отправлено',
    'Письмо доставлено Деду Морозу',
    'Подарки готовятся',
    'Дед Мороз сел в сани',
    'Дед Мороз в пути',
    'Подарки доставлены!',
  ];

  final List<String> _stepIcons = ['✉️', '📮', '🎅', '🎁', '🛷', '❄️', '⭐'];

  @override
  void initState() {
    super.initState();
    _newYear = DateTime(DateTime.now().year + 1, 1, 1);
    _updateTime();
    _calculateCurrentStep();

    // Обновляем время каждую секунду
    Future.delayed(const Duration(seconds: 1), _updateTimer);
  }

  void _updateTimer() {
    if (mounted) {
      setState(_updateTime);
      Future.delayed(const Duration(seconds: 1), _updateTimer);
    }
  }

  void _updateTime() {
    final now = DateTime.now();
    _timeLeft = _newYear.difference(now);
  }

  void _calculateCurrentStep() {
    final daysUntilNewYear = _timeLeft.inDays;
    if (daysUntilNewYear > 30) {
      _currentStep = 0;
    } else if (daysUntilNewYear > 20) {
      _currentStep = 1;
    } else if (daysUntilNewYear > 15) {
      _currentStep = 2;
    } else if (daysUntilNewYear > 10) {
      _currentStep = 3;
    } else if (daysUntilNewYear > 5) {
      _currentStep = 4;
    } else if (daysUntilNewYear > 0) {
      _currentStep = 5;
    } else {
      _currentStep = 6;
    }
  }

  @override
  Widget build(BuildContext context) {
    _calculateCurrentStep();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Отслеживание доставки'),
        backgroundColor: Colors.green,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E3A8A), Color(0xFF0EA5E9)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Анимация доставки
              SizedBox(
                height: 200,
                child: Lottie.asset('assets/animations/delivery_tracking.json'),
              ),

              // Таймер до Нового Года
              _buildCountdownTimer(),

              const SizedBox(height: 30),

              // Информация о статусе
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'Статус доставки:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _steps[_currentStep],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Шаги доставки
              _buildDeliverySteps(),

              const SizedBox(height: 30),

              // Карта с маршрутом
              _buildDeliveryMap(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownTimer() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white30),
      ),
      child: Column(
        children: [
          const Text(
            'До Нового Года осталось:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTimeCard(_timeLeft.inDays, 'Дней'),
              _buildTimeCard(_timeLeft.inHours % 24, 'Часов'),
              _buildTimeCard(_timeLeft.inMinutes % 60, 'Минут'),
              _buildTimeCard(_timeLeft.inSeconds % 60, 'Секунд'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCard(int value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 5,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  Widget _buildDeliverySteps() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Путь письма:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 15),
            ..._steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              final isActive = index <= _currentStep;

              return Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isActive ? Colors.green : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _stepIcons[index],
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        step,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isActive ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                    if (isActive)
                      const Icon(Icons.check_circle, color: Colors.green),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryMap() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Маршрут Деда Мороза:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 15),
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.blue[50],
              ),
              child: Stack(
                children: [
                  // Здесь будет карта с маршрутом
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.map, size: 50, color: Colors.blue),
                        const SizedBox(height: 10),
                        Text(
                          'От Великого Устюга до вашего города',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // Анимация движения
                  if (_currentStep >= 5)
                    Positioned(
                      right: 50,
                      top: 80,
                      child: Lottie.asset(
                        'assets/animations/sleigh_flying.json',
                        width: 100,
                        height: 100,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
