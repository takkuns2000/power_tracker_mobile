import 'package:flutter/material.dart';

enum MeasurementStatus { idle, measuring, finished }

class MeasurementViewModel extends ChangeNotifier {
  MeasurementStatus _status = MeasurementStatus.idle;
  String? _selectedVehicleId;
  double? _temperatureCelsius;
  double? _pressureHpa;

  MeasurementStatus get status => _status;
  String? get selectedVehicleId => _selectedVehicleId;
  double? get temperatureCelsius => _temperatureCelsius;
  double? get pressureHpa => _pressureHpa;

  void selectVehicle(String vehicleId) {
    _selectedVehicleId = vehicleId;
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

  DateTime? _startTime;
  DateTime? get startTime => _startTime;

  void startMeasurement() {
    _status = MeasurementStatus.measuring;
    _startTime = DateTime.now();
    notifyListeners();
  }

  void stopMeasurement() {
    _status = MeasurementStatus.finished;
    notifyListeners();
  }

  void reset() {
    _status = MeasurementStatus.idle;
    notifyListeners();
  }
}
