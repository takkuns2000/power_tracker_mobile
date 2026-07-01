# Pro Mode

Spec: [basic_specification.md](../basic_specification.md) § 6
Spec: [requirements_specification.md](../requirements_specification.md) § 4

## 機能一覧

| 機能 | 対象画面 |
|------|---------|
| 計測中のトルクリアルタイム表示 | measuring_screen |
| 計測結果のトルクグラフ表示 | measurement_result_screen |
| グラフ横軸を回転数に切替 | measurement_result_screen |
| 2台以上の車両登録 | garage_screen, vehicle_settings_screen |
| ギア比登録（1〜7速＋ファイナル） | vehicle_settings_screen |

## 課金方式

- **形式：** サブスクリプション（自動更新型）
- **ライブラリ：** `in_app_purchase`（Flutter 公式）
- **Pro 判定：** ローカルキャッシュを持たず、アプリ起動時・フォアグラウンド復帰時に `in_app_purchase` へ直接問い合わせる
  - プラットフォーム（StoreKit / Google Play Billing）がネイティブ側でサブスク状態を管理するため、オフラインでも直近の状態を返す
  - `shared_preferences` 等への保存は行わない（平文保存による改ざんリスクを避けるため）

```
アプリ起動 / フォアグラウンド復帰
  → PurchaseService.checkProStatus()
  → in_app_purchase でサブスク状態を取得
  → ViewModel に isPro を通知
  → 各画面で Pro 機能の表示を切り替え
```

## 関連サービス

- lib/services/purchase_service.dart — サブスク状態の問い合わせ・Pro 判定

## 実装メモ

### デバッグ環境（課金モックの切り替え）

開発中は `--dart-define=DEBUG_PRO=true` で PRO 状態を有効化できる。

```bash
fvm flutter run --dart-define=DEBUG_PRO=true   # PRO ON
fvm flutter run                                 # PRO OFF（デフォルト）
```

VS Code では `.vscode/launch.json` に「Debug (PRO ON)」「Debug (PRO OFF)」の構成を追加済み。  
`PurchaseService.debugTogglePro()` によるランタイム切り替えも引き続き使用可能。

リリースビルドでは `--dart-define` を付与しないため `isPro = false` のまま。

### トルク計算

**計算式（`PsCalculatorService.calcTorqueKgm`）:**

```
wheel_rpm    = (speedMs / (π × tireOuterDiameterM)) × 60
engine_rpm   = wheel_rpm × usedGearRatio × finalGearRatio
torque [N·m] = P [W] / (engine_rpm × π / 30)
torque [kgm] = torque [N·m] / 9.80665
```

**前提条件：** 計測前にギア選択が必要。  
- ユーザーが計測画面でギアを選択（`MeasurementViewModel.setSelectedGear()`）
- 車両にタイヤサイズ・ギア比が設定済みの場合のみ選択 UI を表示
- `Measurement.usedGearRatio` / `finalGearRatio` として保存

### グラフ横軸 RPM 切替

- `MeasurementResultViewModel.toggleGraphAxis()` で `GraphAxisMode.time ↔ rpm` を切り替え
- RPM データ（`HpPoint.rpm`）が存在しない場合は切り替えボタンを無効化
- RPM データは `usedGearRatio` / `finalGearRatio` / `tireSize` がすべて揃っているときのみ生成される
- **PRO 計測はデフォルトで RPM 軸表示**（`MeasurementResultViewModel` コンストラクタで初期値設定）

### RPM グラフの重複表示防止

GPS 由来の速度データは計測中に落ち込みが発生することがあり、同一 RPM 帯に複数点が生じる。
`rpmChartPoints` getter で単調増加フィルタを適用して解決：

```dart
// MeasurementResultViewModel.rpmChartPoints
// → RPM が前の点より大きい点のみを通す（単調増加）
```

### トルクグラフのデュアルスケール表示

馬力グラフと同一キャンバスに描画するが、独立スケールで表示：

```
torque Y 座標 = size.height × (1 - 0.5 × torqueKgm / maxTorque)
```

ピーク時にグラフ高さの 50% 付近に表示される。`powerPs <= 0` の場合はトルク値を `0.0` で返す。

### PRO 計測の判定方法

計測記録が PRO モードで取得されたかどうかの判定は **ユーザーの現在のサブスク状態ではなく計測データで行う**。

```dart
// Measurement.usedGearRatio != null → PRO 計測
bool get isMeasurementPro => _measurement.usedGearRatio != null;
```

- PRO 計測の結果画面: `isPro = vm.isMeasurementPro`（サブスク状態に依存しない）
- History カードの PRO バッジ: `m.usedGearRatio != null` で表示
- これにより PRO 解約後も過去の PRO 計測データは引き続き参照可能

### PRO 非計測データの表示

非 PRO 計測を結果画面で開いた場合、トルク・回転数エリアは `ProLockWrapper(mode: ProLockMode.notMeasured)` でぼかし表示。

- 表示テキスト：「トルク・回転数グラフ / PRO モードで計測すると表示されます」
- `ProLockMode.upgrade`（計測中画面・未契約ユーザー向け）とは別メッセージ

### 計測準備画面のバリデーション優先度

PRO モード有効時のエラー表示優先順位：

1. 車両未登録 → 「ガレージから車両を登録してください」
2. ギア比未設定 → 「車両設定からギア比を設定してください」
3. タイヤサイズ未設定 → 「車両設定からタイヤサイズを設定してください」
4. ギア未選択 → 「計測ギアの選択をしてください」

### 複数台登録制限

- `GarageViewModel.canAddVehicle` = `isPro || vehicles.isEmpty`
- フリープランは 1 台まで。2 台目以降の追加時に PRO へのアップグレードを促すダイアログを表示

### in_app_purchase 統合（未実装・別タスク）

`PurchaseService.checkStatus()` を以下の方針で実装すること：

1. `InAppPurchase.instance.queryProductDetails({productId})` でサブスク商品情報を取得
2. `InAppPurchase.instance.purchaseStream` をリッスンしてサブスク状態を購読
3. レシート検証はプラットフォーム（StoreKit / Google Play Billing）側に委ねる
4. `shared_preferences` への保存は行わない（改ざん防止）
5. アプリ起動時・`AppLifecycleState.resumed` 時に `checkStatus()` を呼ぶ

**商品 ID（要設定）：**
- App Store Connect / Google Play Console での登録が必要
- 現在は未定のため、プロダクション実装時に追記すること
