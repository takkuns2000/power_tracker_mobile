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
