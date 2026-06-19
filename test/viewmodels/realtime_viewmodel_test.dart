import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:horsepower_tracker_mobile/models/vehicle.dart';
import 'package:horsepower_tracker_mobile/services/gps_service.dart';
import 'package:horsepower_tracker_mobile/services/ps_calculator.dart';
import 'package:horsepower_tracker_mobile/viewmodels/realtime_viewmodel.dart';

// ---------------------------------------------------------------------------
// Fake GPS Service
// ---------------------------------------------------------------------------

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
      );
      expect(result, 0.0);
    });

    test('加速時の PS が仕様式と一致する', () {
      // 手計算（仕様書の式から独立して算出）:
      //   ke2 = 1500 × 25² / (2 × 0.85) = 937500 / 1.7 = 551470.588 J
      //   ke1 = 1500 × 10² / 2           = 75000 J
      //   PE  = 0（Δh=0）
      //   PS  = (551470.588 - 75000) / 1s / 735.49875 = 647.82 PS
      const expected = 647.82;

      final t0 = DateTime(2024);
      final t1 = t0.add(const Duration(seconds: 1));

      calc.calculate(
          currentSpeedMs: 10.0,
          currentAltitudeM: 0.0,
          currentTime: t0,
          vehicleMassKg: 1500);

      final ps = calc.calculate(
          currentSpeedMs: 25.0,
          currentAltitudeM: 0.0,
          currentTime: t1,
          vehicleMassKg: 1500);

      expect(ps, closeTo(expected, 0.01));
    });

    test('減速時は 0.0 を返す', () {
      final t0 = DateTime(2024);
      final t1 = t0.add(const Duration(seconds: 1));

      calc.calculate(
          currentSpeedMs: 25.0,
          currentAltitudeM: 0.0,
          currentTime: t0,
          vehicleMassKg: 1500);

      final ps = calc.calculate(
          currentSpeedMs: 10.0,
          currentAltitudeM: 0.0,
          currentTime: t1,
          vehicleMassKg: 1500);

      expect(ps, 0.0);
    });

    test('登坂（等速）の PS が仕様式と一致する（PE の η 適用を検証）', () {
      // 手計算（仕様書の式から独立して算出）:
      //   ke2 = 1500 × 20² / (2 × 0.85) = 600000 / 1.7 = 352941.176 J
      //   ke1 = 1500 × 20² / 2           = 300000 J
      //   PE  = 1500 × 9.80665 × 5 / 0.85 = 73549.875 / 0.85 = 86529.265 J
      //   PS  = (52941.176 + 86529.265) / 1s / 735.49875 = 189.63 PS
      //
      //   ※ PE に η を付け忘れた場合:
      //   PE  = 1500 × 9.80665 × 5 = 73549.875 J → PS ≈ 171.91 PS（テストが落ちる）
      const expected = 189.63;

      final t0 = DateTime(2024);
      final t1 = t0.add(const Duration(seconds: 1));

      calc.calculate(
          currentSpeedMs: 20.0,
          currentAltitudeM: 0.0,
          currentTime: t0,
          vehicleMassKg: 1500);

      final ps = calc.calculate(
          currentSpeedMs: 20.0,
          currentAltitudeM: 5.0,
          currentTime: t1,
          vehicleMassKg: 1500);

      expect(ps, closeTo(expected, 0.01));
    });

    test('reset 後は初回扱いになる（0.0 を返す）', () {
      final t0 = DateTime(2024);
      final t1 = t0.add(const Duration(seconds: 1));

      calc.calculate(
          currentSpeedMs: 10.0,
          currentAltitudeM: 0.0,
          currentTime: t0,
          vehicleMassKg: 1500);

      calc.reset();

      final ps = calc.calculate(
          currentSpeedMs: 25.0,
          currentAltitudeM: 0.0,
          currentTime: t1,
          vehicleMassKg: 1500);

      expect(ps, 0.0);
    });
  });

  // -------------------------------------------------------------------------
  // RealtimeViewModel
  // -------------------------------------------------------------------------

  group('RealtimeViewModel', () {
    late _FakeGpsService gps;
    late RealtimeViewModel vm;

    setUp(() {
      gps = _FakeGpsService();
      vm = RealtimeViewModel(gps);
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

    test('加速時は horsepower > 0', () {
      final t0 = DateTime(2024);
      final t1 = t0.add(const Duration(seconds: 1));

      vm.selectVehicle(Vehicle(
          id: 1,
          name: 'A',
          weightKg: 1500,
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024)));

      gps.emit(GpsPermissionStatus.granted, _pos(speedMs: 10.0, time: t0));
      gps.emit(GpsPermissionStatus.granted, _pos(speedMs: 25.0, time: t1));

      expect(vm.ps, greaterThan(0.0));
    });

    test('減速時は horsepower == 0', () {
      final t0 = DateTime(2024);
      final t1 = t0.add(const Duration(seconds: 1));

      vm.selectVehicle(Vehicle(
          id: 1,
          name: 'A',
          weightKg: 1500,
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024)));

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
      final v = Vehicle(
        id: 42,
        name: 'テスト車両',
        weightKg: 1200,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );
      vm.selectVehicle(v);
      expect(vm.selectedVehicleId, '42');
    });

    test('selectVehicle(null) で selectedVehicleId が null になる', () {
      vm.selectVehicle(Vehicle(
          id: 1,
          name: 'A',
          weightKg: 1000,
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024)));
      vm.selectVehicle(null);
      expect(vm.selectedVehicleId, isNull);
    });
  });
}
