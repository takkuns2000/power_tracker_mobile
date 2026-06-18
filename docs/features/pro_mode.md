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

<!-- 実装時に気づいた仕様補足・注意事項をここに追記 -->
