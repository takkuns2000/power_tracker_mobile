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
| ギア比登録（1〜8速＋ファイナル） | vehicle_settings_screen |

## 関連サービス

- lib/services/purchase_service.dart — 課金・プラン判定

## 実装メモ

<!-- 課金ライブラリ選定・Pro判定の実装方針をここに追記 -->
