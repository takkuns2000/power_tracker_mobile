import 'package:flutter_test/flutter_test.dart';
import 'package:horsepower_tracker_mobile/services/ps_calculator.dart';

void main() {
  const m = 1090.0; // sample デフォルト車両重量
  const eta = 0.85; // RWD（= 1 − 集約ロス係数0.15）

  final t0 = DateTime(2026, 1, 1, 0, 0, 0);

  double kmhToMs(double kmh) => kmh * 1000 / 3600;

  // prev をセットしてから dt 秒後の点で calculate を呼ぶヘルパー。
  double calcStep(
    PsCalculatorService calc, {
    required double v1Kmh,
    required double v2Kmh,
    required double dtSec,
    double alt1 = 0,
    double alt2 = 0,
    double mass = m,
    double eta_ = eta,
  }) {
    calc.calculate(
      currentSpeedMs: kmhToMs(v1Kmh),
      currentAltitudeM: alt1,
      currentTime: t0,
      vehicleMassKg: mass,
      driveEfficiency: eta_,
    );
    return calc.calculate(
      currentSpeedMs: kmhToMs(v2Kmh),
      currentAltitudeM: alt2,
      currentTime: t0.add(Duration(microseconds: (dtSec * 1e6).round())),
      vehicleMassKg: mass,
      driveEfficiency: eta_,
    );
  }

  group('PsCalculatorService', () {
    test('初回呼び出しは 0.0 を返す', () {
      final calc = PsCalculatorService();
      final ps = calc.calculate(
        currentSpeedMs: kmhToMs(50),
        currentAltitudeM: 0,
        currentTime: t0,
        vehicleMassKg: m,
        driveEfficiency: eta,
      );
      expect(ps, 0.0);
    });

    test('Δt ≤ 0 は 0.0 を返す', () {
      final calc = PsCalculatorService();
      final ps = calcStep(calc, v1Kmh: 50, v2Kmh: 50, dtSec: 0);
      expect(ps, 0.0);
    });

    test('加速例: 10→17km/h, Δt=1s, m=1090, η=0.85 ≈ 12.7 PS', () {
      final calc = PsCalculatorService();
      final ps = calcStep(calc, v1Kmh: 10, v2Kmh: 17, dtSec: 1.0);
      expect(ps, closeTo(12.7, 0.3));
    });

    test('等速 105km/h は 0 PS（伝達パワーが無ければ損失も無い）', () {
      final calc = PsCalculatorService();
      final ps = calcStep(calc, v1Kmh: 105, v2Kmh: 105, dtSec: 1.0);
      expect(ps, closeTo(0, 0.01));
    });

    test('惰行 119→118km/h は 0 PS（過大表示の再発防止）', () {
      final calc = PsCalculatorService();
      final ps = calcStep(calc, v1Kmh: 119, v2Kmh: 118, dtSec: 1.0);
      expect(ps, 0.0);
    });

    test('強い減速（100→0km/h）は 0.0', () {
      final calc = PsCalculatorService();
      final ps = calcStep(calc, v1Kmh: 100, v2Kmh: 0, dtSec: 1.0);
      expect(ps, 0.0);
    });

    test('加速の出力は GPS 更新間隔（Δt）に依存しない', () {
      // 10→17km/h を 1秒で一気に / 0.5秒×2回（中間13.5km/h）で計測した
      // ときの平均が大きく乖離しないこと（P = m·a·v_avg で Δt 安定）。
      final calc1 = PsCalculatorService();
      final whole = calcStep(calc1, v1Kmh: 10, v2Kmh: 17, dtSec: 1.0);

      final calc2 = PsCalculatorService();
      calc2.calculate(
        currentSpeedMs: kmhToMs(10),
        currentAltitudeM: 0,
        currentTime: t0,
        vehicleMassKg: m,
        driveEfficiency: eta,
      );
      final half1 = calc2.calculate(
        currentSpeedMs: kmhToMs(13.5),
        currentAltitudeM: 0,
        currentTime: t0.add(const Duration(milliseconds: 500)),
        vehicleMassKg: m,
        driveEfficiency: eta,
      );
      final half2 = calc2.calculate(
        currentSpeedMs: kmhToMs(17),
        currentAltitudeM: 0,
        currentTime: t0.add(const Duration(seconds: 1)),
        vehicleMassKg: m,
        driveEfficiency: eta,
      );
      final halfAvg = (half1 + half2) / 2;

      expect(halfAvg, closeTo(whole, 1.5));
    });

    test('reset 後は再び初回扱いになる', () {
      final calc = PsCalculatorService();
      calcStep(calc, v1Kmh: 50, v2Kmh: 60, dtSec: 1.0);
      calc.reset();
      final ps = calc.calculate(
        currentSpeedMs: kmhToMs(60),
        currentAltitudeM: 0,
        currentTime: t0.add(const Duration(seconds: 5)),
        vehicleMassKg: m,
        driveEfficiency: eta,
      );
      expect(ps, 0.0);
    });
  });
}
