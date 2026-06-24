import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/measurement.dart';
import '../models/measurement_data_point.dart';
import '../models/vehicle.dart';
import '../repositories/measurement_repository.dart';
import '../services/gps_service.dart';
import '../services/ps_calculator.dart';
import 'vehicle_selection_viewmodel.dart';

enum MeasurementStatus { idle, measuring, finished }

class MeasurementViewModel extends ChangeNotifier {
  MeasurementViewModel(
      this._gpsService, this._repository, this._vehicleSelection) {
    _gpsService.addListener(_onGpsUpdate);
  }

  final GpsService _gpsService;
  final MeasurementRepository _repository;
  final VehicleSelectionViewModel _vehicleSelection;
  final PsCalculatorService _calculator = PsCalculatorService();

  MeasurementStatus _status = MeasurementStatus.idle;
  double? _temperatureCelsius;
  double? _pressureHpa;

  double? _currentPs;
  double _maxPs = 0;
  DateTime? _startTime;
  final List<MeasurementDataPoint> _dataPoints = [];

  static const Duration _kGpsTimeout = Duration(seconds: 3);

  Measurement? _savedMeasurement;
  String? _saveError;
  double? _gpsAccuracyM;
  double? _gpsUpdateHz;
  DateTime? _lastGpsTime;
  Timer? _gpsTimeoutTimer;

  MeasurementStatus get status => _status;
  Vehicle? get selectedVehicle => _vehicleSelection.vehicle;
  String? get selectedVehicleId => _vehicleSelection.vehicleId;
  double? get temperatureCelsius => _temperatureCelsius;
  double? get pressureHpa => _pressureHpa;
  double? get currentPs => _currentPs;
  double get maxPs => _maxPs;
  DateTime? get startTime => _startTime;
  Measurement? get savedMeasurement => _savedMeasurement;
  String? get saveError => _saveError;

  double? get gpsAccuracyM => _gpsAccuracyM;
  double? get gpsUpdateHz => _gpsUpdateHz;
  bool get isGpsLocked =>
      _gpsService.permissionStatus == GpsPermissionStatus.granted &&
      _gpsAccuracyM != null;

  int get gpsPrecisionSegments {
    final acc = _gpsAccuracyM;
    if (acc == null) return 0;
    if (acc <= 3) return 8;
    if (acc <= 5) return 7;
    if (acc <= 8) return 6;
    if (acc <= 12) return 5;
    if (acc <= 20) return 4;
    if (acc <= 30) return 3;
    if (acc <= 50) return 2;
    if (acc <= 100) return 1;
    return 0;
  }

  int get gpsHzSegments {
    final hz = _gpsUpdateHz;
    if (hz == null) return 0;
    if (hz >= 10) return 8;
    if (hz >= 8) return 7;
    if (hz >= 6) return 6;
    if (hz >= 4) return 5;
    if (hz >= 2) return 4;
    if (hz >= 1) return 3;
    return 1;
  }

  void clearSaveError() {
    _saveError = null;
  }

  void selectVehicle(Vehicle? vehicle) {
    _vehicleSelection.select(vehicle);
    _calculator.reset();
    notifyListeners();
  }

  void setTemperature(double? value) {
    _temperatureCelsius = value;
    notifyListeners();
  }

  void setPressure(double? value) {
    _pressureHpa = value;
    notifyListeners();
  }

  void startMeasurement() {
    _status = MeasurementStatus.measuring;
    _startTime = DateTime.now();
    _currentPs = null;
    _maxPs = 0;
    _dataPoints.clear();
    _calculator.reset();
    notifyListeners();
  }

  Future<void> stopMeasurement() async {
    _status = MeasurementStatus.finished;

    final vehicle = _vehicleSelection.vehicle;
    if (vehicle == null || _startTime == null) {
      _saveError = '計測データが不足しています。';
    } else {
      try {
        final measurement = Measurement(
          vehicleId: vehicle.id,
          vehicleName: vehicle.name,
          vehicleWeightKg: vehicle.weightKg,
          vehicleSnapshot: vehicle,
          measuredAt: _startTime!,
          maxHp: _maxPs,
          temperatureCelsius: _temperatureCelsius,
          pressureHpa: _pressureHpa,
          driveLossCoefficient: 1.0 - vehicle.drivetrain.driveEfficiency,
          dataPoints: List.unmodifiable(_dataPoints),
        );
        _savedMeasurement = await _repository.insert(measurement);
      } catch (e) {
        debugPrint('[MeasurementViewModel] save error: $e');
        _saveError = '計測データの保存に失敗しました。';
      }
    }
    notifyListeners();
  }

  void reset() {
    _status = MeasurementStatus.idle;
    _currentPs = null;
    _maxPs = 0;
    _startTime = null;
    _dataPoints.clear();
    _savedMeasurement = null;
    _saveError = null;
    _calculator.reset();
    notifyListeners();
  }

  void _onGpsUpdate() {
    if (_gpsService.permissionStatus != GpsPermissionStatus.granted) return;

    final position = _gpsService.lastPosition;
    if (position == null) return;

    _gpsAccuracyM = position.accuracy;

    final now = position.timestamp;
    final prev = _lastGpsTime;
    if (prev != null) {
      final dtSec = now.difference(prev).inMicroseconds / 1e6;
      if (dtSec > 0) _gpsUpdateHz = 1.0 / dtSec;
    }
    _lastGpsTime = now;

    _gpsTimeoutTimer?.cancel();
    _gpsTimeoutTimer = Timer(_kGpsTimeout, _onGpsTimeout);

    if (_status != MeasurementStatus.measuring) {
      notifyListeners();
      return;
    }

    final vehicle = _vehicleSelection.vehicle;
    if (vehicle == null) return;

    final offsetMs = now.difference(_startTime!).inMilliseconds;
    if (offsetMs < 0) return;

    _dataPoints.add(MeasurementDataPoint(
      measurementId: 0,
      offsetMs: offsetMs,
      speedKmh: position.speed * 3.6,
      latitude: position.latitude,
      longitude: position.longitude,
      altitudeM: position.altitude,
      accuracyM: position.accuracy,
    ));

    final ps = _calculator.calculate(
      currentSpeedMs: position.speed,
      currentAltitudeM: position.altitude,
      currentTime: now,
      vehicleMassKg: vehicle.weightKg,
      driveEfficiency: vehicle.drivetrain.driveEfficiency,
    );
    _currentPs = ps;
    if (ps > _maxPs) _maxPs = ps;

    notifyListeners();
  }

  void _onGpsTimeout() {
    _gpsAccuracyM = null;
    _gpsUpdateHz = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _gpsTimeoutTimer?.cancel();
    _gpsService.removeListener(_onGpsUpdate);
    super.dispose();
  }
}
