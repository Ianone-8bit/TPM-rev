import 'package:sqflite/sqflite.dart';

import 'database_service.dart';
import '../models/mission.dart';
import 'mission_service.dart';

class MissionDbService {
  static final MissionDbService instance =
      MissionDbService();

  Future<void> saveStatus(
      int missionId,
      String status) async {
    Database db =
        await DatabaseService.instance.database;

    await db.insert(
      'missions',
      {
        'id': missionId,
        'status': status,
      },
      conflictAlgorithm:
          ConflictAlgorithm.replace,
    );
  }

  Future<String?> getStatus(
      int missionId) async {
    Database db =
        await DatabaseService.instance.database;

    final result = await db.query(
      'missions',
      where: 'id=?',
      whereArgs: [missionId],
    );

    if (result.isEmpty) return null;

    return result.first['status']
        as String;
  }

  Future<void> resetDailyMissions() async {
  final db =
      await DatabaseService.instance.database;

  final dailyMissions =
      MissionService.instance.missions
          .where(
            (m) =>
                m.type ==
                MissionType.daily,
          )
          .toList();

  for (final mission
      in dailyMissions) {
    await db.delete(
      'missions',
      where: 'id = ?',
      whereArgs: [mission.id],
    );

    mission.status =
        MissionStatus.available;
  }
}

Future<void> resetWeeklyMissions() async {
  final db =
      await DatabaseService.instance.database;

  final weeklyMissions =
      MissionService.instance.missions
          .where(
            (m) =>
                m.type ==
                MissionType.weekly,
          )
          .toList();

  for (final mission
      in weeklyMissions) {
    await db.delete(
      'missions',
      where: 'id = ?',
      whereArgs: [mission.id],
    );

    mission.status =
        MissionStatus.available;
  }
}
}