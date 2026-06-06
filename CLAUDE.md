# HorsepowerTracker

**IMPORTANT: 会話を開始する前に必ず [README.md](README.md) を読むこと。** MCPサーバーの設定・利用方法などの重要な開発環境情報が記載されている。

See [README.md](README.md) for project overview.
Specs: [docs/requirements_specification.md](docs/requirements_specification.md), [docs/basic_specification.md](docs/basic_specification.md)

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
- UI text: Japanese only

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
