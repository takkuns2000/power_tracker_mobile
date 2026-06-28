import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  Database? _db;

  Database get database {
    assert(_db != null, 'DatabaseService.initialize() が未実行です');
    return _db!;
  }

  Future<void> initialize({String? path}) async {
    debugPrint('[DatabaseService] initialize start');
    final dbPath =
        path ?? join(await getDatabasesPath(), 'horsepower_tracker.db');
    debugPrint('[DatabaseService] db path: $dbPath');
    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: _onCreate,
    );
    debugPrint('[DatabaseService] initialize done');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE vehicles (
        id                INTEGER PRIMARY KEY AUTOINCREMENT,
        name              TEXT    NOT NULL,
        model_code        TEXT,
        weight_kg         REAL    NOT NULL,
        memo              TEXT,
        drivetrain        INTEGER NOT NULL DEFAULT 0,
        displacement_cc   INTEGER,
        tire_width_mm     INTEGER,
        tire_aspect_ratio INTEGER,
        tire_rim_inch     INTEGER,
        image_path        TEXT,
        created_at        INTEGER NOT NULL,
        updated_at        INTEGER NOT NULL,
        is_deleted        INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE gear_ratios (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicle_id  INTEGER NOT NULL,
        gear_number INTEGER NOT NULL,
        ratio       REAL    NOT NULL,
        FOREIGN KEY (vehicle_id) REFERENCES vehicles(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE measurements (
        id                     INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicle_id             INTEGER,
        vehicle_name           TEXT    NOT NULL,
        vehicle_weight_kg      REAL    NOT NULL,
        vehicle_snapshot_json  TEXT    NOT NULL,
        measured_at            INTEGER NOT NULL,
        max_hp                 REAL    NOT NULL,
        temperature_celsius    REAL,
        pressure_hpa           REAL,
        final_gear_ratio       REAL,
        used_gear_ratio        REAL,
        drive_loss_coefficient REAL    NOT NULL DEFAULT 0.15,
        memo                   TEXT,
        FOREIGN KEY (vehicle_id) REFERENCES vehicles(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE measurement_data_points (
        id             INTEGER PRIMARY KEY AUTOINCREMENT,
        measurement_id INTEGER NOT NULL,
        offset_ms      INTEGER NOT NULL,
        speed_kmh      REAL    NOT NULL,
        latitude       REAL    NOT NULL,
        longitude      REAL    NOT NULL,
        altitude_m     REAL    NOT NULL,
        accuracy_m     REAL    NOT NULL,
        FOREIGN KEY (measurement_id) REFERENCES measurements(id)
      )
    ''');
  }

  void dispose() {
    _db?.close();
  }
}
