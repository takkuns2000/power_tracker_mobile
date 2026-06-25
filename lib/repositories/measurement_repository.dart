import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/measurement.dart';
import '../models/measurement_data_point.dart';
import '../models/vehicle.dart';
import '../services/database_service.dart';

class MeasurementRepository {
  MeasurementRepository(this._db);

  final DatabaseService _db;

  Future<List<Measurement>> getAll() async {
    final rows = await _db.database.query(
      'measurements',
      orderBy: 'measured_at DESC',
    );
    final results = <Measurement>[];
    for (final row in rows) {
      final id = row['id'] as int;
      final dataPointRows = await _db.database.query(
        'measurement_data_points',
        where: 'measurement_id = ?',
        whereArgs: [id],
        orderBy: 'offset_ms ASC',
      );
      results.add(_fromRow(row, dataPointRows));
    }
    return results;
  }

  Future<Measurement?> getById(int id) async {
    final rows = await _db.database.query(
      'measurements',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final dataPointRows = await _db.database.query(
      'measurement_data_points',
      where: 'measurement_id = ?',
      whereArgs: [id],
      orderBy: 'offset_ms ASC',
    );
    return _fromRow(rows.first, dataPointRows);
  }

  Future<Measurement> insert(Measurement measurement) async {
    late int id;
    await _db.database.transaction((txn) async {
      id = await txn.insert('measurements', _toRow(measurement));
      for (final dp in measurement.dataPoints) {
        await txn.insert('measurement_data_points', _dataPointToRow(dp.copyWith(measurementId: id)));
      }
    });
    debugPrint('[MeasurementRepository] insert done: id=$id, dataPoints=${measurement.dataPoints.length}');
    return measurement.copyWith(id: id);
  }

  Future<void> updateMemo(int id, String? memo) async {
    await _db.database.update(
      'measurements',
      {'memo': memo},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateDriveLossCoefficient(int id, double coefficient) async {
    await _db.database.update(
      'measurements',
      {'drive_loss_coefficient': coefficient},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> delete(int id) async {
    debugPrint('[MeasurementRepository] delete: id=$id');
    await _db.database.transaction((txn) async {
      await txn.delete('measurement_data_points',
          where: 'measurement_id = ?', whereArgs: [id]);
      await txn.delete('measurements', where: 'id = ?', whereArgs: [id]);
    });
  }

  Measurement _fromRow(
    Map<String, dynamic> row,
    List<Map<String, dynamic>> dataPointRows,
  ) {
    final snapshotJson = jsonDecode(row['vehicle_snapshot_json'] as String) as Map<String, dynamic>;
    final vehicleSnapshot = Vehicle.fromJson(snapshotJson);

    final dataPoints = dataPointRows
        .map((dp) => MeasurementDataPoint(
              id: dp['id'] as int?,
              measurementId: dp['measurement_id'] as int,
              offsetMs: dp['offset_ms'] as int,
              speedKmh: (dp['speed_kmh'] as num).toDouble(),
              latitude: (dp['latitude'] as num).toDouble(),
              longitude: (dp['longitude'] as num).toDouble(),
              altitudeM: (dp['altitude_m'] as num).toDouble(),
              accuracyM: (dp['accuracy_m'] as num).toDouble(),
            ))
        .toList();

    return Measurement(
      id: row['id'] as int?,
      vehicleId: row['vehicle_id'] as int?,
      vehicleName: row['vehicle_name'] as String,
      vehicleWeightKg: (row['vehicle_weight_kg'] as num).toDouble(),
      vehicleSnapshot: vehicleSnapshot,
      measuredAt: DateTime.fromMillisecondsSinceEpoch(row['measured_at'] as int),
      maxHp: (row['max_hp'] as num).toDouble(),
      temperatureCelsius: (row['temperature_celsius'] as num?)?.toDouble(),
      pressureHpa: (row['pressure_hpa'] as num?)?.toDouble(),
      finalGearRatio: (row['final_gear_ratio'] as num?)?.toDouble(),
      usedGearRatio: (row['used_gear_ratio'] as num?)?.toDouble(),
      driveLossCoefficient: (row['drive_loss_coefficient'] as num).toDouble(),
      memo: row['memo'] as String?,
      dataPoints: dataPoints,
    );
  }

  Map<String, dynamic> _toRow(Measurement m) => {
        'vehicle_id': m.vehicleId,
        'vehicle_name': m.vehicleName,
        'vehicle_weight_kg': m.vehicleWeightKg,
        'vehicle_snapshot_json': jsonEncode(m.vehicleSnapshot.toJson()),
        'measured_at': m.measuredAt.millisecondsSinceEpoch,
        'max_hp': m.maxHp,
        'temperature_celsius': m.temperatureCelsius,
        'pressure_hpa': m.pressureHpa,
        'final_gear_ratio': m.finalGearRatio,
        'used_gear_ratio': m.usedGearRatio,
        'drive_loss_coefficient': m.driveLossCoefficient,
        'memo': m.memo,
      };

  Map<String, dynamic> _dataPointToRow(MeasurementDataPoint dp) => {
        'measurement_id': dp.measurementId,
        'offset_ms': dp.offsetMs,
        'speed_kmh': dp.speedKmh,
        'latitude': dp.latitude,
        'longitude': dp.longitude,
        'altitude_m': dp.altitudeM,
        'accuracy_m': dp.accuracyM,
      };
}
