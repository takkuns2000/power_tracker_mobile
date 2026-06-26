import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:horsepower_tracker_mobile/models/drivetrain.dart';
import 'package:horsepower_tracker_mobile/models/vehicle.dart';
import 'package:horsepower_tracker_mobile/services/gps_service.dart';
import 'package:horsepower_tracker_mobile/services/ps_calculator.dart';
import 'package:horsepower_tracker_mobile/viewmodels/garage_viewmodel.dart';
import 'package:horsepower_tracker_mobile/viewmodels/realtime_viewmodel.dart';
import 'package:horsepower_tracker_mobile/viewmodels/vehicle_selection_viewmodel.dart';
import 'package:mocktail/mocktail.dart';

// ---------------------------------------------------------------------------
// Fake GPS Service
// ---------------------------------------------------------------------------

class _MockGarageViewModel extends Mock implements GarageViewModel {}

class _FakeGpsService extends GpsService {
  GpsPermissionStatus _status = GpsPermissionStatus.unknown;
  Position? _position;

  @override
  GpsPermissionStatus get permissionStatus => _status;

  @override
  Position? get lastPosition => _position;

  @override
  Future<void> initialize() async {}

  void emit(GpsPermissionStatus status, [Position? position]) {
    _status = status;
    _position = position;
    notifyListeners();
  }
}

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

Position _pos({
  double speedMs = 0.0,
  double lat = 35.0,
  double lng = 139.0,
  double altM = 0.0,
  DateTime? time,
}) {
  return Position(
    latitude: lat,
    longitude: lng,
    timestamp: time ?? DateTime(2024),
    accuracy: 5.0,
    altitude: altM,
    altitudeAccuracy: 5.0,
    heading: 0.0,
    headingAccuracy: 0.0,
    speed: speedMs,
    speedAccuracy: 0.5,
  );
}

