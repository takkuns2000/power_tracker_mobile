# 計測機能

Spec: [basic_specification.md](../basic_specification.md) § 2-1, 2-2, 2-3, 3

## 対象画面

| 画面 | ファイル |
|------|---------|
| 計測準備 | lib/views/measurement/measurement_preparation_screen.dart |
| 計測中 | lib/views/measurement/measuring_screen.dart |
| 計測結果詳細 | lib/views/measurement/measurement_result_screen.dart |

## ViewModel / Model / Repository

| 種別 | ファイル |
|------|---------|
| ViewModel | lib/viewmodels/measurement_viewmodel.dart |
| Model | lib/models/measurement.dart |
| Repository | lib/repositories/measurement_repository.dart |

## 関連サービス

- lib/services/gps_service.dart — GPS計測
- lib/services/horsepower_calculator.dart — 馬力算出ロジック

## 馬力計算ロジック

`lib/sample/dart_package_1_base.dart` に確定済みの計算コードがある。**このファイルは変更禁止**。`lib/services/horsepower_calculator.dart` を実装する際はこのコードを参考に同じロジックで構築すること。

| 関数 | 内容 |
|------|------|
| `calculateWork` | GPS データ列から総仕事量を算出（位置エネルギー補正あり） |
| `calculateHorsepower` | 仕事量・時間から馬力（PS）を算出。換算係数は 75（仏馬力） |
| `calculatePotentialEnergy` | 標高差から位置エネルギーを算出 |
| `calculateWorkBetweenGps` | 隣接する2点間の仕事量を算出（リアルタイム計測用） |

主要な計算式：

```
engineWork = m × v2² / (2 × 9.8 × driveEfficiency) − m × v1² / (2 × 9.8)
HP = engineWork / deltaTime / 75
RPM = speed(km/h) × 1000/60 / (π × tireDiameter) × finalGearRatio × gearRatio
```

## 実装メモ

<!-- 実装時に気づいた仕様補足・注意事項をここに追記 -->
