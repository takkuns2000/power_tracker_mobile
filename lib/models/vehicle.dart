import 'package:freezed_annotation/freezed_annotation.dart';
import 'drivetrain.dart';
import 'gear_ratio.dart';
import 'tire_size.dart';

part 'vehicle.freezed.dart';
part 'vehicle.g.dart';

@freezed
class Vehicle with _$Vehicle {
  const Vehicle._();

  const factory Vehicle({
    int? id,
    required String name,
    String? modelCode,
    required double weightKg,
    Drivetrain? drivetrain,
    int? displacementCc,
    String? memo,
    TireSize? tireSize,
    @Default([]) List<GearRatio> gearRatios,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool isDeleted,
  }) = _Vehicle;

  factory Vehicle.fromJson(Map<String, dynamic> json) =>
      _$VehicleFromJson(json);

  /// ファイナルギア比（gear_number = 0）
  GearRatio? get finalGearRatio =>
      gearRatios.where((g) => g.gearNumber == 0).firstOrNull;

  /// 変速ギア比リスト（gear_number 1〜7）
  List<GearRatio> get transmissionGears =>
      gearRatios.where((g) => g.gearNumber > 0).toList()
        ..sort((a, b) => a.gearNumber.compareTo(b.gearNumber));
}
