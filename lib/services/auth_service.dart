import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class AuthService {
  static final AuthService instance = AuthService();
  
  // Ganti URL ini dengan URL file api.php di server/hosting Anda
  // Jika pakai XAMPP, bisa dicoba http://127.0.0.1/hunter_system/backend/api.php
  // Jika localhost di browser error CORS, pastikan URL mengarah tepat ke lokasi api.php
  final String apiUrl = 'http://127.0.0.1/hunter_system/backend/api.php';

  String hashPassword(String password) {
    return sha256
        .convert(utf8.encode(password))
        .toString();
  }

  Future<String?> register(
    String username,
    String password,
  ) async {
    if (username.isEmpty || password.isEmpty) {
      return 'Username dan Password tidak boleh kosong';
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "action": "register",
          "username": username,
          "passwordHash": hashPassword(password),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return null; // Success
        } else {
          return data['message'] ?? 'Gagal Register';
        }
      } else {
        return 'Server Error: ${response.statusCode}';
      }
    } catch (e) {
      return 'Koneksi ke Server Gagal (Pastikan XAMPP/Hosting menyala): $e';
    }
  }

  Future<bool> login(
    String username,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "action": "login",
          "username": username,
          "passwordHash": hashPassword(password),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('username', username);
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs =
        await SharedPreferences.getInstance();

    await prefs.clear();
  }

  Future<bool> isLoggedIn() async {
    SharedPreferences prefs =
        await SharedPreferences.getInstance();

    return prefs.getBool('isLoggedIn') ?? false;
  }

  Future<String> currentUser() async {
    SharedPreferences prefs =
        await SharedPreferences.getInstance();

    return prefs.getString('username') ?? '';
  }
}