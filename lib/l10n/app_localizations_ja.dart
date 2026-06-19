// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get close => '閉じる';

  @override
  String get pro => 'PRO';

  @override
  String get unitKg => 'KG';

  @override
  String get unitCc => 'CC';

  @override
  String get unitPs => 'PS';

  @override
  String get unitKgm => 'kgm';

  @override
  String get unitHp => 'HP';

  @override
  String get unitKmh => 'km/h';

  @override
  String get unitSeconds => '秒';

  @override
  String get navLive => 'LIVE';

  @override
  String get navTrack => 'TRACK';

  @override
  String get navHistory => 'HISTORY';

  @override
  String get navVehicles => 'VEHICLES';

  @override
  String get garage => 'ガレージ';

  @override
  String get fleetOverview => 'Fleet Overview';

  @override
  String get vehicleCardWeight => 'Weight';

  @override
  String get vehicleCardPower => 'Power';

  @override
  String get proModeRequired => 'Pro Mode が必要です';

  @override
  String get proModeRequiredMessage => '複数車両の登録には Pro Mode へのアップグレードが必要です。';

  @override
  String get vehicleSettings => '車両設定';

  @override
  String get inputError => '入力エラー';

  @override
  String get requiredFieldsError => 'ニックネーム・重量・駆動方式は必須項目です。\n入力内容を確認してください。';

  @override
  String get vehicleSave => '車両を保存';

  @override
  String get proModeLimited => 'Pro Mode 限定';

  @override
  String get upgradeToUnlock => 'アップグレードして解放';

  @override
  String get labelVehicleNickname => '車両ニックネーム';

  @override
  String get labelModelCode => '型式';

  @override
  String get placeholderModelCode => '例：JZA80';

  @override
  String get labelVehicleWeight => '車両重量 (KG)';

  @override
  String get labelDisplacement => '排気量 (CC)';

  @override
  String get labelVehicleMemo => '車両メモ';

  @override
  String get labelDrivetrain => '駆動方式設定';

  @override
  String get proModeTireSize => 'Pro Mode：タイヤサイズ';

  @override
  String get labelTireWidth => '幅 (MM)';

  @override
  String get labelTireAspect => '扁平率 (%)';

  @override
  String get labelTireRim => 'リム径 (インチ)';

  @override
  String get proModeGearRatio => 'Pro Mode：ギア比設定';

  @override
  String get labelGear1 => '1速';

  @override
  String get labelGear2 => '2速';

  @override
  String get labelGear3 => '3速';

  @override
  String get labelGear4 => '4速';

  @override
  String get labelGear5 => '5速';

  @override
  String get labelGear6 => '6速';

  @override
  String get labelGear7 => '7速';

  @override
  String get labelFinalGear => 'ファイナルギア比';

  @override
  String get measurementPrep => '計測準備';

  @override
  String get measurementPrepSubtitle => '走行前の環境設定と車両確認を行ってください';

  @override
  String get selectVehicle => 'SELECT VEHICLE';

  @override
  String get selectVehicleHint => '車両を選択';

  @override
  String get labelTemperature => 'TEMPERATURE';

  @override
  String get labelPressure => 'PRESSURE';

  @override
  String get gpsPrecision => 'GPS PRECISION';

  @override
  String get gpsLock10Hz => 'LOCK (10Hz)';

  @override
  String get startMeasurement => '計測開始';

  @override
  String get measuring => '計測中';

  @override
  String get statusLabel => 'ステータス';

  @override
  String get realtimeTracking => 'リアルタイム追跡中';

  @override
  String get elapsedTime => '経過時間';

  @override
  String get estimatedPower => '推定馬力';

  @override
  String get peakPowerDefault => 'ピーク: -- PS';

  @override
  String get estimatedTorque => '推定トルク';

  @override
  String get peakTorqueDefault => 'ピーク: -- kgm';

  @override
  String get proFeature => 'PRO機能';

  @override
  String get stopMeasurement => '計測を停止';

  @override
  String get viewResults => '結果詳細を確認する';

  @override
  String get measurementResult => '計測結果';

  @override
  String get measurementDateTime => '計測日時';

  @override
  String get peakPowerReached => '最高出力到達';

  @override
  String get chartPowerHp => '馬力 (HP)';

  @override
  String get chartRpmX1000 => 'RPM x1000';

  @override
  String get chartRpmAxis => '回転数軸';

  @override
  String get chartTimeElapsed => '時間経過 (s)';

  @override
  String get envInputTemp => '気温 (任意)';

  @override
  String get envInputPressure => '大気圧 (任意)';

  @override
  String get stat0To100 => '0-100 KM/H';

  @override
  String get statHumidity => '湿度';

  @override
  String get statMaxTorque => '最大トルク';

  @override
  String get showDetailLog => '詳細ログを表示';

  @override
  String get measuredVehicle => '計測車両';

  @override
  String get vehicleDetailDisplacement => '排気量';

  @override
  String get vehicleDetailDrivetrain => '駆動方式';

  @override
  String get vehicleNoteHint => '車両に関する特記事項を入力...';

  @override
  String get measurementConditions => '計測環境 & コンディション';

  @override
  String get condRoadCondition => '路面状況';

  @override
  String get condAltitude => '標高（平均）';

  @override
  String get condDriveLoss => '駆動ロス係数';

  @override
  String get condTireSize => 'タイヤサイズ';

  @override
  String get condMeasurementGear => '計測ギア';

  @override
  String get measurementMemo => '計測記録メモ';

  @override
  String get measurementMemoHint => 'この計測に関するメモを残す...';

  @override
  String get exportData => 'データをエクスポート';

  @override
  String get complete => '完了';

  @override
  String get lifetimeRuns => 'Lifetime Runs';

  @override
  String get records => 'Records';

  @override
  String get peakStats => 'Peak Stats';

  @override
  String get maxHp => 'MAX HP';

  @override
  String get trendNeutral => '-- HP';

  @override
  String get ecuSyncDescription =>
      'Synchronize with ECU to import historical dyno data automatically.';

  @override
  String get latitude => 'LATITUDE';

  @override
  String get longitude => 'LONGITUDE';

  @override
  String get altitude => 'ALTITUDE';

  @override
  String get gps10Hz => 'GPS 10Hz';

  @override
  String get systemActive => 'SYSTEM ACTIVE';

  @override
  String get locationDenied => '位置情報の利用が拒否されました。タップして再度許可してください。';

  @override
  String get locationPermanentlyDenied =>
      '位置情報の利用が永続的に拒否されています。設定アプリから許可してください。';

  @override
  String get locationServiceDisabled => '位置情報サービスが無効です。端末の設定から有効にしてください。';

  @override
  String get loadError => 'データ読み込みエラー';

  @override
  String get loadErrorMessage => '車両データの読み込みに失敗しました。';
}
