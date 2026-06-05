# HorsepowerTracker

スマートフォンで自車両の馬力を計測・記録・分析するモバイルアプリです。

## 概要

GPSセンサーを活用して走行データを取得し、車両の馬力をその場で計測できます。計測結果はすべて端末内に保存され、外部サーバへの送信は一切行いません。

## 対応環境

| OS | バージョン |
|----|-----------|
| Android | 13以上（API レベル 33以上） |
| iOS | 16.0以上 |

## 主な機能

- **馬力計測** — GPSデータをもとに走行中の馬力をリアルタイム計測
- **記録閲覧** — 過去の計測結果を一覧・詳細表示
- **車両登録** — 複数車両の管理・紐付け
- **課金機能** — 追加機能のアンロック

## 技術スタック

| 項目 | 採用技術 |
|------|---------|
| フレームワーク | Flutter (fvm 3.44.1) |
| アーキテクチャ | MVVM |
| 状態管理 | Provider |
| ローカルDB | SQLite |
| 位置情報 | GPS（緯度・経度・標高） |

## セットアップ

### 前提条件

- [fvm](https://fvm.app/) がインストール済みであること
- Flutter 3.44.1（fvm により自動切替）

### 手順

```bash
# リポジトリのクローン
git clone https://github.com/takenaka/horsepower_tracker_mobile.git
cd horsepower_tracker_mobile

# Flutter バージョンのセットアップ
fvm install

# 依存パッケージのインストール
fvm flutter pub get

# アプリの起動
fvm flutter run
```

## Claude Code 開発環境

### プラグイン

以下のプラグインを使用しています。

```bash
# マーケットプレイスの追加（初回のみ）
claude plugin marketplace add anthropics/claude-code

# プラグインのインストール
claude plugin install feature-dev
claude plugin install commit-commands
claude plugin install security-guidance
```

| プラグイン | 用途 |
|-----------|------|
| `feature-dev` | 機能実装のガイド付き開発支援 |
| `commit-commands` | コミット・プッシュ・PR作成のワークフロー自動化 |
| `security-guidance` | コード変更時の脆弱性自動チェック |

### MCP サーバー

#### Dart/Flutter MCP（公式）

パッケージ検索・エラー分析・依存関係管理に使用します。

```bash
claude mcp add --transport stdio dart -- fvm dart mcp-server
```

#### Stitch MCP（Google）

AIによるUIデザイン生成に使用します。事前に以下のセットアップが必要です。

**前提条件**

- [Google Cloud SDK（gcloud）](https://cloud.google.com/sdk/docs/install) がインストール済みであること
- Node.js がインストール済みであること（`brew install node`）

**セットアップ手順**

```bash
# gcloud 認証（2種類とも必要）
gcloud auth login
gcloud auth application-default login

# Stitch API の有効化
gcloud services enable stitch.googleapis.com --project <YOUR_PROJECT_ID>

# Stitch MCP の初期設定（対話形式）
# Client: Claude Code / Connection: Direct を選択
npx @_davideast/stitch-mcp init
```

## .claudeignore

Claudeが読み込まないファイルを `.claudeignore` で管理しています。ビルド成果物・自動生成コード・機密情報ファイルを対象としています。新たに除外したいファイルがある場合は [.claudeignore](.claudeignore) に追記してください。

## データの取り扱い

計測データおよび車両情報はすべて端末内（SQLite）にローカル保存されます。外部サーバへの送信は行いません。
