import 'package:flutter/foundation.dart';
import '../models/vehicle.dart';

class VehicleSelectionViewModel extends ChangeNotifier {
  Vehicle? _vehicle;

  Vehicle? get vehicle => _vehicle;
  String? get vehicleId => _vehicle?.id?.toString();

  void select(Vehicle? vehicle) {
    _vehicle = vehicle;
    notifyListeners();
  }

  void selectDefaultIfEmpty(Vehicle vehicle) {
    if (_vehicle != null) return;
    _vehicle = vehicle;
  }
}
