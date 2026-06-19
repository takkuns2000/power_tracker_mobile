# デザイン仕様書

## 基本方針

### デザインの一貫性

- **色・フォント・スペーシング・コンポーネントは本仕様書の定義に従い、全画面で統一すること**
- 新しいスタイル値を独自に定義しない。既存のトークン（`AppColors`・`AppTextStyles`）を使う
- 既存画面と異なるスタイルを使う場合は、本仕様書を先に更新してから実装する

### UI/UX 原則

- **フィードバック**：ユーザー操作（タップ・保存・削除等）には必ず視覚的な応答を返す（ローディング表示、成功/エラー表示など）
- **必須と任意の明示**：入力フォームでは必須項目に ` *`（エラー色）を付け、任意項目は何も付けない
- **タップ領域**：タップ可能な要素は最低 48×48px を確保する
- **スクロール余白**：コンテンツ末尾には `bottomNavigationBar` の高さ分のパディングを取らない（Scaffold が自動調整）。末尾余白は `24px` 程度にとどめる
- **エラー状態**：保存失敗・バリデーションエラーは `AppColors.error` を使って明示する
- **空状態**：リストが空のときはFABで追加を促す（空状態カードとFABの重複は避ける）

---

## Source of Truth

| ファイル | 役割 |
|---------|------|
| `lib/app_theme.dart` | カラートークン・タイポグラフィ・グローバルテーマ |
| `lib/views/widgets/glass_card.dart` | カード・ゲージ等の共通ウィジェット |

---

## カラートークン（`AppColors`）

| 定数 | 値 | 用途 |
|------|----|------|
| `background` | `#00132D` | Scaffold 背景 |
| `surface` | `#1D3557` | カード・モーダル背景。GlassCard の塗り色ベース（`0x66` = 40% 透明） |
| `surfaceContainer` | `#032041` | ナビゲーションバー・入力フィールド背景 |
| `surfaceContainerHigh` | `#112A4C` | Card ウィジェットのデフォルト背景 |
| `primary` | `#E63946` | CTA・アクティブ状態・強調。保存ボタン・FAB |
| `onPrimary` | `#680011` | primary 上のコンテンツ色（直接使用は少ない） |
| `secondary` | `#98CDF2` | 数値表示・補助的強調（重量・速度等） |
| `tertiary` | `#9ECFD1` | Pro Mode 専用色（バッジ・ロックオーバーレイ・ギア比） |
| `onSurface` | `#D5E3FF` | 本文・見出しテキスト |
| `onSurfaceVariant` | `#E4BEBC` | ラベル・プレースホルダー・サブテキスト |
| `outline` | `#5B403F` | ボーダー・区切り線 |
| `error` | `#FFB4AB` | エラー状態 |

### 透明度の使い方

```dart
AppColors.primary.withValues(alpha: 0.15)  // アクティブ背景
AppColors.primary.withValues(alpha: 0.3)   // グロー・シャドウ
AppColors.outline.withValues(alpha: 0.2)   // 薄いボーダー・Divider
AppColors.onSurfaceVariant.withValues(alpha: 0.7)  // フィールドラベル
```

---

## タイポグラフィ（`AppTextStyles`）

| メソッド | フォント | サイズ | 用途 |
|---------|---------|--------|------|
| `displayHp(context)` | Sora / 800 | 64px | 馬力数値の大型表示 |
| `headlineLg(context)` | Sora / 700 | 24px | 画面タイトル・車両名 |
| `statsMd(context)` | JetBrains Mono / 600 | 20px | 数値・ギア比・重量 |
| `bodyMd(context)` | Inter / 400 | 16px | 本文・説明テキスト |
| `labelCaps(context)` | Inter / 700 | 12px | フィールドラベル・キャプション（大文字推奨） |

### よく使うカスタマイズ

