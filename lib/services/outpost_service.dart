import 'dart:math';

import 'package:geolocator/geolocator.dart';
import 'package:sqflite/sqflite.dart';

import 'database_service.dart';

class OutpostService {
  static final OutpostService instance =
      OutpostService();


  Future<void> resetOutpost() async {
    final db =
        await DatabaseService.instance.database;

    await db.delete(
      'hunter_outpost',
    );
  }


  Future<Map<String, double>>
      getOrCreateOutpost(
    Position currentPosition,
  ) async {
    Database db =
        await DatabaseService.instance.database;

    final result =
        await db.query('hunter_outpost');

    if (result.isNotEmpty) {
      return {
        'lat':
            result.first['latitude']
                as double,
        'lon':
            result.first['longitude']
                as double,
      };
    }

    final random = Random();

    double distanceMeters =
    (5 + random.nextInt(10))
        .toDouble();

    double angle =
        random.nextDouble() * 2 * pi;

    double latOffset =
        (distanceMeters / 111111) *
            cos(angle);

    double lonOffset =
        (distanceMeters /
                (111111 *
                    cos(currentPosition
                            .latitude *
                        pi /
                        180))) *
            sin(angle);

    double targetLat =
        currentPosition.latitude +
            latOffset;

    double targetLon =
        currentPosition.longitude +
            lonOffset;

    await db.insert(
      'hunter_outpost',
      {
        'id': 1,
        'latitude': targetLat,
        'longitude': targetLon,
      },
    );

    return {
      'lat': targetLat,
      'lon': targetLon,
    };
  }
}
