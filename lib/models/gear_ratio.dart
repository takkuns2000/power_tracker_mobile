import 'package:freezed_annotation/freezed_annotation.dart';

part 'gear_ratio.freezed.dart';
part 'gear_ratio.g.dart';

@freezed
abstract class GearRatio with _$GearRatio {
  const factory GearRatio({
    int? id,
    required int vehicleId,
    /// 0 = ファイナルギア、1〜7 = 変速ギア
    required int gearNumber,
    required double ratio,
  }) = _GearRatio;

  factory GearRatio.fromJson(Map<String, dynamic> json) =>
      _$GearRatioFromJson(json);
}
