import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horsepower_tracker_mobile/models/drivetrain.dart';
import 'package:horsepower_tracker_mobile/models/measurement.dart';
import 'package:horsepower_tracker_mobile/models/measurement_data_point.dart';
import 'package:horsepower_tracker_mobile/models/vehicle.dart';
import 'package:horsepower_tracker_mobile/repositories/measurement_repository.dart';
import 'package:horsepower_tracker_mobile/services/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

late DatabaseService _db;
late MeasurementRepository _repo;

Vehicle _vehicle() => Vehicle(
      id: 1,
      name: 'テスト車',
      weightKg: 1200.0,
      drivetrain: Drivetrain.rwd,
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );

Measurement _measurement({List<MeasurementDataPoint> dataPoints = const []}) =>
    Measurement(
      vehicleId: 1,
      vehicleName: 'テスト車',
      vehicleWeightKg: 1200.0,
      vehicleSnapshot: _vehicle(),
      measuredAt: DateTime(2024, 6, 1, 10, 0),
      maxHp: 150.0,
      driveLossCoefficient: 0.15,
      dataPoints: dataPoints,
    );

MeasurementDataPoint _dp(int offsetMs, double speedKmh) =>
    MeasurementDataPoint(
      measurementId: 0,
      offsetMs: offsetMs,
      speedKmh: speedKmh,
      latitude: 35.0,
      longitude: 139.0,
      altitudeM: 10.0,
      accuracyM: 5.0,
    );

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  setUp(() async {
    _db = DatabaseService();
    await _db.initialize(path: inMemoryDatabasePath);
    _repo = MeasurementRepository(_db);
  });

  tearDown(() => _db.dispose());

  group('insert', () {
    test('保存した Measurement に id が付与される', () async {
      final saved = await _repo.insert(_measurement());
      expect(saved.id, isNotNull);
    });

    test('dataPoints も一緒に保存される', () async {
      final m = _measurement(dataPoints: [
        _dp(0, 0),
        _dp(1000, 30),
        _dp(2000, 60),
      ]);
      final saved = await _repo.insert(m);
      final loaded = await _repo.getById(saved.id!);
      expect(loaded!.dataPoints, hasLength(3));
    });

    test('vehicleSnapshot の drivetrain が正しく復元される', () async {
      final saved = await _repo.insert(_measurement());
      final loaded = await _repo.getById(saved.id!);
      expect(loaded!.vehicleSnapshot.drivetrain, Drivetrain.rwd);
    });
  });

  group('getAll', () {
    test('複数件保存して全件取得できる', () async {
      await _repo.insert(_measurement());
      await _repo.insert(_measurement());
      final all = await _repo.getAll();
      expect(all, hasLength(2));
    });

    test('measured_at の降順で返る', () async {
      final m1 = _measurement().copyWith(measuredAt: DateTime(2024, 1, 1));
      final m2 = _measurement().copyWith(measuredAt: DateTime(2024, 6, 1));
      await _repo.insert(m1);
      await _repo.insert(m2);
      final all = await _repo.getAll();
      expect(all.first.measuredAt, DateTime(2024, 6, 1));
    });
  });

  group('getById', () {
    test('存在しない id は null を返す', () async {
      final result = await _repo.getById(9999);
      expect(result, isNull);
    });

    test('保存した measurement を id で取得できる', () async {
      final saved = await _repo.insert(_measurement());
      final loaded = await _repo.getById(saved.id!);
      expect(loaded, isNotNull);
      expect(loaded!.vehicleName, 'テスト車');
    });
  });

  group('updateMemo', () {
    test('メモを更新できる', () async {
      final saved = await _repo.insert(_measurement());
      await _repo.updateMemo(saved.id!, 'テストメモ');
      final loaded = await _repo.getById(saved.id!);
      expect(loaded!.memo, 'テストメモ');
    });

    test('null を渡すとメモが消える', () async {
      final saved = await _repo.insert(_measurement());
      await _repo.updateMemo(saved.id!, 'メモ');
      await _repo.updateMemo(saved.id!, null);
      final loaded = await _repo.getById(saved.id!);
      expect(loaded!.memo, isNull);
    });
  });

  group('updateDriveLossCoefficient', () {
    test('駆動ロス係数を更新できる', () async {
      final saved = await _repo.insert(_measurement());
      await _repo.updateDriveLossCoefficient(saved.id!, 0.20);
      final loaded = await _repo.getById(saved.id!);
      expect(loaded!.driveLossCoefficient, closeTo(0.20, 0.0001));
    });
  });
}
