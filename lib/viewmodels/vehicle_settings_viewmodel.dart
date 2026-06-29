import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
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
    _imagePath = vehicle?.imagePath;
    _originalImagePath = vehicle?.imagePath;
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

  String? _imagePath;
  String? _originalImagePath;
  String? get imagePath => _imagePath;

  String? _imagePickError;
  String? get imagePickError => _imagePickError;
  void clearImagePickError() {
    _imagePickError = null;
  }

  bool get hasPendingChanges {
    if (_editingVehicle == null) {
      return nameController.text.trim().isNotEmpty ||
          weightController.text.trim().isNotEmpty;
    }
    final v = _editingVehicle;
    if (_imagePath != _originalImagePath) return true;
    if (_drivetrain != v.drivetrain) return true;
    if (nameController.text != v.name) return true;
    if (modelCodeController.text != (v.modelCode ?? '')) return true;
    if (weightController.text != v.weightKg.toString()) return true;
    if (displacementController.text != (v.displacementCc?.toString() ?? '')) {
      return true;
    }
    if (memoController.text != (v.memo ?? '')) return true;
    if (tireWidthController.text != (v.tireSize?.widthMm.toString() ?? '')) {
      return true;
    }
    if (tireAspectController.text !=
        (v.tireSize?.aspectRatio.toString() ?? '')) {
      return true;
    }
    if (tireRimController.text != (v.tireSize?.rimInch.toString() ?? '')) {
      return true;
    }
    final origFinalGear = v.finalGearRatio;
    if (finalGearController.text != (origFinalGear?.ratio.toString() ?? '')) {
      return true;
    }
    for (var i = 0; i < gearControllers.length; i++) {
      final orig =
          v.transmissionGears.where((g) => g.gearNumber == i + 1).firstOrNull;
      if (gearControllers[i].text != (orig?.ratio.toString() ?? '')) {
        return true;
      }
    }
    return false;
  }

  Future<void> pickImage() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        imageQuality: 90,
      );
      if (picked == null) return;

      final cropped = await ImageCropper().cropImage(
        sourcePath: picked.path,
        aspectRatio: const CropAspectRatio(ratioX: 3, ratioY: 1),
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 85,
        maxWidth: 1080,
        maxHeight: 360,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: '写真を切り抜く',
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: '写真を切り抜く',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );
      if (cropped == null) return;

      final dir = await getApplicationDocumentsDirectory();
      final destDir = Directory(p.join(dir.path, 'vehicle_images'));
      if (!await destDir.exists()) await destDir.create(recursive: true);

      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final dest = p.join(destDir.path, fileName);
      await File(cropped.path).copy(dest);

      if (_imagePath != null && _imagePath != _originalImagePath) {
        await _deleteFile(_imagePath!);
      }

      _imagePath = dest;
    } catch (e) {
      debugPrint('[VehicleSettingsViewModel] pickImage error: $e');
      _imagePickError = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> _deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }

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
          imagePath: _imagePath,
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
          imagePath: _imagePath,
          updatedAt: DateTime.now(),
        ));
        // 編集時に画像を差し替えた場合、古いファイルを削除
        if (_originalImagePath != null && _originalImagePath != _imagePath) {
          await _deleteFile(_originalImagePath!);
        }
      }
      _originalImagePath = _imagePath;
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
    // 保存されずに閉じた場合、未保存の選択画像を削除
    if (_imagePath != null && _imagePath != _originalImagePath) {
      _deleteFile(_imagePath!);
    }
    super.dispose();
  }
}
