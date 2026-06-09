import 'package:sqflite/sqflite.dart';

import 'database_service.dart';

class HunterService {
  static final HunterService instance =
      HunterService();

  Future<Map<String, dynamic>?> getHunter(
      String username) async {
    Database db =
        await DatabaseService.instance.database;

    final result = await db.query(
      'users',
      where: 'username=?',
      whereArgs: [username],
    );

    if (result.isEmpty) {
      return null;
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