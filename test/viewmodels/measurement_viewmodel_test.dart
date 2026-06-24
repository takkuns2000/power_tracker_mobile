import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:horsepower_tracker_mobile/models/drivetrain.dart';
import 'package:horsepower_tracker_mobile/models/measurement.dart';
import 'package:horsepower_tracker_mobile/models/vehicle.dart';
import 'package:horsepower_tracker_mobile/repositories/measurement_repository.dart';
import 'package:horsepower_tracker_mobile/services/database_service.dart';
import 'package:horsepower_tracker_mobile/services/gps_service.dart';
import 'package:horsepower_tracker_mobile/viewmodels/measurement_viewmodel.dart';
import 'package:horsepower_tracker_mobile/viewmodels/vehicle_selection_viewmodel.dart';

class _FakeGpsService extends GpsService {
  final GpsPermissionStatus _status = GpsPermissionStatus.granted;
  Position? _position;

  @override
  GpsPermissionStatus get permissionStatus => _status;

  @override
  Position? get lastPosition => _position;

  @override
  Future<void> initialize() async {}

  void emit(Position position) {
    _position = position;
    notifyListeners();
  }
}

class _FakeMeasurementRepository extends MeasurementRepository {
  _FakeMeasurementRepository() : super(DatabaseService());

  final List<Measurement> stored = [];

  @override
  Future<List<Measurement>> getAll() async => List.unmodifiable(stored);

  @override
  Future<Measurement> insert(Measurement measurement) async {
    final saved = measurement.copyWith(id: stored.length + 1);
    stored.add(saved);
    return saved;
  }

  @override
  Future<void> updateMemo(int id, String? memo) async {}

  @override
  Future<void> updateDriveLossCoefficient(int id, double c) async {}
}

Position _pos({
  double speedMs = 0.0,
  double altM = 0.0,
  DateTime? time,
}) =>
    Position(
      latitude: 35.0,
      longitude: 139.0,
      timestamp: time ?? DateTime(2024),
      accuracy: 5.0,
      altitude: altM,
      altitudeAccuracy: 1.0,
      heading: 0.0,
      headingAccuracy: 0.0,
      speed: speedMs,
      speedAccuracy: 0.1,
    );

