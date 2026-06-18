# データ設計仕様書
## 馬力計測モバイルアプリ「HorsepowerTracker」

| 項目 | 内容 |
|------|------|
| ドキュメント種別 | データ設計仕様書 |
| アプリ名 | HorsepowerTracker |
| 作成日 | 2026年6月18日 |
| バージョン | 1.2 |

---

## 1. 設計方針

| 方針 | 内容 |
|------|------|
| 保存場所 | 端末ローカル SQLite のみ（外部送信なし） |
| 車両スナップショット | 計測時の Vehicle オブジェクト全体を measurements テーブルに JSON TEXT として保存。車両情報を後から編集しても過去の計測記録は変わらない |
| 車両削除 | 論理削除（is_deleted フラグ）。関連する計測記録はそのまま保持し、vehicle_snapshot_json の値で表示する |
| サンプリング頻度 | GPS 更新イベントに同期（デバイス依存、概ね 1Hz）。生 GPS データを保存し、HP・トルクは表示時に演算することで駆動ロス係数変更後も再計算可能にする |
| タイヤサイズ | 車両情報として vehicles テーブルに登録する【Pro Mode のみ】。幅(mm) / 扁平率(%) / リム径(インチ) の3値で管理し、外径を算出可能にする |
| モデル実装 | freezed + json_serializable + build_runner による自動生成を使用する |

---

## 2. テーブル定義

### 2-1. vehicles（車両）

| カラム | 型 | 制約 | 説明 |
|--------|-----|------|------|
| id | INTEGER | PK, AUTOINCREMENT | |
| name | TEXT | NOT NULL | 車名 |
| model_code | TEXT | | 型式（任意） |
| weight_kg | REAL | NOT NULL | 車両重量（kg） |
| memo | TEXT | | メモ（任意） |
| tire_width_mm | INTEGER | | タイヤ幅（mm）【Pro Mode】 |
| tire_aspect_ratio | INTEGER | | タイヤ扁平率（%）【Pro Mode】 |
| tire_rim_inch | INTEGER | | リム径（インチ）【Pro Mode】 |
| created_at | INTEGER | NOT NULL | 作成日時（Unix ms） |
| updated_at | INTEGER | NOT NULL | 更新日時（Unix ms） |
| is_deleted | INTEGER | NOT NULL, DEFAULT 0 | 論理削除フラグ（0:有効, 1:削除） |

```sql
CREATE TABLE vehicles (
  id                INTEGER PRIMARY KEY AUTOINCREMENT,
  name              TEXT    NOT NULL,
  model_code        TEXT,
  weight_kg         REAL    NOT NULL,
  memo              TEXT,
  tire_width_mm     INTEGER,
  tire_aspect_ratio INTEGER,
  tire_rim_inch     INTEGER,
  created_at        INTEGER NOT NULL,
  updated_at        INTEGER NOT NULL,
  is_deleted        INTEGER NOT NULL DEFAULT 0
);
```

---

### 2-2. gear_ratios（ギア比）【Pro Mode】

gear_number = 0 はファイナルギア比、1〜7 は各変速ギア比を表す。

| カラム | 型 | 制約 | 説明 |
|--------|-----|------|------|
| id | INTEGER | PK, AUTOINCREMENT | |
| vehicle_id | INTEGER | NOT NULL, FK → vehicles.id | 対象車両 |
| gear_number | INTEGER | NOT NULL | 0=ファイナルギア、1〜7=変速ギア |
| ratio | REAL | NOT NULL | ギア比 |

```sql
CREATE TABLE gear_ratios (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  vehicle_id  INTEGER NOT NULL,
  gear_number INTEGER NOT NULL,  -- 0: ファイナル, 1〜7: 変速ギア
  ratio       REAL    NOT NULL,
  FOREIGN KEY (vehicle_id) REFERENCES vehicles(id)
);
```

---

### 2-3. measurements（計測記録）

