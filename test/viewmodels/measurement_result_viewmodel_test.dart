import 'package:flutter_test/flutter_test.dart';
import 'package:horsepower_tracker_mobile/models/drivetrain.dart';
import 'package:horsepower_tracker_mobile/models/gear_ratio.dart';
import 'package:horsepower_tracker_mobile/models/measurement.dart';
import 'package:horsepower_tracker_mobile/models/measurement_data_point.dart';
import 'package:horsepower_tracker_mobile/models/tire_size.dart';
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

Vehicle _vehicle({TireSize? tireSize, List<GearRatio> gearRatios = const []}) =>
    Vehicle(
      id: 1,
      name: 'テスト車',
      weightKg: 1200.0,
      drivetrain: Drivetrain.rwd,
      tireSize: tireSize,
      gearRatios: gearRatios,
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );

Measurement _measurement({
  List<MeasurementDataPoint> dataPoints = const [],
  Vehicle? vehicle,
  double? usedGearRatio,
  double? finalGearRatio,
}) {
  final v = vehicle ?? _vehicle();
  return Measurement(
    vehicleId: 1,
    vehicleName: 'テスト車',
    vehicleWeightKg: 1200.0,
    vehicleSnapshot: v,
    measuredAt: DateTime(2024, 6, 1, 10, 0),
    maxHp: 150.0,
    driveLossCoefficient: 0.15,
    usedGearRatio: usedGearRatio,
    finalGearRatio: finalGearRatio,
    dataPoints: dataPoints,
  );
}

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

  group('torque / RPM（PRO機能）', () {
    // ギア比・タイヤサイズなし → トルク・RPM は null
    test('ギア比・タイヤサイズ未設定のとき hasTorqueData=false', () {
      final dps = [_dp(0, 0), _dp(1000, 60), _dp(2000, 100)];
      final vm = MeasurementResultViewModel(repo, _measurement(dataPoints: dps));
      expect(vm.hasTorqueData, false);
    });

    test('ギア比・タイヤサイズ未設定のとき hasRpmData=false', () {
      final dps = [_dp(0, 0), _dp(1000, 60)];
      final vm = MeasurementResultViewModel(repo, _measurement(dataPoints: dps));
      expect(vm.hasRpmData, false);
    });

    test('ギア比・タイヤサイズ設定済みのとき hasTorqueData=true（加速区間あり）', () {
      final tire = TireSize(widthMm: 205, aspectRatio: 55, rimInch: 16);
      final v = _vehicle(tireSize: tire);
      final dps = [
        _dp(0, 0),
        _dp(1000, 60),
        _dp(2000, 100),
      ];
      final m = _measurement(
        dataPoints: dps,
        vehicle: v,
        usedGearRatio: 2.0,
        finalGearRatio: 4.0,
      );
      final vm = MeasurementResultViewModel(repo, m);
      // 加速区間のps>0となるポイントでトルクが計算される
      expect(vm.hasTorqueData, true);
    });

    test('maxTorqueKgm はデータなしのとき null', () {
      final vm = MeasurementResultViewModel(repo, _measurement());
      expect(vm.maxTorqueKgm, isNull);
    });
  });

  group('graphAxisMode / toggleGraphAxis', () {
    test('初期値は GraphAxisMode.time', () {
      final vm = MeasurementResultViewModel(repo, _measurement());
      expect(vm.graphAxisMode, GraphAxisMode.time);
    });

    test('RPM データなしのとき canToggleRpmAxis=false', () {
      final dps = [_dp(0, 0), _dp(1000, 60)];
      final vm = MeasurementResultViewModel(repo, _measurement(dataPoints: dps));
      expect(vm.canToggleRpmAxis, false);
    });

    test('RPM データなしのとき toggleGraphAxis は何もしない', () {
      final dps = [_dp(0, 0), _dp(1000, 60)];
      final vm = MeasurementResultViewModel(repo, _measurement(dataPoints: dps));
      vm.toggleGraphAxis();
      expect(vm.graphAxisMode, GraphAxisMode.time);
    });

    test('RPM データありのとき toggleGraphAxis で time→rpm→time と切り替わる', () {
      final tire = TireSize(widthMm: 205, aspectRatio: 55, rimInch: 16);
      final v = _vehicle(tireSize: tire);
      final dps = [_dp(0, 0), _dp(1000, 60), _dp(2000, 100)];
      final m = _measurement(
        dataPoints: dps,
        vehicle: v,
        usedGearRatio: 2.0,
        finalGearRatio: 4.0,
      );
      final vm = MeasurementResultViewModel(repo, m);

      expect(vm.graphAxisMode, GraphAxisMode.time);
      vm.toggleGraphAxis();
      expect(vm.graphAxisMode, GraphAxisMode.rpm);
      vm.toggleGraphAxis();
      expect(vm.graphAxisMode, GraphAxisMode.time);
    });
  });

  group('rpmChartPoints', () {
    test('RPM データなしのとき空リストを返す', () {
      final dps = [_dp(0, 0), _dp(1000, 60)];
      final vm = MeasurementResultViewModel(repo, _measurement(dataPoints: dps));
      expect(vm.rpmChartPoints, isEmpty);
    });

    test('RPM が単調増加するとき全点を返す', () {
      final tire = TireSize(widthMm: 205, aspectRatio: 55, rimInch: 16);
      final v = _vehicle(tireSize: tire);
      final dps = [_dp(0, 0), _dp(1000, 60), _dp(2000, 100), _dp(3000, 140)];
      final m = _measurement(
        dataPoints: dps,
        vehicle: v,
        usedGearRatio: 2.0,
        finalGearRatio: 4.0,
      );
      final vm = MeasurementResultViewModel(repo, m);
      expect(
        vm.rpmChartPoints.length,
        vm.hpValues.where((p) => p.rpm != null).length,
      );
    });

    test('RPM が落ち込む区間は除外される', () {
      final tire = TireSize(widthMm: 205, aspectRatio: 55, rimInch: 16);
      final v = _vehicle(tireSize: tire);
      final dps = [
        _dp(0, 0),
        _dp(1000, 60),
        _dp(2000, 100),
        _dp(3000, 60),
        _dp(4000, 140),
      ];
      final m = _measurement(
        dataPoints: dps,
        vehicle: v,
        usedGearRatio: 2.0,
        finalGearRatio: 4.0,
      );
      final vm = MeasurementResultViewModel(repo, m);
      final pts = vm.rpmChartPoints;
      for (int i = 1; i < pts.length; i++) {
        expect(pts[i].rpm! > pts[i - 1].rpm!, isTrue);
      }
    });

    test('rpmChartPoints の RPM は常に単調増加', () {
      final tire = TireSize(widthMm: 205, aspectRatio: 55, rimInch: 16);
      final v = _vehicle(tireSize: tire);
      final dps = [
        _dp(0, 0),
        _dp(1000, 60),
        _dp(2000, 100),
        _dp(3000, 60),
        _dp(4000, 140),
      ];
      final m = _measurement(
        dataPoints: dps,
        vehicle: v,
        usedGearRatio: 2.0,
        finalGearRatio: 4.0,
      );
      final vm = MeasurementResultViewModel(repo, m);
      final rpms = vm.rpmChartPoints.map((p) => p.rpm!).toList();
      for (int i = 1; i < rpms.length; i++) {
        expect(rpms[i] > rpms[i - 1], isTrue);
      }
    });
  });

  group('toggleLossOverride の selectedPointNotifier', () {
    test('time モード時は selectedPoint が offsetMs で引き継がれる', () {
      final dps = [_dp(0, 0), _dp(1000, 60), _dp(2000, 100)];
      final vm = MeasurementResultViewModel(repo, _measurement(dataPoints: dps));
      vm.selectChartPoint(vm.hpValues[1]);
      vm.toggleLossOverride();
      expect(vm.selectedPointNotifier.value?.offsetMs, 1000);
    });

    test('rpm モード時は selectedPoint が null にクリアされる', () {
      final tire = TireSize(widthMm: 205, aspectRatio: 55, rimInch: 16);
      final v = _vehicle(tireSize: tire);
      final dps = [_dp(0, 0), _dp(1000, 60), _dp(2000, 100)];
      final m = _measurement(
        dataPoints: dps,
        vehicle: v,
        usedGearRatio: 2.0,
        finalGearRatio: 4.0,
      );
      final vm = MeasurementResultViewModel(repo, m);
      vm.toggleGraphAxis();
      vm.selectChartPoint(vm.hpValues[1]);
      vm.toggleLossOverride();
      expect(vm.selectedPointNotifier.value, isNull);
    });
  });
}