Vehicle _vehicle({
  int id = 1,
  String name = 'テスト車両',
  double weightKg = 1500,
  Drivetrain drivetrain = Drivetrain.rwd,
}) =>
    Vehicle(
      id: id,
      name: name,
      weightKg: weightKg,
      drivetrain: drivetrain,
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    WidgetsFlutterBinding.ensureInitialized();
  });

  // -------------------------------------------------------------------------
  // PsCalculatorService
  // -------------------------------------------------------------------------

  group('PsCalculatorService', () {
    late PsCalculatorService calc;

    setUp(() => calc = PsCalculatorService());

    test('初回呼び出しは 0.0 を返す', () {
      final result = calc.calculate(
        currentSpeedMs: 10.0,
        currentAltitudeM: 0.0,
        currentTime: DateTime(2024),
        vehicleMassKg: 1500,
        driveEfficiency: Drivetrain.rwd.driveEfficiency,
      );
      expect(result, 0.0);
    });

    test('RWD (η=0.85) 加速時の PS が仕様式と一致する', () {
      // 手計算（集約モデル）:
      //   ΔKE     = 1500 × (25² − 10²) / 2 = 1500 × 525 / 2 = 393750 J
      //   P_wheel = 393750 / 1s = 393750 W
      //   P_engine = 393750 / 0.85 = 463235.29 W
      //   PS       = 463235.29 / 735.49875 = 629.82 PS
      const expected = 629.82;

      final t0 = DateTime(2024);
      final t1 = t0.add(const Duration(seconds: 1));

      calc.calculate(
        currentSpeedMs: 10.0,
        currentAltitudeM: 0.0,
        currentTime: t0,
        vehicleMassKg: 1500,
        driveEfficiency: Drivetrain.rwd.driveEfficiency,
      );

      final ps = calc.calculate(
        currentSpeedMs: 25.0,
        currentAltitudeM: 0.0,
        currentTime: t1,
        vehicleMassKg: 1500,
        driveEfficiency: Drivetrain.rwd.driveEfficiency,
      );

      expect(ps, closeTo(expected, 0.01));
    });

    test('FWD (η=0.90) 加速時の PS が仕様式と一致する', () {
      // 手計算:
      //   ΔKE     = 1500 × (25² − 10²) / 2 = 393750 J
      //   P_engine = 393750 / 1s / 0.90 = 437500 W
      //   PS       = 437500 / 735.49875 = 594.83 PS
      const expected = 594.83;

      final t0 = DateTime(2024);
      final t1 = t0.add(const Duration(seconds: 1));

      calc.calculate(
        currentSpeedMs: 10.0,
        currentAltitudeM: 0.0,
        currentTime: t0,
        vehicleMassKg: 1500,
        driveEfficiency: Drivetrain.fwd.driveEfficiency,
      );

      final ps = calc.calculate(
        currentSpeedMs: 25.0,
        currentAltitudeM: 0.0,
        currentTime: t1,
        vehicleMassKg: 1500,
        driveEfficiency: Drivetrain.fwd.driveEfficiency,
      );

      expect(ps, closeTo(expected, 0.01));
    });

    test('AWD (η=0.80) 加速時の PS が仕様式と一致する', () {
      // 手計算:
      //   ΔKE     = 1500 × (25² − 10²) / 2 = 393750 J
      //   P_engine = 393750 / 1s / 0.80 = 492187.5 W
      //   PS       = 492187.5 / 735.49875 = 669.19 PS
      const expected = 669.19;

      final t0 = DateTime(2024);
      final t1 = t0.add(const Duration(seconds: 1));

      calc.calculate(
        currentSpeedMs: 10.0,
        currentAltitudeM: 0.0,
        currentTime: t0,
        vehicleMassKg: 1500,
        driveEfficiency: Drivetrain.awd.driveEfficiency,
      );

      final ps = calc.calculate(
        currentSpeedMs: 25.0,
        currentAltitudeM: 0.0,
        currentTime: t1,
        vehicleMassKg: 1500,
        driveEfficiency: Drivetrain.awd.driveEfficiency,
      );

      expect(ps, closeTo(expected, 0.01));
    });

    test('減速時は 0.0 を返す', () {
      final t0 = DateTime(2024);
      final t1 = t0.add(const Duration(seconds: 1));

      calc.calculate(
        currentSpeedMs: 25.0,
        currentAltitudeM: 0.0,
        currentTime: t0,
        vehicleMassKg: 1500,
        driveEfficiency: Drivetrain.rwd.driveEfficiency,
      );

      final ps = calc.calculate(
        currentSpeedMs: 10.0,
        currentAltitudeM: 0.0,
        currentTime: t1,
        vehicleMassKg: 1500,
        driveEfficiency: Drivetrain.rwd.driveEfficiency,
      );

      expect(ps, 0.0);
    });

    test('登坂（等速）の PS が仕様式と一致する（PE の η 適用を検証）', () {
      // 手計算（集約モデル・等速だが登坂で正の出力）:
      //   η = 0.85 (RWD)、ΔKE = 0（等速）
      //   climbWork = 1500 × 9.80665 × 5 = 73549.875 J
      //   P_engine  = 73549.875 / 1s / 0.85 = 86529.265 W
      //   PS        = 86529.265 / 735.49875 = 117.65 PS
      //
      //   ※ climbWork に η を付け忘れた場合:
      //   PS = 73549.875 / 735.49875 = 100.0 PS（テストが落ちる）
      const expected = 117.65;

      final t0 = DateTime(2024);
      final t1 = t0.add(const Duration(seconds: 1));

      calc.calculate(
        currentSpeedMs: 20.0,
        currentAltitudeM: 0.0,
        currentTime: t0,
        vehicleMassKg: 1500,
        driveEfficiency: Drivetrain.rwd.driveEfficiency,
      );

      final ps = calc.calculate(
        currentSpeedMs: 20.0,
        currentAltitudeM: 5.0,
        currentTime: t1,
        vehicleMassKg: 1500,
        driveEfficiency: Drivetrain.rwd.driveEfficiency,
      );

      expect(ps, closeTo(expected, 0.01));
    });

    test('reset 後は初回扱いになる（0.0 を返す）', () {
      final t0 = DateTime(2024);
      final t1 = t0.add(const Duration(seconds: 1));

      calc.calculate(
        currentSpeedMs: 10.0,
        currentAltitudeM: 0.0,
        currentTime: t0,
        vehicleMassKg: 1500,
        driveEfficiency: Drivetrain.rwd.driveEfficiency,
      );

      calc.reset();

      final ps = calc.calculate(
        currentSpeedMs: 25.0,
        currentAltitudeM: 0.0,
        currentTime: t1,
        vehicleMassKg: 1500,
        driveEfficiency: Drivetrain.rwd.driveEfficiency,
      );

      expect(ps, 0.0);
    });
  });

  // -------------------------------------------------------------------------
  // RealtimeViewModel
  // -------------------------------------------------------------------------

  group('RealtimeViewModel', () {
    late _FakeGpsService gps;
    late VehicleSelectionViewModel vehicleSelection;
    late _MockGarageViewModel garage;
    late RealtimeViewModel vm;

    setUp(() {
      gps = _FakeGpsService();
      vehicleSelection = VehicleSelectionViewModel();
      garage = _MockGarageViewModel();
      when(() => garage.vehicles).thenReturn(const []);
      vm = RealtimeViewModel(gps, vehicleSelection, garage);
    });

    tearDown(() {
      vm.dispose();
      gps.dispose();
    });

    test('初期状態は全値 null・isGpsActive は false', () {
      expect(vm.ps, isNull);
      expect(vm.speedKmh, isNull);
      expect(vm.latitude, isNull);
      expect(vm.longitude, isNull);
      expect(vm.altitudeM, isNull);
      expect(vm.isGpsActive, false);
      expect(vm.gpsUpdateHz, isNull);
    });

    test('GPS権限なし（denied）は全値 null', () {
      gps.emit(GpsPermissionStatus.denied);
      expect(vm.speedKmh, isNull);
      expect(vm.latitude, isNull);
      expect(vm.isGpsActive, false);
    });

    test('位置更新後に速度・座標が反映される', () {
      gps.emit(
        GpsPermissionStatus.granted,
        _pos(speedMs: 10.0, lat: 35.6762, lng: 139.6503, altM: 20.0),
      );
      expect(vm.speedKmh, closeTo(36.0, 0.1));
      expect(vm.latitude, 35.6762);
      expect(vm.longitude, 139.6503);
      expect(vm.altitudeM, 20.0);
    });

    test('位置更新後に isGpsActive が true になる', () {
      gps.emit(GpsPermissionStatus.granted, _pos(speedMs: 10.0));
      expect(vm.isGpsActive, true);
    });

    test('加速時は ps > 0（RWD）', () {
      final t0 = DateTime(2024);
      final t1 = t0.add(const Duration(seconds: 1));

      vm.selectVehicle(_vehicle(drivetrain: Drivetrain.rwd));
      gps.emit(GpsPermissionStatus.granted, _pos(speedMs: 10.0, time: t0));
      gps.emit(GpsPermissionStatus.granted, _pos(speedMs: 25.0, time: t1));

      expect(vm.ps, greaterThan(0.0));
    });

    test('減速時は ps == 0', () {
      final t0 = DateTime(2024);
      final t1 = t0.add(const Duration(seconds: 1));

      vm.selectVehicle(_vehicle(drivetrain: Drivetrain.rwd));
      gps.emit(GpsPermissionStatus.granted, _pos(speedMs: 25.0, time: t0));
      gps.emit(GpsPermissionStatus.granted, _pos(speedMs: 10.0, time: t1));

      expect(vm.ps, 0.0);
    });

    test('2回目のGPS更新で gpsUpdateHz が設定される', () {
      final t0 = DateTime(2024);
      final t1 = t0.add(const Duration(milliseconds: 100));

      gps.emit(GpsPermissionStatus.granted, _pos(speedMs: 10.0, time: t0));
      expect(vm.gpsUpdateHz, isNull);

      gps.emit(GpsPermissionStatus.granted, _pos(speedMs: 10.0, time: t1));
      expect(vm.gpsUpdateHz, closeTo(10.0, 1.0));
    });

    test('selectVehicle で selectedVehicleId が変わる', () {
      vm.selectVehicle(_vehicle(id: 42, drivetrain: Drivetrain.fwd));
      expect(vm.selectedVehicleId, '42');
    });

    test('selectVehicle(null) で selectedVehicleId が null になる', () {
      vm.selectVehicle(_vehicle());
      vm.selectVehicle(null);
      expect(vm.selectedVehicleId, isNull);
    });

    test('車両を選択すると selectedVehicleId がセットされる', () {
      vm.selectVehicle(Vehicle(
        id: 1,
        name: 'テスト車両',
        weightKg: 1500,
        drivetrain: Drivetrain.fwd,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      ));
      expect(vm.selectedVehicleId, '1');
    });

    test('FWD 車両は RWD より低い PS を返す', () {
      // FWD (η=0.90) は RWD (η=0.85) より η が大きい（損失が少ない）ので、
      // ke2 が小さくなり PS は低くなる
      final t0 = DateTime(2024);
      final t1 = t0.add(const Duration(seconds: 1));

      vm.selectVehicle(_vehicle(drivetrain: Drivetrain.fwd));
      gps.emit(GpsPermissionStatus.granted, _pos(speedMs: 10.0, time: t0));
      gps.emit(GpsPermissionStatus.granted, _pos(speedMs: 25.0, time: t1));
      final psFwd = vm.ps!;

      vm.selectVehicle(_vehicle(drivetrain: Drivetrain.rwd));
      gps.emit(GpsPermissionStatus.granted, _pos(speedMs: 10.0, time: t0));
      gps.emit(GpsPermissionStatus.granted, _pos(speedMs: 25.0, time: t1));
      final psRwd = vm.ps!;

      expect(psFwd, lessThan(psRwd));
    });

    test('AWD 車両は RWD より高い PS を返す', () {
      // AWD (η=0.80) は RWD (η=0.85) より η が小さい（損失が多い）ので、
      // ke2 が大きくなり PS は高くなる
      final t0 = DateTime(2024);
      final t1 = t0.add(const Duration(seconds: 1));

      vm.selectVehicle(_vehicle(drivetrain: Drivetrain.awd));
      gps.emit(GpsPermissionStatus.granted, _pos(speedMs: 10.0, time: t0));
      gps.emit(GpsPermissionStatus.granted, _pos(speedMs: 25.0, time: t1));
      final psAwd = vm.ps!;

      vm.selectVehicle(_vehicle(drivetrain: Drivetrain.rwd));
      gps.emit(GpsPermissionStatus.granted, _pos(speedMs: 10.0, time: t0));
      gps.emit(GpsPermissionStatus.granted, _pos(speedMs: 25.0, time: t1));
      final psRwd = vm.ps!;

      expect(psAwd, greaterThan(psRwd));
    });
  });
}