| カラム | 型 | 制約 | 説明 |
|--------|-----|------|------|
| id | INTEGER | PK, AUTOINCREMENT | |
| vehicle_id | INTEGER | FK → vehicles.id（NULL 可） | 紐付き車両。論理削除後も FK を保持する |
| vehicle_name | TEXT | NOT NULL | 計測時の車名（後方互換用） |
| vehicle_weight_kg | REAL | NOT NULL | 計測時の車両重量（後方互換用） |
| vehicle_snapshot_json | TEXT | NOT NULL | 計測時の Vehicle 全体を JSON 文字列で保存（タイヤサイズ・ギア比・型式含む） |
| measured_at | INTEGER | NOT NULL | 計測開始日時（Unix ms） |
| max_hp | REAL | NOT NULL | 最高馬力（PS） |
| temperature_celsius | REAL | | 気温（℃）任意入力 |
| pressure_hpa | REAL | | 大気圧（hPa）任意入力 |
| final_gear_ratio | REAL | | 使用したファイナルギア比スナップショット【Pro Mode】 |
| used_gear_ratio | REAL | | 使用した変速ギア比スナップショット【Pro Mode】 |
| drive_loss_coefficient | REAL | NOT NULL, DEFAULT 0.15 | 駆動ロス係数（0〜1）。デフォルト 0.15（15%損失） |
| memo | TEXT | | メモ（任意、後から編集可） |

```sql
CREATE TABLE measurements (
  id                     INTEGER PRIMARY KEY AUTOINCREMENT,
  vehicle_id             INTEGER,
  vehicle_name           TEXT    NOT NULL,
  vehicle_weight_kg      REAL    NOT NULL,
  vehicle_snapshot_json  TEXT    NOT NULL,
  measured_at            INTEGER NOT NULL,
  max_hp                 REAL    NOT NULL,
  temperature_celsius    REAL,
  pressure_hpa           REAL,
  final_gear_ratio       REAL,
  used_gear_ratio        REAL,
  drive_loss_coefficient REAL    NOT NULL DEFAULT 0.15,
  memo                   TEXT,
  FOREIGN KEY (vehicle_id) REFERENCES vehicles(id)
);
```

---

### 2-4. measurement_data_points（計測データポイント）

生 GPS データのみを保存する。HP・トルクは表示時に演算する。

| カラム | 型 | 制約 | 説明 |
|--------|-----|------|------|
| id | INTEGER | PK, AUTOINCREMENT | |
| measurement_id | INTEGER | NOT NULL, FK → measurements.id | 対象計測記録 |
| offset_ms | INTEGER | NOT NULL | 計測開始からの経過時間（ms） |
| speed_kmh | REAL | NOT NULL | GPS から取得した速度（km/h） |
| latitude | REAL | NOT NULL | 緯度（WGS84） |
| longitude | REAL | NOT NULL | 経度（WGS84） |
| altitude_m | REAL | NOT NULL | 標高（m） |
| accuracy_m | REAL | NOT NULL | GPS 位置精度（m）。フィルタリングに使用 |

```sql
CREATE TABLE measurement_data_points (
  id             INTEGER PRIMARY KEY AUTOINCREMENT,
  measurement_id INTEGER NOT NULL,
  offset_ms      INTEGER NOT NULL,
  speed_kmh      REAL    NOT NULL,
  latitude       REAL    NOT NULL,
  longitude      REAL    NOT NULL,
  altitude_m     REAL    NOT NULL,
  accuracy_m     REAL    NOT NULL,
  FOREIGN KEY (measurement_id) REFERENCES measurements(id)
);
```

---

## 3. テーブルリレーション

```
vehicles 1 ──── * gear_ratios          (Pro Mode、vehicle_id FK)
vehicles 1 ──── * measurements         (vehicle_id FK、NULL 可)
measurements 1 ──── * measurement_data_points  (measurement_id FK)
```

---

## 4. モデル定義（Dart）

`freezed` + `json_serializable` + `build_runner` による自動生成を使用する。

### 4-1. Vehicle

