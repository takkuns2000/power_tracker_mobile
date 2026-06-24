import 'package:freezed_annotation/freezed_annotation.dart';

part 'measurement_data_point.freezed.dart';

@freezed
abstract class MeasurementDataPoint with _$MeasurementDataPoint {
  const factory MeasurementDataPoint({
    int? id,
    required int measurementId,
    required int offsetMs,
    required double speedKmh,
    required double latitude,
    required double longitude,
    required double altitudeM,
    required double accuracyM,
  }) = _MeasurementDataPoint;
}
