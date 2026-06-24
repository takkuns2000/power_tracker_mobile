import 'package:flutter/material.dart';
import '../models/drivetrain.dart';
import '../models/gear_ratio.dart';
import '../models/tire_size.dart';
import '../models/vehicle.dart';
import '../repositories/vehicle_repository.dart';
import '../services/purchase_service.dart';

class VehicleSettingsViewModel extends ChangeNotifier {
  VehicleSettingsViewModel({
    required this._repository,
    required this._purchaseService,
    Vehicle? vehicle,
  }) : _editingVehicle = vehicle {
    debugPrint('[VehicleSettingsViewModel] init: vehicle=${vehicle?.name}');
    nameController = TextEditingController(text: vehicle?.name ?? '');
    modelCodeController =
        TextEditingController(text: vehicle?.modelCode ?? '');
    weightController = TextEditingController(
        text: vehicle != null ? vehicle.weightKg.toString() : '');
    displacementController =
        TextEditingController(text: vehicle?.displacementCc?.toString() ?? '');
    memoController = TextEditingController(text: vehicle?.memo ?? '');
    tireWidthController = TextEditingController(
        text: vehicle?.tireSize?.widthMm.toString() ?? '');
    tireAspectController = TextEditingController(
        text: vehicle?.tireSize?.aspectRatio.toString() ?? '');
    tireRimController = TextEditingController(
        text: vehicle?.tireSize?.rimInch.toString() ?? '');
    finalGearController = TextEditingController(
        text: vehicle?.finalGearRatio?.ratio.toString() ?? '');
    gearControllers = List.generate(7, (i) {
      final gear = vehicle?.transmissionGears
          .where((g) => g.gearNumber == i + 1)
          .firstOrNull;
      return TextEditingController(text: gear?.ratio.toString() ?? '');
    });
    _drivetrain = vehicle?.drivetrain ?? Drivetrain.fwd;
  }

  final VehicleRepository _repository;
  final PurchaseService _purchaseService;
  final Vehicle? _editingVehicle;

  bool get isPro => _purchaseService.isPro;

  late final TextEditingController nameController;
  late final TextEditingController modelCodeController;
  late final TextEditingController weightController;
  late final TextEditingController displacementController;
  late final TextEditingController memoController;
  late final TextEditingController tireWidthController;
  late final TextEditingController tireAspectController;
  late final TextEditingController tireRimController;
  late final TextEditingController finalGearController;
  late final List<TextEditingController> gearControllers;

  Drivetrain _drivetrain = Drivetrain.fwd;
  Drivetrain get drivetrain => _drivetrain;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  bool get isEditing => _editingVehicle != null;

  void selectDrivetrain(Drivetrain value) {
    _drivetrain = value;
    notifyListeners();
  }

  Future<bool> save() async {
    final isPro = _purchaseService.isPro;
    debugPrint('[VehicleSettingsViewModel] save start: isPro=$isPro');
    final name = nameController.text.trim();
    final weightText = weightController.text.trim();
    if (name.isEmpty || weightText.isEmpty) {
      debugPrint('[VehicleSettingsViewModel] save aborted: name or weight empty');
      return false;
    }
    final weight = double.tryParse(weightText);
    if (weight == null) {
      debugPrint('[VehicleSettingsViewModel] save aborted: invalid weight');
      return false;
    }

    _isSaving = true;
    notifyListeners();

    try {
      final modelCode = modelCodeController.text.trim().isEmpty
          ? null
          : modelCodeController.text.trim();
      final displacement =
          int.tryParse(displacementController.text.trim());
      final memo = memoController.text.trim().isEmpty
          ? null
          : memoController.text.trim();

      TireSize? tireSize;
      List<GearRatio> gearRatios = [];

      if (isPro) {
        final width = int.tryParse(tireWidthController.text.trim());
        final aspect = int.tryParse(tireAspectController.text.trim());
        final rim = int.tryParse(tireRimController.text.trim());
        if (width != null && aspect != null && rim != null) {
          tireSize =
              TireSize(widthMm: width, aspectRatio: aspect, rimInch: rim);
        }

        final finalRatio =
            double.tryParse(finalGearController.text.trim());
        if (finalRatio != null) {
          gearRatios.add(GearRatio(
            vehicleId: _editingVehicle?.id ?? 0,
            gearNumber: 0,
            ratio: finalRatio,
          ));
        }
        for (var i = 0; i < gearControllers.length; i++) {
          final ratio = double.tryParse(gearControllers[i].text.trim());
          if (ratio != null) {
            gearRatios.add(GearRatio(
              vehicleId: _editingVehicle?.id ?? 0,
              gearNumber: i + 1,
              ratio: ratio,
            ));
          }
        }
      }

      if (_editingVehicle == null) {
        final now = DateTime.now();
        await _repository.insert(Vehicle(
          name: name,
          modelCode: modelCode,
          weightKg: weight,
          drivetrain: _drivetrain,
          displacementCc: displacement,
          memo: memo,
          tireSize: tireSize,
          gearRatios: gearRatios,
          createdAt: now,
          updatedAt: now,
        ));
      } else {
        await _repository.update(_editingVehicle.copyWith(
          name: name,
          modelCode: modelCode,
          weightKg: weight,
          drivetrain: _drivetrain,
          displacementCc: displacement,
          memo: memo,
          tireSize: tireSize,
          gearRatios: gearRatios,
          updatedAt: DateTime.now(),
        ));
      }
      debugPrint('[VehicleSettingsViewModel] save done');
      return true;
    } catch (e) {
      debugPrint('[VehicleSettingsViewModel] save error: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    modelCodeController.dispose();
    weightController.dispose();
    displacementController.dispose();
    memoController.dispose();
    tireWidthController.dispose();
    tireAspectController.dispose();
    tireRimController.dispose();
    finalGearController.dispose();
    for (final c in gearControllers) {
      c.dispose();
    }
    super.dispose();
  }
}
