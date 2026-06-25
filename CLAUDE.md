# HorsepowerTracker

**IMPORTANT: 会話を開始する前に必ず [README.md](README.md) を読むこと。** MCPサーバーの設定・利用方法などの重要な開発環境情報が記載されている。

See [README.md](README.md) for project overview.
Specs: [docs/requirements_specification.md](docs/requirements_specification.md), [docs/basic_specification.md](docs/basic_specification.md), [docs/data_specification.md](docs/data_specification.md), [docs/design_specification.md](docs/design_specification.md)

## Testing

- テスト種別：ユニットテスト（ViewModel・Repository のロジック）。Widget テストは書かない
- テストファイル配置：`test/viewmodels/`、`test/repositories/`
- モックライブラリ：`mocktail`
- テスト内では `package:flutter_test/flutter_test.dart` を使う（Widget テスト機能は使わないがユニットテスト関数を提供する）
- 実行コマンド：`fvm flutter test`
- **新機能を実装したら対応するユニットテストを必ず追加すること**

## Commands

```bash
fvm flutter pub get
fvm flutter run
fvm flutter test
fvm flutter analyze
fvm flutter build apk
fvm flutter build ipa
```

## Architecture

- Pattern: MVVM
- State: Provider only — no setState
- Widgets: StatelessWidget only — no StatefulWidget
- UI text: 言語ファイルで多言語対応（日本語・英語）予定。別ブランチで実装予定のため、現時点のハードコードテキストは後で移行が必要

### MVVM 厳守ルール
Model - ViewModel - Viewのアーキテクチャを採用する。
- Model :　モデルクラス
- ViewModel : UIの状態を持ったり、ロジックの呼び出しなどを行う
- View : UI部分
View が直接触れるのは ViewModel のみ。以下は禁止：

- 例`context.read<Repository>()` — View から Repository を直接取得しない
- 例`context.read<XxxService>()` — View から Service を直接取得しない
- Repository / Service への直接アクセスは必ず ViewModel 経由にする

### UIコンポーネント規約

- **カード表示は必ず `GlassCard` を使う** — 表示カード・アクションエリアを問わず、画面内の独立したコンテンツ単位はすべて `lib/views/widgets/glass_card.dart` の `GlassCard` でラップする
- **ダイアログは必ず `showConfirmDialog` を使う** — `AlertDialog` 直接使用禁止。`lib/views/widgets/confirm_dialog.dart` の `showConfirmDialog` / `ConfirmDialog` を使う

### エラーハンドリング規約

- **エラーキャッチは ViewModel で行う**。View に例外を伝播させない（View に try/catch を書かない）
- ViewModel はエラー状態（`String? loadError` 等）をフィールドで公開し、`clearXxxError()` でリセットする
- **エラーはすべてダイアログ表示**。View は `addPostFrameCallback` を使い `build()` 内でダイアログを起動する
- ユーザー操作に起因しないエラー（ロード失敗等）も同様にダイアログで通知する

## Directory

```
lib/
├── models/
├── viewmodels/
├── views/
│   ├── measurement/
│   ├── realtime/
│   ├── records/
│   └── garage/
├── repositories/
└── services/
```

## Subagents

機能実装時は対応する機能ドキュメントをコンテキストに渡してSubagentを起動する。

| 機能 | ドキュメント |
|------|------------|
| 計測 | [docs/features/measurement.md](docs/features/measurement.md) |
| リアルタイム | [docs/features/realtime.md](docs/features/realtime.md) |
| 記録 | [docs/features/records.md](docs/features/records.md) |
| ガレージ・車両設定 | [docs/features/garage.md](docs/features/garage.md) |
| Pro Mode | [docs/features/pro_mode.md](docs/features/pro_mode.md) |

## Skills

スキルは自動では使用されない。以下のタイミングで適宜使用を促すこと。

| コマンド | 用途 | 使用タイミング |
|---------|------|-------------|
| `/self-review` | アーキテクチャ規約・バグのセルフレビュー | PR作成前 |
| `/security-review` | セキュリティ脆弱性のレビュー | PR作成前 |
| `/commit-commands:commit` | コミットの作成 | 実装完了時 |
| `/commit-commands:commit-push-pr` | コミット・プッシュ・PR作成を一括実行 | レビュー依頼時 |
| `/commit-commands:clean_gone` | リモートで削除済みのローカルブランチを一括削除 | ブランチが増えてきたとき |
| `/feature-dev:feature-dev` | コードベースを理解した上でのガイド付き機能実装 | 新機能の実装開始時 |

### 推奨フロー

```
実装完了 → /self-review → /security-review → /commit-commands:commit-push-pr
```
