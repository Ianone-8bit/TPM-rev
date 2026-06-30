import 'package:sqflite/sqflite.dart';

import 'database_service.dart';

class HunterService {
  static final HunterService instance = HunterService();

  /// Ambil data hunter, auto-buat row baru jika belum ada
  Future<Map<String, dynamic>?> getHunter(String username) async {
    if (username.isEmpty) return null;
    Database db = await DatabaseService.instance.database;

    final result = await db.query(
      'users',
      where: 'username=?',
      whereArgs: [username],
    );

    if (result.isEmpty) {
      // Buat data awal untuk user baru
      await db.insert('users', {
        'username': username,
        'level': 1,
        'exp': 0,
        'gold': 0,
      });
      return {'username': username, 'level': 1, 'exp': 0, 'gold': 0};
    }

    return result.first;
  }

  Future<void> addExp(
    String username,
    int expGain,
  ) async {
    Database db =
        await DatabaseService.instance.database;

    final hunter =
        await getHunter(username);

    if (hunter == null) return;

    int exp =
        hunter['exp'] + expGain;

    int level =
        hunter['level'];

    while (exp >= 100) {
      exp -= 100;
      level++;
    }

    await db.update(
      'users',
      {
        'exp': exp,
        'level': level,
      },
      where: 'username=?',
      whereArgs: [username],
    );
  }

  Future<void> addGold(
    String username,
    int goldGain,
  ) async {
    Database db =
        await DatabaseService.instance.database;

    final hunter =
        await getHunter(username);

    if (hunter == null) return;

    await db.update(
      'users',
      {
        'gold':
            hunter['gold'] + goldGain,
      },
      where: 'username=?',
      whereArgs: [username],
    );
  }
}