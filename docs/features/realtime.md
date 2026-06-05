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
- lib/services/horsepower_calculator.dart — 馬力リアルタイム算出

## 実装メモ

<!-- 実装時に気づいた仕様補足・注意事項をここに追記 -->
