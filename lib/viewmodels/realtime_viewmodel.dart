import 'package:flutter/material.dart';

class RealtimeViewModel extends ChangeNotifier {
  double _horsepower = 0.0;
  double _speedKmh = 0.0;
  double _latitude = 0.0;
  double _longitude = 0.0;
  double _altitudeM = 0.0;

  double get horsepower => _horsepower;
  double get speedKmh => _speedKmh;
  double get latitude => _latitude;
  double get longitude => _longitude;
  double get altitudeM => _altitudeM;

  void updateTelemetry({
    required double horsepower,
    required double speedKmh,
    required double latitude,
    required double longitude,
    required double altitudeM,
  }) {
    _horsepower = horsepower;
    _speedKmh = speedKmh;
    _latitude = latitude;
    _longitude = longitude;
    _altitudeM = altitudeM;
    notifyListeners();
  }
}
