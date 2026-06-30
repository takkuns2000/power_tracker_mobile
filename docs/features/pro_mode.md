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
