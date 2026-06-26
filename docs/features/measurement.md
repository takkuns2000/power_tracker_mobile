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

**主目的は加速時のピーク馬力計測**。LIVE（等速時）の馬力は 0 でよい。

`lib/sample/dart_package_1_base.dart` に元となる計算コードがある（**変更禁止**）。
sample の `engineWork = m·v2²/(2η) − m·v1²/2` は η を v2² だけに掛ける非対称形で、
等速時に `m·v²(1−η)/(2η)`（＝運動エネルギーの一定割合）が損失として残り、105km/h で
約111PS と過大になる（実損失の約15〜20倍）。これは「運動エネルギーの損失」を計上して
しまう誤りなので、実装（`lib/services/ps_calculator.dart`）では以下に是正している：
- 運動量から得た**ホイール出力に対して**集約ロス係数で /η する（対称形）
- ロスは「運動エネルギーの割合」ではなく「エンジン→ホイールの伝達損失」として扱う
- ロス係数は**駆動系＋転がり抵抗＋空気抵抗を集約**した値（走行抵抗は別項にしない）

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
| `driveEfficiency` (η) | 駆動方式により可変 | FWD=0.90 / RWD=0.85 / AWD=0.80（`Drivetrain.driveEfficiency` から取得。= 1 − 集約ロス係数） |
| `g` | 9.80665 | 重力加速度 [m/s²] |
| `wattsPerPs` | 75 × 9.80665 ≈ 735.5 | 1 PS をワットで表した値 |

### 計算ステップ（隣接する 2 GPS 点間）

運動量から得た**ホイール出力**を、集約ロス係数で**エンジン出力**へ換算する。

```
v1, v2 : 前後の速度 [m/s]
Δt     : 経過時間 [s]
Δh     : 標高差 [m]（後 − 前）
m      : 車両重量 [kg]
η      : 駆動効率 (0.85) ＝ 1 − 集約ロス係数
g      : 9.80665 [m/s²]

# 1. 運動エネルギー差 [J]
ΔKE = m × (v2² − v1²) / 2

# 2. 位置エネルギー差 [J]
climbWork = m × g × Δh

# 3. ホイール出力 [W]（加速＋勾配を Δt で出力化）
P_wheel = (ΔKE + climbWork) / Δt

# 4. エンジン出力 [W]（集約ロス係数で換算 ＝ 伝達損失）
P_engine = P_wheel / η
if P_engine ≤ 0: PS = 0   （等速・惰行・減速・下りでは 0）

# 5. 瞬時出力 [PS]
PS = P_engine / (75 × g)          // 1 PS = 75 kgf·m/s = 735.5 W
```

> 等速時は ΔKE=0 → P_wheel=0 → **0 PS**。伝達するパワーが無ければ伝達損失も無い、という定義通りの帰結（主目的のピーク馬力は加速時に出る）。
> `P_wheel = m·a·v_avg` なので GPS 更新間隔（Δt）に依存せず安定する。

### ロス係数（集約損失）

GPS 計測はタイヤの動きから算出するため、取得できるのは**ホイール出力**のみ。
これを `÷ η` でエンジン出力（クランク馬力）へ換算する。ここでの **η（= 1 − ロス係数）は
エンジン→ホイールの伝達損失を表し、駆動系・転がり抵抗・空気抵抗を集約**した値とする。

| 駆動方式 | 既定ロス | η | 備考 |
|---------|------|---|------|
| FWD (FF) | 10% | 0.90 | 前輪駆動 |
| RWD (FR) | 15% | 0.85 | 後輪駆動 |
| AWD (4WD) | 20% | 0.80 | 四輪駆動 |

η の既定値は `lib/models/drivetrain.dart` の `driveEfficiency` getter で管理する。
計測結果画面の駆動ロス係数スライダー（`driveLossCoefficient`）で調整でき、走行抵抗ぶんを
含めて集約損失として運用する。`drivetrain` 未設定の車両は選択エラーで計算不可。

### 将来オプション: 空力切り出し（road-load モデル）

集約せず走行抵抗を物理的に切り出すと全速度域で高精度になる（**今回は不採用**、式のみ記録）。

```
P_engine = ( ΔKE/Δt + ½·ρ·Cd·A·v³ + Crr·m·g·v + m·g·Δh/Δt ) / η_駆動系
既定係数案: ρ=1.2 [kg/m³], Cd=0.30, A=2.2 [m²], Crr=0.015
```

- 集約との誤差：**40〜90km/h のピーク計測では最大〜8%（高速端）**。低速側は数%。
- 空力係数（Cd/A）を汎用固定値とした場合、実車と CdA が ±50% ズレても**この速度域では誤差 ≤ 5PS**（40km/h で 0.5PS 未満）。空力パワーは v³ なので影響が出るのは **120km/h 超**（150km/h で係数ズレ ≈ 24PS）。
- このモデルでは等速時に巡航パワー（≈20PS）が出るため 0 にはならない。
- 参考: [poweraccel.co.jp](http://www.poweraccel.co.jp/powercal.html) の「空走法」（ニュートラル惰行の減速率から走行抵抗を実測。Cd/A 不要・最も正確）。

### 実装ファイル

| ファイル | 役割 |
|---------|------|
| `lib/services/ps_calculator.dart` | LIVE画面用・リアルタイム1点間計算（`PsCalculatorService`） |
| `lib/sample/dart_package_1_base.dart` | 参照コード（変更禁止） |

### 数値検証例

| 条件 | 値 |
|---|---|
| v1 = 10 km/h → v2 = 17 km/h, Δt = 1 s, Δh = 0, m = 1090 kg, η = 0.85 | 加速 |
| **結果** | **≈ 12.7 PS**（= ΔKE/Δt/η。集約モデル） |
| v1 = v2 = 105 km/h（等速）| **0 PS**（P_wheel = 0） |
| v1 = 119 → v2 = 118 km/h（惰行）| **0 PS**（減速は 0 にクランプ） |

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
