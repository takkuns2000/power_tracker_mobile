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

## 実装メモ

<!-- 実装時に気づいた仕様補足・注意事項をここに追記 -->
