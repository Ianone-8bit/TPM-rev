import 'package:flutter/material.dart';

import 'screens/home_page.dart';
import 'screens/login_page.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> checkLogin() async {
    return AuthService.instance.isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GrowUp',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0F1A),
        primaryColor: const Color(0xFF7C3AED),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF7C3AED),
          secondary: Color(0xFF10B981),
          surface: Color(0xFF1A1A2E),
          tertiary: Color(0xFF10B981),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F0F1A),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
          iconTheme: IconThemeData(color: Color(0xFF7C3AED)),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1A1A2E),
          elevation: 6,
          shadowColor: const Color(0xFF7C3AED).withOpacity(0.15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: const Color(0xFF7C3AED).withOpacity(0.25),
              width: 1,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7C3AED),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            shadowColor: const Color(0xFF7C3AED).withOpacity(0.4),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1A1A2E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2),
          ),
          labelStyle: const TextStyle(color: Colors.white60),
          prefixIconColor: const Color(0xFF7C3AED),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
        dividerColor: Colors.white12,
      ),
      home: FutureBuilder<bool>(
        future: checkLogin(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
              ),
            );
          }
          return snapshot.data! ? const HomePage() : const LoginPage();
        },
      ),
    );
  }
}