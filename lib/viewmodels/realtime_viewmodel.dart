import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/vehicle.dart';
import '../services/gps_service.dart';
import '../services/ps_calculator.dart';

class RealtimeViewModel extends ChangeNotifier {
  static const Duration _kGpsTimeout = Duration(seconds: 3);

  RealtimeViewModel(this._gpsService) {
    _gpsService.addListener(_onGpsUpdate);
  }

  final GpsService _gpsService;
  final PsCalculatorService _calculator = PsCalculatorService();

  double? _ps;
  double? _speedKmh;
  double? _latitude;
  double? _longitude;
  double? _altitudeM;
  bool _isGpsActive = false;
  double? _gpsUpdateHz;
  String? _selectedVehicleId;
  double? _selectedVehicleMass;
  double? _selectedDriveEfficiency;
  String? _vehicleError;
  DateTime? _lastGpsTime;
  Timer? _gpsTimeoutTimer;

  double? get ps => _ps;
  double? get speedKmh => _speedKmh;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  double? get altitudeM => _altitudeM;
  bool get isGpsActive => _isGpsActive;
  double? get gpsUpdateHz => _gpsUpdateHz;
  String? get selectedVehicleId => _selectedVehicleId;
  String? get vehicleError => _vehicleError;

  void clearVehicleError() {
    _vehicleError = null;
  }

  void _onGpsUpdate() {
    if (_gpsService.permissionStatus != GpsPermissionStatus.granted) {
      _clearValues();
      _calculator.reset();
      notifyListeners();
      return;
    }

    final position = _gpsService.lastPosition;
    if (position == null) return;

    final now = position.timestamp;
    final prev = _lastGpsTime;

    if (prev != null) {
      final dtSec = now.difference(prev).inMicroseconds / 1e6;
      if (dtSec > 0) _gpsUpdateHz = 1.0 / dtSec;
    }
    _lastGpsTime = now;

    _speedKmh = position.speed * 3.6;
    _latitude = position.latitude;
    _longitude = position.longitude;
    _altitudeM = position.altitude;

    if (_selectedVehicleId != null && _selectedDriveEfficiency != null) {
      _ps = _calculator.calculate(
        currentSpeedMs: position.speed,
        currentAltitudeM: position.altitude,
        currentTime: now,
        vehicleMassKg: _selectedVehicleMass!,
        driveEfficiency: _selectedDriveEfficiency!,
      );
    } else {
      _ps = null;
      _calculator.reset();
    }

    _isGpsActive = true;
    _gpsTimeoutTimer?.cancel();
    _gpsTimeoutTimer = Timer(_kGpsTimeout, () {
      _isGpsActive = false;
      notifyListeners();
    });

    notifyListeners();
  }

  void selectVehicle(Vehicle? vehicle) {
    if (vehicle != null && vehicle.drivetrain == null) {
      _vehicleError = '駆動方式が設定されていません。車両設定を確認してください。';
      // notifyListeners() 呼ばない — callback 内で直接エラーを処理
      return;
    }
    _selectedVehicleId = vehicle?.id?.toString();
    _selectedVehicleMass = vehicle?.weightKg;
    _selectedDriveEfficiency = vehicle?.drivetrain?.driveEfficiency;
    _calculator.reset();
    notifyListeners();
  }

  void initDefaultVehicle(Vehicle vehicle) {
    if (_selectedVehicleId != null) return;
    if (vehicle.drivetrain == null) return; // エラーなし・スキップ
    _selectedVehicleId = vehicle.id?.toString();
    _selectedVehicleMass = vehicle.weightKg;
    _selectedDriveEfficiency = vehicle.drivetrain!.driveEfficiency;
    _calculator.reset();
  }

  void _clearValues() {
    _ps = null;
    _speedKmh = null;
    _latitude = null;
    _longitude = null;
    _altitudeM = null;
    _isGpsActive = false;
    _gpsUpdateHz = null;
    _lastGpsTime = null;
    _gpsTimeoutTimer?.cancel();
    _gpsTimeoutTimer = null;
  }

  @override
  void dispose() {
    _gpsTimeoutTimer?.cancel();
    _gpsService.removeListener(_onGpsUpdate);
    super.dispose();
  }
}
