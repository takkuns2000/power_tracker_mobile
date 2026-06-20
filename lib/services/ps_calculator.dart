import 'dart:math' as math;

/// GPS速度・標高データから瞬時出力（PS）を算出するステートフルサービス。
///
/// すべての仕事量を J（ジュール）で統一し、最後に PS へ変換する。
///
///   ke2 [J]             = m×v2²/(2η)      エンジンが v2 を実現するために出力すべきエネルギー
///   ke1 [J]             = m×v1²/2         すでに車両に蓄えられているエネルギー（η なし・支払い済み）
///   engineWork [J]      = ke2 − ke1
///   potentialEnergy [J] = m×g×Δh / η      ke2 と同様にエンジン側へ換算
///   power [W]           = (engineWork + potentialEnergy) / Δt
///   PS                  = power / (75 × g)   // 1 PS = 75 kgf·m/s = 735.499 W
///
/// η は Drivetrain.driveEfficiency から渡す（FWD=0.90, RWD=0.85, AWD=0.80）
class PsCalculatorService {
  static const double _g = 9.80665; // 重力加速度 [m/s²]
  static const double _wattsPerPs = 75.0 * _g; // 1 PS = 735.499 W

  double _prevSpeedMs = 0.0;
  double _prevAltitudeM = 0.0;
  DateTime? _prevTime;

  /// [currentSpeedMs]: GPS速度 [m/s]
  /// [currentAltitudeM]: GPS標高 [m]
  /// [currentTime]: タイムスタンプ
  /// [vehicleMassKg]: 車両重量 [kg]
  /// [driveEfficiency]: ドライブトレイン効率 η（Drivetrain.driveEfficiency を使用）
  ///
  /// 戻り値: PS。減速時・初回呼び出しは 0.0。
  double calculate({
    required double currentSpeedMs,
    required double currentAltitudeM,
    required DateTime currentTime,
    required double vehicleMassKg,
    required double driveEfficiency,
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

    // 運動エネルギー差 [J]
    final ke2 = vehicleMassKg * math.pow(currentSpeedMs, 2) / (2 * driveEfficiency);
    final ke1 = vehicleMassKg * math.pow(prevSpeed, 2) / 2;
    final engineWorkJ = ke2 - ke1;

    // 位置エネルギー差 [J]（ke2 と同様に η でエンジン側に換算）
    final potentialEnergyJ = vehicleMassKg * _g * (currentAltitudeM - prevAlt) / driveEfficiency;

    final totalWorkJ = engineWorkJ + potentialEnergyJ;
    if (totalWorkJ <= 0) return 0.0;

    // W → PS 変換
    return (totalWorkJ / dtSec) / _wattsPerPs;
  }

  void reset() {
    _prevSpeedMs = 0.0;
    _prevAltitudeM = 0.0;
    _prevTime = null;
  }
}
