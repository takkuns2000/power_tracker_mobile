# 計測機能

Spec: [basic_specification.md](../basic_specification.md) § 2-1, 2-2, 2-3, 3

## 対象画面

| 画面 | ファイル |
|------|---------|
| 計測準備 | lib/views/measurement/measurement_preparation_view.dart |
| 計測中 | lib/views/measurement/measuring_view.dart |
| 計測結果詳細 | lib/views/measurement/measurement_result_view.dart |

## ViewModel / Model / Repository

| 種別 | ファイル |
|------|---------|
| ViewModel（計測フロー） | lib/viewmodels/measurement_viewmodel.dart |
| ViewModel（結果画面） | lib/viewmodels/measurement_result_viewmodel.dart |
| Model | lib/models/measurement.dart |
| Model（データポイント） | lib/models/measurement_data_point.dart |
| Repository | lib/repositories/measurement_repository.dart |

## 関連サービス

- lib/services/gps_service.dart — GPS計測
- lib/services/ps_calculator.dart — PS 算出ロジック（`PsCalculatorService`）

## 馬力計算ロジック

`lib/sample/dart_package_1_base.dart` に元となる計算コードがある。**このファイルは変更禁止**。
実装ファイル（`lib/services/ps_calculator.dart`）は以下の点で sample コードを改善している：
- 仕事量をすべて J（ジュール）に統一（sample は kgf·m と J が混在）
- 位置エネルギーにも η を適用してエンジン側へ換算（sample は η なし）
- 重力加速度を 9.8 → 9.80665 に精度向上

### 単位系

すべての仕事量を **J（ジュール）** で統一し、最後に目的の出力単位へ変換する。

| 量 | 単位 | 備考 |
|---|---|---|
| 速度入力 | m/s | GPS から直接取得 |
| 質量 | kg | |
| 標高 | m | |
| 仕事量（全て） | J | 中間計算はすべて J に統一 |
| 出力（瞬時） | W | J / s |
| 表示単位 | PS | 仏馬力（metric horsepower） |

### 定数

| 定数 | 値 | 説明 |
|---|---|---|
| `driveEfficiency` (η) | 駆動方式により可変 | FWD=0.90 / RWD=0.85 / AWD=0.80（`Drivetrain.driveEfficiency` から取得） |
| `g` | 9.80665 | 重力加速度 [m/s²] |
| `wattsPerPs` | 75 × 9.80665 ≈ 735.5 | 1 PS をワットで表した値 |

### 計算ステップ（隣接する 2 GPS 点間）

```
v1, v2 : 前後の速度 [m/s]
Δt     : 経過時間 [s]
Δh     : 標高差 [m]（後 − 前）
m      : 車両重量 [kg]
η      : 駆動効率 (0.85)
g      : 9.80665 [m/s²]

# 1. 運動エネルギー差 [J]
ke2 = m × v2² / (2η)    ← エンジンが今から v2 を実現するために出力すべきエネルギー（η で損失分を上乗せ）
ke1 = m × v1² / 2       ← すでに車両に蓄えられているエネルギー。η なし（過去の計算で損失は支払い済み）
engineWork = ke2 − ke1  [J]

# ke1 に η を付けない理由：
# ke1/η にすると engineWork = (ke2−ke1)/η = ΔKE/η となり、等速走行で 0 になる。
# η なしで引くことで等速時も正の値（ドライブトレインの常時損失補填分）が得られる。
# 等速時: ke2/η − ke1 = m×v²×(1−η)/(2η) > 0

# 2. 位置エネルギー差 [J]（エンジン出力換算）
potentialEnergy = m × g × Δh / η  [J]   ← KE の ke2 と同様、η でエンジン側に換算

# 3. 合計仕事量 [J]
totalWork = engineWork + potentialEnergy
if totalWork ≤ 0: PS = 0  （減速・下り坂のみは出力しない）

# 4. 瞬時出力 [PS]
power [W] = totalWork / Δt
PS = power / (75 × g)          // 1 PS = 75 kgf·m/s = 735.5 W
```

### ロス馬力（ドライブトレイン損失）

GPS 計測はタイヤの動きから算出するため、取得できるのは**ホイール馬力**（車輪出力）のみ。
`ke2 = m × v2² / (2η)` の `÷ η` により、ホイール馬力からエンジン出力（クランク馬力）を逆算する。

η は車両の駆動方式（`Drivetrain`）に応じて自動決定される。`drivetrain` が未設定の車両は選択エラーとなり計算不可。

| 駆動方式 | 損失 | η | 備考 |
|---------|------|---|------|
| FWD (FF) | 10% | 0.90 | 前輪駆動 |
| RWD (FR) | 15% | 0.85 | 後輪駆動 |
| AWD (4WD) | 20% | 0.80 | 四輪駆動 |

η の値は `lib/models/drivetrain.dart` の `driveEfficiency` getter で管理する。

### 実装ファイル

| ファイル | 役割 |
|---------|------|
| `lib/services/ps_calculator.dart` | LIVE画面用・リアルタイム1点間計算（`PsCalculatorService`） |
| `lib/sample/dart_package_1_base.dart` | 参照コード（変更禁止） |

### 数値検証例

| 条件 | 値 |
|---|---|
| v1 = 10 km/h → v2 = 17 km/h | Δv = +7 km/h |
| Δt = 1 s、Δh = 0 m | 標高変化なし |
| m = 1090 kg | sample デフォルト値 |
| **結果** | **≈ 13.7 PS**（Δh = 0 のため potentialEnergy = 0、sample と同値） |

### RPM 計算（Pro Mode 専用）

LIVE 画面では表示しない。計測グラフ（Pro Mode）でのみ使用。

```
RPM = speed[km/h] × 1000/60 / (π × tireDiameter[m]) × finalGearRatio × gearRatio
```

## 実装メモ

### 計測フロー

1. **計測準備画面**：車両選択ドロップダウン + 外気温・気圧入力 + GPS信号品質表示
2. **計測中画面**：開始/停止ボタン、リアルタイム HP 表示（現在値・最大値）、速度ストリーク背景アニメーション
3. **計測結果画面**：AppBar 右端の Close ボタン（×）でリセット＆トップへ戻る

### データ保存

- GPS 更新ごとに `MeasurementDataPoint`（offsetMs・speedKmh・緯度・経度・高度・精度）を収集
- 計測停止時に `Measurement` + `MeasurementDataPoint[]` を SQLite に一括保存（`MeasurementRepository`）
- `vehicleSnapshot` として計測時点の車両情報を JSON 文字列で保存（後から車両を変更・削除しても記録が残る）

### 計測結果画面の機能

- `MeasurementResultViewModel` で結果データを管理（`measurement_result_viewmodel.dart`）
- HP 推移グラフ（CustomPaint 折れ線）
  - データ型: `List<HpPoint>`（`typedef HpPoint = ({int offsetMs, double ps})`、`measurement_result_viewmodel.dart` で定義）
  - 横軸は `offsetMs`（実経過時間）に比例。GPS 更新間隔が不均一でも時間軸が正確になる
  - インデックス均等割りは使用禁止（GPS 更新頻度が変動すると時間軸が歪むため）
- 駆動ロス係数スライダー（Pro: リセットボタンあり）
- メモ入力・保存
- 車両情報展開パネル
- 画像シェア / ツイートボタン（`_ShareRow`）
  - `PictureRecorder` + `Canvas` で 800×600px の PNG を生成
  - `share_plus v13`（`ShareParams` + `sharePositionOrigin`）で共有
  - シェアロジックは ViewModel に集約（MVVM 厳守）
