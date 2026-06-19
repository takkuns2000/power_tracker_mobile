import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../repositories/vehicle_repository.dart';
import '../services/purchase_service.dart';
import 'vehicle_settings_viewmodel.dart';

class GarageViewModel extends ChangeNotifier {
  GarageViewModel(this._repository, this._purchaseService) {
    loadVehicles();
  }

  final VehicleRepository _repository;
  final PurchaseService _purchaseService;

  bool get isPro => _purchaseService.isPro;
  List<Vehicle> _vehicles = [];
  bool _isLoading = false;

  List<Vehicle> get vehicles => List.unmodifiable(_vehicles);
  bool get isLoading => _isLoading;

  Future<void> loadVehicles() async {
    debugPrint('[GarageViewModel] loadVehicles start');
    _isLoading = true;
    notifyListeners();
    _vehicles = await _repository.getAll();
    _isLoading = false;
    notifyListeners();
    debugPrint('[GarageViewModel] loadVehicles done: ${_vehicles.length} vehicles');
  }

  Future<void> deleteVehicle(int id) async {
    await _repository.delete(id);
    await loadVehicles();
  }

  VehicleSettingsViewModel createSettingsViewModel({Vehicle? vehicle}) {
    return VehicleSettingsViewModel(
      repository: _repository,
      purchaseService: _purchaseService,
      vehicle: vehicle,
    );
  }
}
