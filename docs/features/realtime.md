# リアルタイム機能

Spec: [basic_specification.md](../basic_specification.md) § 2-4

## 対象画面

| 画面 | ファイル |
|------|---------|
| リアルタイム | lib/views/realtime/realtime_screen.dart |

## ViewModel / Model

| 種別 | ファイル |
|------|---------|
| ViewModel | lib/viewmodels/realtime_viewmodel.dart |

## 関連サービス

- lib/services/gps_service.dart — GPS（緯度・経度・標高・速度）
- lib/services/ps_calculator.dart — PS リアルタイム算出（`PsCalculatorService`）

## PS 計算

GPS の隣接 2 点間から瞬時出力を算出する。計算式の詳細は [measurement.md § 馬力計算ロジック](measurement.md#馬力計算ロジック) を参照。

### 車両選択と計算有効条件

| 状態 | PS 表示 |
|------|---------|
| 車両選択あり・GPS 取得中 | 計算値を表示 |
| 車両未選択 | `"-"` を表示（計算スキップ） |
| 車両登録なし | `"-"` を表示（計算不可） |

- 車両が 1 台以上登録されている場合、画面表示時に自動で 1 台目を選択する
- ユーザーが手動で変更した選択は維持される

### GPS タイムアウト

最後の GPS 更新から 3 秒以上経過すると `isGpsActive = false` になりインジケータが赤に変わる。

### ゲージ表示

`GaugeSegmentRow`（10 分割）: 30 PS ごとに 1 セグメント点灯、300 PS で全灯。

```
filledCount = (ps / 30).floor().clamp(0, 10)
```

### ロス馬力（ドライブトレイン損失）

GPS 計測はタイヤの動きから算出するため、取得できるのは**ホイール馬力**（車輪出力）のみ。

`PsCalculatorService` では駆動効率 η を KE・PE の両方に適用し、エンジン出力（クランク馬力）を推定する。

```
エンジン出力 × η = タイヤ側の仕事量
→ エンジン出力 = タイヤ側の仕事量 / η

ke2 = m × v2² / (2η)   ← エンジンが今から v2 を実現するために出力すべきエネルギー（η で損失分を上乗せ）
ke1 = m × v1² / 2      ← すでに車両に蓄えられているエネルギー。η なし（過去の計算で損失は支払い済み）
PE  = m × g × Δh / η   ← ke2 と同様、η でエンジン側に換算

# ke1 に η を付けない理由：
# ke1/η にすると engineWork = ΔKE/η となり、等速走行で 0 になる。
# η なしで引くことで等速時も正の値（ドライブトレインの常時損失補填分）が得られる。
# 等速時: ke2/η − ke1 = m×v²×(1−η)/(2η) > 0
```

| 表示方針 | η | メリット | デメリット |
|---------|---|---------|-----------|
| ホイール馬力（実測） | 1.0 | GPS から正確に算出できる値をそのまま表示 | エンジン出力より低い値になる（一般的な損失 15〜20%） |
| エンジン馬力（推定） | 0.85 | 車のカタログ値に近い数値になる | 固定 η のため車種によって誤差が出る。現在の実装 |

**現在の実装**: 車両の駆動方式（`Drivetrain`）に応じて η が自動決定される。
`drivetrain` が未設定の車両を選択した場合はエラーダイアログを表示し PS 計算を行わない。
η の値は `lib/models/drivetrain.dart` の `driveEfficiency` getter で管理する。

## 実装メモ

### GPS権限フロー（実装済み）

- `lib/services/gps_service.dart` が権限チェック・リクエスト・ストリーム開始を一括管理
- `GpsService` は `ChangeNotifier` として `MultiProvider` に登録（`lib/main.dart`）
- アプリ起動時に `initialize()` が自動呼び出しされ、OSの権限ダイアログを表示
- 権限状態は `GpsPermissionStatus` 列挙型で管理（5状態）

| 状態 | 意味 | UIへの影響 |
|------|------|-----------|
| `unknown` | 初期化中 | バナーなし |
| `granted` | 許可済み・ストリーム取得中 | バナーなし |
| `denied` | 拒否（再リクエスト可） | バナー表示 → タップで再ダイアログ |
| `permanentlyDenied` | 永続拒否 | バナー表示 → タップで設定アプリへ |
| `serviceDisabled` | GPS機能が端末で無効 | バナー表示（タップ不可） |

- GPSから取得するデータ：`Position.speed`（m/s）、`Position.timestamp`
- 加速度は呼び出し側で `a = Δv/Δt` として算出する（GPSは加速度を直接提供しない）
- 更新頻度はハードウェア依存。`distanceFilter: 0` でフィルターなしの全更新を受け取る
