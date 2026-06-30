import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database_service.dart';

/// AuthService menggunakan SQLite lokal — tidak membutuhkan server/XAMPP.
class AuthService {
  static final AuthService instance = AuthService();

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<String?> register(String username, String password) async {
    if (username.trim().isEmpty || password.trim().isEmpty) {
      return 'Username dan password tidak boleh kosong';
    }
    if (username.trim().length < 3) {
      return 'Username minimal 3 karakter';
    }
    if (password.trim().length < 6) {
      return 'Password minimal 6 karakter';
    }

    try {
      final db = await DatabaseService.instance.database;

      // Cek apakah username sudah ada
      final existing = await db.query(
        'auth_users',
        where: 'username = ?',
        whereArgs: [username.trim()],
      );

      if (existing.isNotEmpty) {
        return 'Username sudah dipakai, coba username lain';
      }

      // Simpan user baru
      await db.insert('auth_users', {
        'username': username.trim(),
        'password_hash': _hashPassword(password),
      });

      // Buat data progress awal di tabel users
      final existing2 = await db.query(
        'users',
        where: 'username = ?',
        whereArgs: [username.trim()],
      );
      if (existing2.isEmpty) {
        await db.insert('users', {
          'username': username.trim(),
          'level': 1,
          'exp': 0,
          'gold': 0,
        });
      }

      return null; // null = sukses
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }

  Future<bool> login(String username, String password) async {
    if (username.trim().isEmpty || password.trim().isEmpty) return false;

    try {
      final db = await DatabaseService.instance.database;

      final result = await db.query(
        'auth_users',
        where: 'username = ? AND password_hash = ?',
        whereArgs: [username.trim(), _hashPassword(password)],
      );

      if (result.isEmpty) return false;

      // Simpan sesi login
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('username', username.trim());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  Future<String> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? '';
  }
}