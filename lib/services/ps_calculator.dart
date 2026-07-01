import 'dart:math' as math;

/// GPS速度・標高データからエンジン瞬時出力（PS）を算出するステートフルサービス。
///
/// 運動量から得たホイール出力を、集約ロス係数でエンジン出力へ換算する。
///
///   ΔKE [J]      = m×(v2²−v1²)/2            運動エネルギー差
///   P_wheel [W]  = (ΔKE + m×g×Δh) / Δt      ホイール出力（加速＋勾配）
///   P_engine [W] = P_wheel / η               η でエンジン出力へ換算（伝達損失）
///   PS           = P_engine / (75 × g)       // 1 PS = 75 kgf·m/s = 735.499 W
///
/// η（driveEfficiency = 1 − ロス係数）は駆動系・転がり抵抗・空気抵抗を集約した
/// 損失を表す。等速・惰行・減速では P_wheel ≤ 0 となり 0 PS を返す（伝達する
/// パワーが無ければ損失も無い）。主目的は加速時のピーク馬力計測。
///
/// 走行抵抗を切り出す road-load モデルは docs/features/measurement.md 参照（今回は不採用）。
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
  /// 戻り値: PS。等速・惰行・減速・初回呼び出しは 0.0。
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

    final deltaKineticJ =
        vehicleMassKg * (math.pow(currentSpeedMs, 2) - math.pow(prevSpeed, 2)) / 2;
    final climbWorkJ = vehicleMassKg * _g * (currentAltitudeM - prevAlt);
    final wheelPowerW = (deltaKineticJ + climbWorkJ) / dtSec;
    final enginePowerW = wheelPowerW / driveEfficiency;
    if (enginePowerW <= 0) return 0.0;

    return enginePowerW / _wattsPerPs;
  }

  void reset() {
    _prevSpeedMs = 0.0;
    _prevAltitudeM = 0.0;
    _prevTime = null;
  }

  /// PS とエンジン回転数からトルク [kgf·m] を計算する。
  ///
  ///   wheel_rpm    = (speedMs / (π × tireOuterDiameterM)) × 60
  ///   engine_rpm   = wheel_rpm × gearRatio × finalRatio
  ///   torque [N·m] = P [W] / (engine_rpm × π / 30)
  ///   torque [kgm] = torque [N·m] / g
  ///
  /// 速度ゼロ・ギア比未設定・エンジン回転数ゼロの場合は null を返す。
  static double? calcTorqueKgm({
    required double powerPs,
    required double speedMs,
    required double gearRatio,
    required double finalRatio,
    required double tireOuterDiameterM,
  }) {
    if (powerPs <= 0) return 0.0;
    if (speedMs <= 0 || gearRatio <= 0 || finalRatio <= 0) return null;
    final wheelRpm = (speedMs / (math.pi * tireOuterDiameterM)) * 60.0;
    final engineRpm = wheelRpm * gearRatio * finalRatio;
    if (engineRpm <= 0) return null;
    final engineRadPerS = engineRpm * math.pi / 30.0;
    final torqueNm = (powerPs * _wattsPerPs) / engineRadPerS;
    return torqueNm / _g;
  }

  /// GPS 速度とギア比からエンジン回転数 [rpm] を計算する。
  static int? calcEngineRpm({
    required double speedMs,
    required double gearRatio,
    required double finalRatio,
    required double tireOuterDiameterM,
  }) {
    if (speedMs <= 0 || gearRatio <= 0 || finalRatio <= 0) return null;
    final wheelRpm = (speedMs / (math.pi * tireOuterDiameterM)) * 60.0;
    final engineRpm = wheelRpm * gearRatio * finalRatio;
    return engineRpm.round();
  }
}