Vehicle _vehicle({Drivetrain drivetrain = Drivetrain.rwd}) => Vehicle(
      id: 1,
      name: 'テスト車',
      weightKg: 1200.0,
      drivetrain: drivetrain,
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  late _FakeGpsService gps;
  late _FakeMeasurementRepository repo;
  late VehicleSelectionViewModel vehicleSelection;
  late MeasurementViewModel vm;

  setUp(() {
    gps = _FakeGpsService();
    repo = _FakeMeasurementRepository();
    vehicleSelection = VehicleSelectionViewModel();
    vm = MeasurementViewModel(gps, repo, vehicleSelection);
  });

  tearDown(() => vm.dispose());

  group('初期状態', () {
    test('status は idle', () {
      expect(vm.status, MeasurementStatus.idle);
    });

    test('selectedVehicle は null', () {
      expect(vm.selectedVehicle, isNull);
    });

    test('currentPs / maxPs は 0', () {
      expect(vm.currentPs, isNull);
      expect(vm.maxPs, 0.0);
    });
  });

  group('selectVehicle', () {
    test('車両を選択すると selectedVehicleId がセットされる', () {
      vm.selectVehicle(_vehicle());
      expect(vm.selectedVehicleId, '1');
    });

    test('null を渡すと選択解除される', () {
      vm.selectVehicle(_vehicle());
      vm.selectVehicle(null);
      expect(vm.selectedVehicleId, isNull);
    });
  });

  group('startMeasurement', () {
    test('status が measuring になる', () {
      vm.selectVehicle(_vehicle());
      vm.startMeasurement();
      expect(vm.status, MeasurementStatus.measuring);
    });

    test('startTime がセットされる', () {
      vm.selectVehicle(_vehicle());
      vm.startMeasurement();
      expect(vm.startTime, isNotNull);
    });

    test('データポイントがリセットされる', () async {
      vm.selectVehicle(_vehicle());
      vm.startMeasurement();
      final t0 = DateTime(2024, 1, 1, 0, 0, 0);
      gps.emit(_pos(speedMs: 10, time: t0));
      await vm.stopMeasurement();

      vm.selectVehicle(_vehicle());
      vm.startMeasurement();
      expect(vm.maxPs, 0.0);
    });
  });

  group('GPS 連携 / PS 計算', () {
    test('計測中に GPS イベントを受け取ると currentPs が更新される', () {
      vm.selectVehicle(_vehicle());
      vm.startMeasurement();

      final t0 = vm.startTime!;
      final t1 = t0.add(const Duration(seconds: 1));
      gps.emit(_pos(speedMs: 5, time: t0));
      gps.emit(_pos(speedMs: 20, time: t1));

      expect(vm.currentPs, isNotNull);
      expect(vm.currentPs!, greaterThan(0));
    });

    test('maxPs は最大値を保持する', () {
      vm.selectVehicle(_vehicle());
      vm.startMeasurement();

      final t0 = vm.startTime!;
      gps.emit(_pos(speedMs: 10, time: t0));
      gps.emit(_pos(speedMs: 30, time: t0.add(const Duration(seconds: 1))));
      final peakAfterAccel = vm.maxPs;
      gps.emit(_pos(speedMs: 5, time: t0.add(const Duration(seconds: 2))));

      expect(vm.maxPs, peakAfterAccel);
    });

    test('計測中でなければ GPS イベントを無視する', () {
      vm.selectVehicle(_vehicle());
      final t0 = DateTime(2024);
      gps.emit(_pos(speedMs: 30, time: t0));
      expect(vm.currentPs, isNull);
    });
  });

  group('stopMeasurement', () {
    test('計測停止後 status が finished になる', () async {
      vm.selectVehicle(_vehicle());
      vm.startMeasurement();
      await vm.stopMeasurement();
      expect(vm.status, MeasurementStatus.finished);
    });

    test('savedMeasurement がセットされる', () async {
      vm.selectVehicle(_vehicle());
      vm.startMeasurement();
      final t = vm.startTime!;
      gps.emit(_pos(speedMs: 20, time: t.add(const Duration(seconds: 1))));
      await vm.stopMeasurement();

      expect(vm.savedMeasurement, isNotNull);
      expect(vm.savedMeasurement!.vehicleName, 'テスト車');
    });

    test('Repository に保存される', () async {
      vm.selectVehicle(_vehicle());
      vm.startMeasurement();
      await vm.stopMeasurement();
      expect(repo.stored, hasLength(1));
    });

    test('車両未選択のときは saveError がセットされる', () async {
      vm.startMeasurement();
      await vm.stopMeasurement();
      expect(vm.saveError, isNotNull);
    });
  });

  group('reset', () {
    test('reset 後 status が idle に戻る', () async {
      vm.selectVehicle(_vehicle());
      vm.startMeasurement();
      await vm.stopMeasurement();
      vm.reset();
      expect(vm.status, MeasurementStatus.idle);
    });

    test('reset 後 savedMeasurement が null になる', () async {
      vm.selectVehicle(_vehicle());
      vm.startMeasurement();
      await vm.stopMeasurement();
      vm.reset();
      expect(vm.savedMeasurement, isNull);
    });
  });

  group('driveLossCoefficient', () {
    test('停止時に drivetrain の損失係数で保存される（RWD=0.15）', () async {
      vm.selectVehicle(_vehicle(drivetrain: Drivetrain.rwd));
      vm.startMeasurement();
      await vm.stopMeasurement();

      expect(repo.stored.first.driveLossCoefficient,
          closeTo(0.15, 0.0001));
    });

    test('FWD は 0.10 で保存される', () async {
      vm.selectVehicle(_vehicle(drivetrain: Drivetrain.fwd));
      vm.startMeasurement();
      await vm.stopMeasurement();

      expect(repo.stored.first.driveLossCoefficient,
          closeTo(0.10, 0.0001));
    });
  });
}
