import 'package:freezed_annotation/freezed_annotation.dart';
import 'measurement_data_point.dart';
import 'vehicle.dart';

part 'measurement.freezed.dart';

@freezed
abstract class Measurement with _$Measurement {
  const factory Measurement({
    int? id,
    int? vehicleId,
    required String vehicleName,
    required double vehicleWeightKg,
    required Vehicle vehicleSnapshot,
    required DateTime measuredAt,
    required double maxHp,
    double? temperatureCelsius,
    double? pressureHpa,
    double? finalGearRatio,
    double? usedGearRatio,
    @Default(0.15) double driveLossCoefficient,
    String? memo,
    @Default([]) List<MeasurementDataPoint> dataPoints,
  }) = _Measurement;
}
