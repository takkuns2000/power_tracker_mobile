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
- `imagePath: String?` フィールド追加（車両写真のローカルファイルパス）

### 車両写真機能

**写真選択フロー（`VehicleSettingsViewModel.pickImage()`）**
1. `image_picker` でギャラリーから選択（maxWidth: 1920, quality: 90）
2. `image_cropper` で3:1比率にクロップ（maxWidth: 1080, maxHeight: 360, quality: 85）
3. `Documents/vehicle_images/{timestamp}.jpg` にコピー保存

**ファイル管理**
- 写真を差し替えた場合：古い一時ファイルを削除
- 保存せずに画面を閉じた場合：未保存の選択ファイルを `dispose()` で削除
- 車両保存時に旧パスのファイルを削除

**UI（`_PhotoModule` in vehicle_settings_view.dart）**
- `GlassCard` + `GestureDetector` でタップ選択
- 画像表示: `BoxFit.fitWidth`（横幅いっぱい、縦は自然サイズ）
- プレースホルダー: `AspectRatio(3:1)` + `add_photo_alternate_outlined` アイコン
- `errorBuilder` でファイル不在時はプレースホルダー表示（クラッシュ防止）
- ガレージ一覧・計測結果カードにも同様の表示を適用

**写真はフリー機能**
- `ProLockWrapper` の外に配置（タイヤ・ギア設定と異なりフリーで使用可）
