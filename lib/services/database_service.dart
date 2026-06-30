import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._();
  DatabaseService._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    if (kIsWeb) {
      // Web: gunakan sqflite_common_ffi_web
      databaseFactory = databaseFactoryFfiWeb;
    } else {
      // Desktop (Windows / Linux / macOS): gunakan FFI
      switch (defaultTargetPlatform) {
        case TargetPlatform.windows:
        case TargetPlatform.linux:
        case TargetPlatform.macOS:
          sqfliteFfiInit();
          databaseFactory = databaseFactoryFfi;
          break;
        default:
          // Android / iOS: sqflite bawaan, tidak perlu inisialisasi manual
          break;
      }
    }

    String path = 'growup.db';
    if (!kIsWeb) {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, 'growup.db');
    }

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabel autentikasi lokal
    await db.execute('''
      CREATE TABLE IF NOT EXISTS auth_users (
        username      TEXT PRIMARY KEY,
        password_hash TEXT NOT NULL
      )
    ''');

    // Tabel data progress user
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        username   TEXT PRIMARY KEY,
        level      INTEGER NOT NULL DEFAULT 1,
        exp        INTEGER NOT NULL DEFAULT 0,
        gold       INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Tabel status kebiasaan/habit
    await db.execute('''
      CREATE TABLE IF NOT EXISTS missions (
        id     INTEGER PRIMARY KEY,
        status TEXT NOT NULL DEFAULT 'available'
      )
    ''');

    // Tabel lokasi check-in spot
    await db.execute('''
      CREATE TABLE IF NOT EXISTS hunter_outpost (
        id        INTEGER PRIMARY KEY,
        latitude  REAL NOT NULL,
        longitude REAL NOT NULL
      )
    ''');
  }
}
