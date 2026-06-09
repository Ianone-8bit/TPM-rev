import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() =>
      _RegisterPageState();
}

class _RegisterPageState
    extends State<RegisterPage> {
  final usernameController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  Future<void> register() async {
    String? error =
        await AuthService.instance.register(
      usernameController.text,
      passwordController.text,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          error == null
              ? 'Register Berhasil'
              : error,
        ),
      ),
    );

    if (error == null) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AWAKENING REGISTRATION')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_add, size: 80, color: Color(0xFF00E5FF)),
              const SizedBox(height: 20),
              const Text(
                'NEW HUNTER',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                  color: Color(0xFF00E5FF),
                  shadows: [Shadow(color: Color(0xFF00E5FF), blurRadius: 10)],
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'CHOOSE HUNTER ID',
                  prefixIcon: Icon(Icons.person_outline, color: Color(0xFF00E5FF)),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'CREATE PASSWORD',
                  prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF00E5FF)),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: register,
                  child: const Text('REGISTER SYSTEM', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}