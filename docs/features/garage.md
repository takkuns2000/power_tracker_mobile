# ガレージ・車両設定機能

Spec: [basic_specification.md](../basic_specification.md) § 2-6, 2-7, 4

## 対象画面

| 画面 | ファイル |
|------|---------|
| ガレージ一覧 | lib/views/garage/garage_view.dart |
| 車両設定 | lib/views/garage/vehicle_settings_view.dart |

## ViewModel / Model / Repository

| 種別 | ファイル |
|------|---------|
| ViewModel | lib/viewmodels/garage_viewmodel.dart |
| Model | lib/models/vehicle.dart |
| Repository | lib/repositories/vehicle_repository.dart |

## 実装メモ

### Pro Mode ガード（ProLockWrapper）

- `lib/views/widgets/pro_lock_wrapper.dart` として独立 widget
- `Stack(fit: StackFit.passthrough)` で親の制約を通過させ、上にロックオーバーレイを重ねる
- ロック状態のオーバーレイ: `Opacity(0.35)` + 錠アイコン + "Pro Model Limited" + アップグレード促進テキスト

### Pro 機能制限対象

| 機能 | 制限内容 |
|------|---------|
| タイヤサイズ編集 | Pro のみ編集可 |
| ギアレシオ編集 | Pro のみ編集可 |
| 計測結果 トルク表示 | Pro のみ表示 |
| 計測結果 詳細ログ | Pro のみ表示 |
| 駆動ロス係数リセット | Pro のみボタン表示 |

### Vehicle モデル

- `drivetrain` を `Drivetrain? → @Default(Drivetrain.fwd) Drivetrain` に変更（未設定による計算エラーを防止）
- `@freezed abstract class` 構文（freezed v3 対応）
