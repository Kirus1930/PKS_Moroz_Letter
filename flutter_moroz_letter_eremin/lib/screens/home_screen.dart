import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'create_letter_screen.dart';
import 'delivery_tracking_screen.dart';
import 'santa_response_screen.dart';
import 'parent_section_screen.dart';
import '../services/letter_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _snowController;

  @override
  void initState() {
    super.initState();
    _snowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _snowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Фон с градиентом
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A2472),
                  Color(0xFF1E3A8A),
                  Color(0xFF6B21A8),
                ],
              ),
            ),
          ),

          // Падающий снег
          Positioned.fill(
            child: Lottie.asset(
              'assets/animations/snowfall.json',
              controller: _snowController,
              fit: BoxFit.cover,
            ),
          ),

          // Содержимое
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Шапка с анимацией
                  SizedBox(
                    height: 200,
                    child: Lottie.asset(
                      'assets/animations/santa_animation.json',
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Заголовок
                  const Text(
                    'Письмо Деду Морозу',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Comic',
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.blue,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Расскажи о себе и своих желаниях!',
                    style: TextStyle(fontSize: 18, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // Основные кнопки
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 1.2,
                      children: [
                        _buildMenuButton(
                          icon: Icons.edit,
                          label: 'Написать письмо',
                          color: Colors.red,
                          onTap: () => _navigateToCreateLetter(context),
                        ),

                        _buildMenuButton(
                          icon: Icons.track_changes,
                          label: 'Отследить доставку',
                          color: Colors.green,
                          onTap: () => _navigateToTracking(context),
                        ),

                        _buildMenuButton(
                          icon: Icons.email,
                          label: 'Ответ от Деда Мороза',
                          color: Colors.amber,
                          onTap: () => _navigateToSantaResponse(context),
                        ),

                        _buildMenuButton(
                          icon: Icons.lock,
                          label: 'Для родителей',
                          color: Colors.purple,
                          onTap: () => _navigateToParentSection(context),
                        ),
                      ],
                    ),
                  ),

                  // Новогодний таймер
                  _buildNewYearTimer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewYearTimer() {
    final now = DateTime.now();
    final newYear = DateTime(now.year + 1, 1, 1);
    final difference = newYear.difference(now);

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white30),
      ),
      child: Column(
        children: [
          const Text(
            'До Нового Года осталось:',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTimeUnit(difference.inDays, 'дней'),
              _buildTimeUnit(difference.inHours % 24, 'часов'),
              _buildTimeUnit(difference.inMinutes % 60, 'минут'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeUnit(int value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
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
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  void _navigateToCreateLetter(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateLetterScreen()),
    );
  }

  void _navigateToTracking(BuildContext context) async {
    final hasLetter = await LetterService.hasLetter();
    if (!hasLetter) {
      _showNoLetterDialog(context);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DeliveryTrackingScreen()),
    );
  }

  void _navigateToSantaResponse(BuildContext context) async {
    final hasLetter = await LetterService.hasLetter();
    if (!hasLetter) {
      _showNoLetterDialog(context);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SantaResponseScreen()),
    );
  }

  void _navigateToParentSection(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ParentSectionScreen()),
    );
  }

  void _showNoLetterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Письмо не найдено'),
        content: const Text('Сначала напиши письмо Деду Морозу!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
