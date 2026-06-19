import 'dart:math' as math;

/// GPS速度・標高データから瞬時出力（PS）を算出するステートフルサービス。
///
/// sampleコード（lib/sample/dart_package_1_base.dart）と同一ロジック:
///   engineWork  = m * v2² / (2g * η) - m * v1² / (2g)   [kgf·m]
///   potentialEnergy = m * 9.8 * Δh                        [J] ← sample準拠
///   ps = (engineWork + potentialEnergy) / Δt / 75
///
/// 定数: 1 PS = 75 kgf·m/s（メトリック馬力）
class PsCalculatorService {
  static const double _driveEfficiency = 0.85;
  static const double _g = 9.8;
  static const double _psConstant = 75.0;

  double _prevSpeedMs = 0.0;
  double _prevAltitudeM = 0.0;
  DateTime? _prevTime;

  /// [currentSpeedMs]: GPS速度 m/s
  /// [currentAltitudeM]: GPS標高 m
  /// [currentTime]: タイムスタンプ
  /// [vehicleMassKg]: 車両重量 kg
  ///
  /// 戻り値: PS。減速時・初回呼び出しは 0.0。
  double calculate({
    required double currentSpeedMs,
    required double currentAltitudeM,
    required DateTime currentTime,
    required double vehicleMassKg,
  }) {
    final prev = _prevTime;
    final prevSpeed = _prevSpeedMs;
    final prevAlt = _prevAltitudeM;

    _prevSpeedMs = currentSpeedMs;
    _prevAltitudeM = currentAltitudeM;
    _prevTime = currentTime;

    if (prev == null) return 0.0;

    final dtSec = currentTime.difference(prev).inMicroseconds / 1e6;
    if (dtSec <= 0) return 0.0;

    // 運動エネルギー差分 [kgf·m] — sampleコード行69と同一
    final ke2 = vehicleMassKg * math.pow(currentSpeedMs, 2) / (2 * _g * _driveEfficiency);
    final ke1 = vehicleMassKg * math.pow(prevSpeed, 2) / (2 * _g);
    final engineWork = ke2 - ke1;

    // 標高補正 — sampleコード行63と同一（unitはJだがsample準拠）
    final potentialEnergy = vehicleMassKg * _g * (currentAltitudeM - prevAlt);

    final totalWork = engineWork + potentialEnergy;
    if (totalWork <= 0) return 0.0;

    return (totalWork / dtSec) / _psConstant;
  }

  void reset() {
    _prevSpeedMs = 0.0;
    _prevAltitudeM = 0.0;
    _prevTime = null;
  }
}
