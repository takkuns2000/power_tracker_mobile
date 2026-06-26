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

  void reloadSelectedVehicle(List<Vehicle> vehicles) {
    final id = _vehicle?.id;
    if (id == null) return;
    Vehicle? latest;
    for (final v in vehicles) {
      if (v.id == id) {
        latest = v;
        break;
      }
    }
    if (latest != _vehicle) {
      _vehicle = latest;
      notifyListeners();
    }
  }
}
