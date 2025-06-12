import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firebase_options_env.dart'; // Uses env-secured Firebase config

// Screens
import 'screens/home_page.dart';
import 'screens/login_screen.dart';
import 'screens/role_screen.dart';
import 'screens/driver_verification_page.dart';
import 'screens/driver_registration_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Load environment variables from .env
  await dotenv.load(fileName: "assets/.env");


  // ✅ Initialize Firebase using environment-secured options
  await Firebase.initializeApp(
    options: FirebaseOptionsFromEnv.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jeepway',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const JeepwayHomePage(),
        '/login': (context) => const LoginScreen(),
        '/onboarding': (context) => const RoleScreen(),
        '/driver-verification': (context) => const DriverVerificationPage(),
        '/driver-registration': (context) => const DriverRegistrationPage(),
      },
    );
  }
}
