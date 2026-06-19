Run `git diff main...HEAD` to get all changes on this branch, then perform a self-review before merging.

Output a structured text report in Japanese with the following sections:

---

## セルフレビュー結果
- 日本語で出力すること

### 1. バグ・ロジックエラー
- null安全性の問題
- async/awaitの抜け
- 境界値・エラーハンドリングの漏れ

### 2. アーキテクチャ違反
- StatefulWidget の使用（禁止）
- setState の使用（禁止 — Provider に移行すること）
- View から直接 Repository/DB へのアクセス
- ViewModel を経由しないデータ操作

### 3. コーディング規約違反
- 不要なコメント（WHY が自明なもの）
- 未使用の import・変数

### 4. Pro Mode の境界
- 無料版で動くべき機能が Pro ガードされていないか
- Pro 専用機能が無料で使えてしまっていないか

### 5. 総合判定

**[PASS / NEEDS CHANGES]**
- Must,Shuld,Nitで優先度付けを行うこと

NEEDS CHANGES の場合は修正が必要な箇所をファイルパスと行番号で列挙する。
