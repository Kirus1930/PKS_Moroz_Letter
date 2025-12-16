import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'screens/create_letter_screen.dart';
import 'screens/delivery_tracking_screen.dart';
import 'screens/santa_response_screen.dart';
import 'screens/parent_section_screen.dart';
import 'services/letter_service.dart';
import 'services/parent_auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await LetterService.init();
  await ParentAuthService.init();

  // Блокируем горизонтальную ориентацию
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const SantaLetterApp());
}

class SantaLetterApp extends StatelessWidget {
  const SantaLetterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Письмо Деду Морозу',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Comic',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/create-letter': (context) => const CreateLetterScreen(),
        '/track-delivery': (context) => const DeliveryTrackingScreen(),
        '/santa-response': (context) => const SantaResponseScreen(),
        '/parent-section': (context) => const ParentSectionScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