```dart
// フィールドラベル
AppTextStyles.labelCaps(context).copyWith(
  color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
)

// 単位テキスト（kg / hp）
AppTextStyles.statsMd(context).copyWith(
  fontSize: 12,
  color: AppColors.onSurfaceVariant,
)

// セクション見出し（色付き）
AppTextStyles.labelCaps(context).copyWith(
  color: AppColors.primary,
  letterSpacing: 1.5,
)
```

---

## スペーシング規約

| 用途 | 値 |
|------|----|
| 画面外周 padding | `horizontal: 20` |
| セクション間 | `SizedBox(height: 16)` |
| モジュール内要素間 | `SizedBox(height: 24)` |
| 行内要素間（横並び） | `SizedBox(width: 24)` |
| ボタン底部 padding | `fromLTRB(16, 12, 16, 32)` |
| スクロール末尾余白 | `bottom: 180`（ボタン高さ分） |

---

## コンポーネントパターン

### GlassCard

`lib/views/widgets/glass_card.dart` — 共通カード。内部で `IntrinsicHeight` + `BackdropFilter` を使用。

```dart
GlassCard(
  leftBorderColor: AppColors.primary,  // 省略可。左ボーダーのアクセントカラー
  child: /* Column 等 */,
)
```

**注意：** `GlassCard` の中に `GridView` / `ListView` を入れてはいけない。
`IntrinsicHeight` が固有高さを計算できず無限ループになる。代わりに `Column` + `Row` を使う。

### 保存・CTA ボタン

```dart
Container(
  height: 64,
  decoration: BoxDecoration(
    color: AppColors.primary,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20)],
  ),
  child: /* Row(icon + text) */,
)
```

### アンダーラインフィールド（`_UnderlineField`）

`vehicle_settings_view.dart` 内に定義。`TextEditingController` は必ず ViewModel から渡す（View に持たせない）。

```dart
_UnderlineField(
  label: 'フィールド名',
  placeholder: '',            // 入力ヒントが不要なら空文字
  controller: vm.xxxController,
  keyboardType: TextInputType.number,  // 数値入力の場合
  suffix: /* 右端ウィジェット（任意）*/,
)
```

### AppBar（画面固有）

**アプリ全画面で以下のスタイルに統一すること。**

`ClipRRect` + `BackdropFilter(blur 20)` + `Container` で実装。高さは `64 + padding.top`。

| 要素 | 値 |
|------|----|
| 背景色 | `AppColors.background.withValues(alpha: 0.8)` |
| 下線 | `AppColors.outline.withValues(alpha: 0.2)`、幅 1 |
| タイトルテキスト | `GoogleFonts.sora(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.primary)` |
| アイコン色 | `AppColors.primary`、サイズ 24 |

### Pro ロック UI（`_ProLockWrapper`）

`vehicle_settings_view.dart` 内に定義。Pro 専用セクションをまるごとラップする。

```dart
_ProLockWrapper(
  isPro: isPro,      // false のとき半透明 + ロックオーバーレイを表示
  child: /* Pro専用モジュール */,
)
```

- `isPro = true` → child をそのまま返す
- `isPro = false` → `Stack` で child を `Opacity(0.35)` + ロックアイコン + アップグレード案内を重ねる
- 色は `AppColors.tertiary`（Pro = teal 系）を使う

---

## 必須・任意フィールドの表示規約

| 区分 | 表示方法 |
|------|---------|
| 必須項目 | ラベル末尾に ` *` を付ける（例：`'駆動方式設定 *'`） |
| 任意項目 | 何も付けない |

---

## アイコン使用規則

- アイコンは Material Icons を使用
- サイズは通常 `24`、キャプション横は `14〜20`
- 色は文脈に応じて `AppColors.primary` / `AppColors.onSurfaceVariant` / セクション色

---

## ジェスチャー

タップ可能要素には `GestureDetector` を使う（`InkWell` は背景にリップルが出るため原則不使用）。
