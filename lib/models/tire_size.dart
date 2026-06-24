import 'package:freezed_annotation/freezed_annotation.dart';

part 'tire_size.freezed.dart';
part 'tire_size.g.dart';

@freezed
abstract class TireSize with _$TireSize {
  const TireSize._();

  const factory TireSize({
    required int widthMm,
    required int aspectRatio,
    required int rimInch,
  }) = _TireSize;

  factory TireSize.fromJson(Map<String, dynamic> json) =>
      _$TireSizeFromJson(json);

  /// タイヤ外径（m）
  double get outerDiameterM =>
      (rimInch * 25.4 + widthMm * aspectRatio / 100 * 2) / 1000;

  @override
  String toString() => '$widthMm/${aspectRatio}R$rimInch';
}
