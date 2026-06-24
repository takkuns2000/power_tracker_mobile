# 記録機能

Spec: [basic_specification.md](../basic_specification.md) § 2-5

## 対象画面

| 画面 | ファイル |
|------|---------|
| 記録一覧 | lib/views/records/records_view.dart |
| 記録詳細 | lib/views/measurement/measurement_result_view.dart |

## ViewModel / Repository

| 種別 | ファイル |
|------|---------|
| ViewModel（一覧） | lib/viewmodels/records_viewmodel.dart |
| ViewModel（詳細） | lib/viewmodels/measurement_result_viewmodel.dart |
| Repository | lib/repositories/measurement_repository.dart |

## 実装メモ

### 記録一覧画面

- サマリーセクション：総計測回数 + 最高 HP をヘッダー下に表示
- 月別セパレーター付き一覧（降順）
- `_RecordCard` タップで詳細（`MeasurementResultView`）へ遷移

### 記録詳細画面

詳細は [measurement.md § 計測結果画面の機能](measurement.md#計測結果画面の機能) を参照。
一覧から開いた場合は `MeasurementResultViewModel` が `measurement` を受け取って動作する（`MeasurementViewModel` リセットは不要）。