| フィールド | 型 | 説明 |
|-----------|-----|------|
| id | int? | DB の主キー |
| name | String | 車名（必須） |
| modelCode | String? | 型式（任意） |
| weightKg | double | 車両重量 kg（必須） |
| memo | String? | メモ（任意） |
| tireSize | TireSize? | タイヤサイズ【Pro Mode】 |
| gearRatios | List\<GearRatio\> | ギア比リスト【Pro Mode】（gear_number 0 = ファイナル、1〜7 = 変速） |
| createdAt | DateTime | 作成日時 |
| updatedAt | DateTime | 更新日時 |
| isDeleted | bool | 論理削除フラグ |

---

### 4-2. GearRatio【Pro Mode】

| フィールド | 型 | 説明 |
|-----------|-----|------|
| id | int? | DB の主キー |
| vehicleId | int | 対象車両 ID |
| gearNumber | int | 0=ファイナルギア、1〜7=変速ギア |
| ratio | double | ギア比 |

---

### 4-3. TireSize（値オブジェクト）【Pro Mode】

| フィールド | 型 | 説明 |
|-----------|-----|------|
| widthMm | int | タイヤ幅（mm）例: 225 |
| aspectRatio | int | 扁平率（%）例: 45 |
| rimInch | int | リム径（インチ）例: 17 |

- タイヤ外径（m）= (rimInch × 25.4 + widthMm × aspectRatio / 100 × 2) / 1000

---

### 4-4. Measurement

| フィールド | 型 | 説明 |
|-----------|-----|------|
| id | int? | DB の主キー |
| vehicleId | int? | 紐付き車両 ID |
| vehicleName | String | 計測時の車名（後方互換用） |
| vehicleWeightKg | double | 計測時の車両重量（後方互換用） |
| vehicleSnapshot | Vehicle | 計測時の Vehicle スナップショット（JSON から復元） |
| measuredAt | DateTime | 計測開始日時 |
| maxHp | double | 最高馬力（PS） |
| temperatureCelsius | double? | 気温（℃） |
| pressureHpa | double? | 大気圧（hPa） |
| finalGearRatio | double? | 使用したファイナルギア比スナップショット【Pro Mode】 |
| usedGearRatio | double? | 使用した変速ギア比スナップショット【Pro Mode】 |
| driveLossCoefficient | double | 駆動ロス係数（デフォルト 0.15） |
| memo | String? | メモ |
| dataPoints | List\<MeasurementDataPoint\> | 時系列データポイント列 |

---

### 4-5. MeasurementDataPoint

| フィールド | 型 | 説明 |
|-----------|-----|------|
| id | int? | DB の主キー |
| measurementId | int | 対象計測記録 ID |
| offsetMs | int | 計測開始からの経過時間（ms） |
| speedKmh | double | GPS から取得した速度（km/h） |
| latitude | double | 緯度 |
| longitude | double | 経度 |
| altitudeM | double | 標高（m） |
| accuracyM | double | GPS 位置精度（m） |

---

## 5. RPM 算出ロジック【Pro Mode】

計測結果詳細のグラフ横軸を回転数（RPM）に切り替える際に使用する。

```
タイヤ外径（m） = (rimInch × 25.4 + widthMm × aspectRatio / 100 × 2) / 1000

RPM = (speedKmh / 3.6) / (タイヤ外径 × π) × finalGearRatio × usedGearRatio × 60
```

- `speedKmh`：各データポイントの速度
- `finalGearRatio`：measurements.final_gear_ratio（計測時スナップショット）
- `usedGearRatio`：measurements.used_gear_ratio（計測時スナップショット）
- `TireSize`：vehicle_snapshot_json 内のタイヤサイズ（車両情報として事前登録）

---

## 6. 未決事項

| 項目 | 内容 |
|------|------|
| drive_loss_coefficient のデフォルト値 | 0.15（15%損失）を仮置き。FF/FR/4WD によって異なるため、準備画面または結果画面で選択補助を設けることも検討 |
| トルク演算 | HP と RPM から算出（トルク = HP × 716.2 / RPM）。Pro Mode の表示時に計算する |
| GPS 精度フィルタリング | accuracy_m が一定値以上のポイントを除外するかどうかは計測サービス実装時に決定 |
