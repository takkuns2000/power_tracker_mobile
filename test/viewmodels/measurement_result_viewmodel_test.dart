import 'package:flutter_test/flutter_test.dart';
import 'package:horsepower_tracker_mobile/models/drivetrain.dart';
import 'package:horsepower_tracker_mobile/models/measurement.dart';
import 'package:horsepower_tracker_mobile/models/measurement_data_point.dart';
import 'package:horsepower_tracker_mobile/models/vehicle.dart';
import 'package:horsepower_tracker_mobile/repositories/measurement_repository.dart';
import 'package:horsepower_tracker_mobile/services/database_service.dart';
import 'package:horsepower_tracker_mobile/viewmodels/measurement_result_viewmodel.dart';

class _FakeMeasurementRepository extends MeasurementRepository {
  _FakeMeasurementRepository() : super(DatabaseService());

  @override
  Future<void> updateMemo(int id, String? memo) async {}

  @override
  Future<void> updateDriveLossCoefficient(int id, double c) async {}
}

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
  late _FakeMeasurementRepository repo;

  setUp(() {
    repo = _FakeMeasurementRepository();
  });

  group('hpValues', () {
    test('データ点が0件のとき空リストを返す', () {
      final vm = MeasurementResultViewModel(repo, _measurement());
      expect(vm.hpValues, isEmpty);
    });

    test('データ点が1件のとき要素1つのリストを返す（初回ps=0.0）', () {
      final vm = MeasurementResultViewModel(
        repo,
        _measurement(dataPoints: [_dp(0, 0)]),
      );
      expect(vm.hpValues.length, 1);
      expect(vm.hpValues[0].offsetMs, 0);
      expect(vm.hpValues[0].ps, 0.0);
    });

    test('hpValues の各要素の offsetMs が dataPoints の offsetMs と一致する', () {
      final dps = [_dp(0, 0), _dp(1000, 60), _dp(3000, 100)];
      final vm = MeasurementResultViewModel(repo, _measurement(dataPoints: dps));

      expect(vm.hpValues.length, 3);
      expect(vm.hpValues[0].offsetMs, 0);
      expect(vm.hpValues[1].offsetMs, 1000);
      expect(vm.hpValues[2].offsetMs, 3000);
    });

    test('不均等な offsetMs でも正しく保持される', () {
      // 間隔: 500ms, 4500ms（不均等）
      final dps = [_dp(0, 0), _dp(500, 60), _dp(5000, 100)];
      final vm = MeasurementResultViewModel(repo, _measurement(dataPoints: dps));

      expect(vm.hpValues[1].offsetMs, 500);
      expect(vm.hpValues[2].offsetMs, 5000);
    });

    test('ps は double 型である', () {
      final dps = [_dp(0, 0), _dp(1000, 60)];
      final vm = MeasurementResultViewModel(repo, _measurement(dataPoints: dps));

      for (final p in vm.hpValues) {
        expect(p.ps, isA<double>());
      }
    });
  });
}
