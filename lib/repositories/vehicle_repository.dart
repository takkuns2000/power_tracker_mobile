import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../models/drivetrain.dart';
import '../models/gear_ratio.dart';
import '../models/tire_size.dart';
import '../models/vehicle.dart';
import '../services/database_service.dart';

class VehicleRepository {
  VehicleRepository(this._db);

  final DatabaseService _db;

  Future<List<Vehicle>> getAll() async {
    debugPrint('[VehicleRepository] getAll start');
    final rows = await _db.database.query(
      'vehicles',
      where: 'is_deleted = 0',
      orderBy: 'created_at ASC',
    );
    final vehicles = <Vehicle>[];
    for (final row in rows) {
      final id = row['id'] as int;
      final gearRows = await _db.database.query(
        'gear_ratios',
        where: 'vehicle_id = ?',
        whereArgs: [id],
      );
      vehicles.add(_fromRow(row, gearRows));
    }
    debugPrint('[VehicleRepository] getAll done: ${vehicles.length} vehicles');
    return vehicles;
  }

  Future<Vehicle?> getById(int id) async {
    final rows = await _db.database.query(
      'vehicles',
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final gearRows = await _db.database.query(
      'gear_ratios',
      where: 'vehicle_id = ?',
      whereArgs: [id],
    );
    return _fromRow(rows.first, gearRows);
  }

  Future<Vehicle> insert(Vehicle vehicle) async {
    debugPrint('[VehicleRepository] insert: ${vehicle.name}');
    final now = DateTime.now();
    final v = vehicle.copyWith(createdAt: now, updatedAt: now);
    late int id;
    await _db.database.transaction((txn) async {
      id = await txn.insert('vehicles', _toRow(v));
      await _insertGearRatios(txn, id, v.gearRatios);
    });
    debugPrint('[VehicleRepository] insert done: id=$id');
    return v.copyWith(id: id);
  }

  Future<void> update(Vehicle vehicle) async {
    debugPrint('[VehicleRepository] update: id=${vehicle.id}');
    assert(vehicle.id != null);
    final v = vehicle.copyWith(updatedAt: DateTime.now());
    await _db.database.transaction((txn) async {
      await txn.update(
        'vehicles',
        _toRow(v),
        where: 'id = ?',
        whereArgs: [v.id],
      );
      await txn.delete(
        'gear_ratios',
        where: 'vehicle_id = ?',
        whereArgs: [v.id],
      );
      await _insertGearRatios(txn, v.id!, v.gearRatios);
    });
  }

  Future<void> delete(int id) async {
    debugPrint('[VehicleRepository] delete: id=$id');
    await _db.database.update(
      'vehicles',
      {
        'is_deleted': 1,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> _insertGearRatios(
    DatabaseExecutor executor,
    int vehicleId,
    List<GearRatio> gears,
  ) async {
    for (final gear in gears) {
      await executor.insert('gear_ratios', {
        'vehicle_id': vehicleId,
        'gear_number': gear.gearNumber,
        'ratio': gear.ratio,
      });
    }
  }

  Vehicle _fromRow(
    Map<String, dynamic> row,
    List<Map<String, dynamic>> gearRows,
  ) {
    final tireCols = [
      row['tire_width_mm'],
      row['tire_aspect_ratio'],
      row['tire_rim_inch'],
    ];
    final tireSize = tireCols.every((v) => v != null)
        ? TireSize(
            widthMm: row['tire_width_mm'] as int,
            aspectRatio: row['tire_aspect_ratio'] as int,
            rimInch: row['tire_rim_inch'] as int,
          )
        : null;

    final drivetrainIndex = row['drivetrain'] as int? ?? 0;
    final drivetrain = Drivetrain.values[drivetrainIndex];

    final gearRatios = gearRows
        .map((g) => GearRatio(
              id: g['id'] as int?,
              vehicleId: g['vehicle_id'] as int,
              gearNumber: g['gear_number'] as int,
              ratio: (g['ratio'] as num).toDouble(),
            ))
        .toList();

    return Vehicle(
      id: row['id'] as int?,
      name: row['name'] as String,
      modelCode: row['model_code'] as String?,
      weightKg: row['weight_kg'] as double,
      drivetrain: drivetrain,
      displacementCc: row['displacement_cc'] as int?,
      memo: row['memo'] as String?,
      tireSize: tireSize,
      gearRatios: gearRatios,
      imagePath: row['image_path'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(row['updated_at'] as int),
      isDeleted: (row['is_deleted'] as int) == 1,
    );
  }

  Map<String, dynamic> _toRow(Vehicle v) => {
        'name': v.name,
        'model_code': v.modelCode,
        'weight_kg': v.weightKg,
        'memo': v.memo,
        'drivetrain': v.drivetrain.index,
        'displacement_cc': v.displacementCc,
        'tire_width_mm': v.tireSize?.widthMm,
        'tire_aspect_ratio': v.tireSize?.aspectRatio,
        'tire_rim_inch': v.tireSize?.rimInch,
        'image_path': v.imagePath,
        'created_at': v.createdAt.millisecondsSinceEpoch,
        'updated_at': v.updatedAt.millisecondsSinceEpoch,
        'is_deleted': v.isDeleted ? 1 : 0,
      };
}
