import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('ja')];

  /// No description provided for @close.
  ///
  /// In ja, this message translates to:
  /// **'閉じる'**
  String get close;

  /// No description provided for @pro.
  ///
  /// In ja, this message translates to:
  /// **'PRO'**
  String get pro;

  /// No description provided for @unitKg.
  ///
  /// In ja, this message translates to:
  /// **'KG'**
  String get unitKg;

  /// No description provided for @unitCc.
  ///
  /// In ja, this message translates to:
  /// **'CC'**
  String get unitCc;

  /// No description provided for @unitPs.
  ///
  /// In ja, this message translates to:
  /// **'PS'**
  String get unitPs;

  /// No description provided for @unitKgm.
  ///
  /// In ja, this message translates to:
  /// **'kgm'**
  String get unitKgm;

  /// No description provided for @unitHp.
  ///
  /// In ja, this message translates to:
  /// **'HP'**
  String get unitHp;

  /// No description provided for @unitKmh.
  ///
  /// In ja, this message translates to:
  /// **'km/h'**
  String get unitKmh;

  /// No description provided for @unitSeconds.
  ///
  /// In ja, this message translates to:
  /// **'秒'**
  String get unitSeconds;

  /// No description provided for @navLive.
  ///
  /// In ja, this message translates to:
  /// **'LIVE'**
  String get navLive;

  /// No description provided for @navTrack.
  ///
  /// In ja, this message translates to:
  /// **'TRACK'**
  String get navTrack;

  /// No description provided for @navHistory.
  ///
  /// In ja, this message translates to:
  /// **'HISTORY'**
  String get navHistory;

  /// No description provided for @navVehicles.
  ///
  /// In ja, this message translates to:
  /// **'VEHICLES'**
  String get navVehicles;

  /// No description provided for @garage.
  ///
  /// In ja, this message translates to:
  /// **'ガレージ'**
  String get garage;

  /// No description provided for @fleetOverview.
  ///
  /// In ja, this message translates to:
  /// **'Fleet Overview'**
  String get fleetOverview;

  /// No description provided for @vehicleCardWeight.
  ///
  /// In ja, this message translates to:
  /// **'Weight'**
  String get vehicleCardWeight;

  /// No description provided for @vehicleCardPower.
  ///
  /// In ja, this message translates to:
  /// **'Power'**
  String get vehicleCardPower;

  /// No description provided for @proModeRequired.
  ///
  /// In ja, this message translates to:
  /// **'Pro Mode が必要です'**
  String get proModeRequired;

  /// No description provided for @proModeRequiredMessage.
  ///
  /// In ja, this message translates to:
  /// **'複数車両の登録には Pro Mode へのアップグレードが必要です。'**
  String get proModeRequiredMessage;

  /// No description provided for @vehicleSettings.
  ///
  /// In ja, this message translates to:
  /// **'車両設定'**
  String get vehicleSettings;

  /// No description provided for @inputError.
  ///
  /// In ja, this message translates to:
  /// **'入力エラー'**
  String get inputError;

  /// No description provided for @requiredFieldsError.
  ///
  /// In ja, this message translates to:
  /// **'ニックネーム・重量・駆動方式は必須項目です。\n入力内容を確認してください。'**
  String get requiredFieldsError;

  /// No description provided for @vehicleSave.
  ///
  /// In ja, this message translates to:
  /// **'車両を保存'**
  String get vehicleSave;

  /// No description provided for @proModeLimited.
  ///
  /// In ja, this message translates to:
  /// **'Pro Mode 限定'**
  String get proModeLimited;

  /// No description provided for @upgradeToUnlock.
  ///
  /// In ja, this message translates to:
  /// **'アップグレードして解放'**
  String get upgradeToUnlock;

  /// No description provided for @labelVehicleNickname.
  ///
  /// In ja, this message translates to:
  /// **'車両ニックネーム'**
  String get labelVehicleNickname;

  /// No description provided for @labelModelCode.
  ///
  /// In ja, this message translates to:
  /// **'型式'**
  String get labelModelCode;

  /// No description provided for @placeholderModelCode.
  ///
  /// In ja, this message translates to:
  /// **'例：JZA80'**
  String get placeholderModelCode;

  /// No description provided for @labelVehicleWeight.
  ///
  /// In ja, this message translates to:
  /// **'車両重量 (KG)'**
  String get labelVehicleWeight;

  /// No description provided for @labelDisplacement.
  ///
  /// In ja, this message translates to:
  /// **'排気量 (CC)'**
  String get labelDisplacement;

  /// No description provided for @labelVehicleMemo.
  ///
  /// In ja, this message translates to:
  /// **'車両メモ'**
  String get labelVehicleMemo;

  /// No description provided for @labelDrivetrain.
  ///
  /// In ja, this message translates to:
  /// **'駆動方式設定'**
  String get labelDrivetrain;

  /// No description provided for @proModeTireSize.
  ///
  /// In ja, this message translates to:
  /// **'Pro Mode：タイヤサイズ'**
  String get proModeTireSize;

  /// No description provided for @labelTireWidth.
  ///
  /// In ja, this message translates to:
  /// **'幅 (MM)'**
  String get labelTireWidth;

  /// No description provided for @labelTireAspect.
  ///
  /// In ja, this message translates to:
  /// **'扁平率 (%)'**
  String get labelTireAspect;

  /// No description provided for @labelTireRim.
  ///
  /// In ja, this message translates to:
  /// **'リム径 (インチ)'**
  String get labelTireRim;

  /// No description provided for @proModeGearRatio.
  ///
  /// In ja, this message translates to:
  /// **'Pro Mode：ギア比設定'**
  String get proModeGearRatio;

  /// No description provided for @labelGear1.
  ///
  /// In ja, this message translates to:
  /// **'1速'**
  String get labelGear1;

  /// No description provided for @labelGear2.
  ///
  /// In ja, this message translates to:
  /// **'2速'**
  String get labelGear2;

  /// No description provided for @labelGear3.
  ///
  /// In ja, this message translates to:
  /// **'3速'**
  String get labelGear3;

  /// No description provided for @labelGear4.
  ///
  /// In ja, this message translates to:
  /// **'4速'**
  String get labelGear4;

  /// No description provided for @labelGear5.
  ///
  /// In ja, this message translates to:
  /// **'5速'**
  String get labelGear5;

  /// No description provided for @labelGear6.
  ///
  /// In ja, this message translates to:
  /// **'6速'**
  String get labelGear6;

  /// No description provided for @labelGear7.
  ///
  /// In ja, this message translates to:
  /// **'7速'**
  String get labelGear7;

  /// No description provided for @labelFinalGear.
  ///
  /// In ja, this message translates to:
  /// **'ファイナルギア比'**
  String get labelFinalGear;

  /// No description provided for @measurementPrep.
  ///
  /// In ja, this message translates to:
  /// **'計測準備'**
  String get measurementPrep;

  /// No description provided for @measurementPrepSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'走行前の環境設定と車両確認を行ってください'**
  String get measurementPrepSubtitle;

  /// No description provided for @selectVehicle.
  ///
  /// In ja, this message translates to:
  /// **'車両選択'**
  String get selectVehicle;

  /// No description provided for @selectVehicleHint.
  ///
  /// In ja, this message translates to:
  /// **'車両を選択'**
  String get selectVehicleHint;

  /// No description provided for @labelTemperature.
  ///
  /// In ja, this message translates to:
  /// **'外気温度'**
  String get labelTemperature;

  /// No description provided for @labelPressure.
  ///
  /// In ja, this message translates to:
  /// **'気圧'**
  String get labelPressure;

  /// No description provided for @gpsPrecision.
  ///
  /// In ja, this message translates to:
  /// **'GPS 精度'**
  String get gpsPrecision;

  /// No description provided for @gpsUpdateRate.
  ///
  /// In ja, this message translates to:
  /// **'GPS 更新頻度'**
  String get gpsUpdateRate;

  /// No description provided for @gpsNoSignal.
  ///
  /// In ja, this message translates to:
  /// **'NO SIGNAL'**
  String get gpsNoSignal;

  /// No description provided for @startMeasurement.
  ///
  /// In ja, this message translates to:
  /// **'計測開始'**
  String get startMeasurement;

  /// No description provided for @measuring.
  ///
  /// In ja, this message translates to:
  /// **'計測中'**
  String get measuring;

  /// No description provided for @statusLabel.
  ///
  /// In ja, this message translates to:
  /// **'ステータス'**
  String get statusLabel;

  /// No description provided for @realtimeTracking.
  ///
  /// In ja, this message translates to:
  /// **'リアルタイム追跡中'**
  String get realtimeTracking;

  /// No description provided for @elapsedTime.
  ///
  /// In ja, this message translates to:
  /// **'経過時間'**
  String get elapsedTime;

  /// No description provided for @estimatedPower.
  ///
  /// In ja, this message translates to:
  /// **'推定馬力'**
  String get estimatedPower;

  /// No description provided for @peakPowerDefault.
  ///
  /// In ja, this message translates to:
  /// **'ピーク: -- PS'**
  String get peakPowerDefault;

  /// No description provided for @estimatedTorque.
  ///
  /// In ja, this message translates to:
  /// **'推定トルク'**
  String get estimatedTorque;

  /// No description provided for @peakTorqueDefault.
  ///
  /// In ja, this message translates to:
  /// **'ピーク: -- kgm'**
  String get peakTorqueDefault;

  /// No description provided for @proFeature.
  ///
  /// In ja, this message translates to:
  /// **'PRO機能'**
  String get proFeature;

  /// No description provided for @stopMeasurement.
  ///
  /// In ja, this message translates to:
  /// **'計測を停止'**
  String get stopMeasurement;

  /// No description provided for @viewResults.
  ///
  /// In ja, this message translates to:
  /// **'結果詳細を確認する'**
  String get viewResults;

  /// No description provided for @measurementResult.
  ///
  /// In ja, this message translates to:
  /// **'計測結果'**
  String get measurementResult;

  /// No description provided for @measurementDateTime.
  ///
  /// In ja, this message translates to:
  /// **'計測日時'**
  String get measurementDateTime;

  /// No description provided for @peakPowerReached.
  ///
  /// In ja, this message translates to:
  /// **'最高出力到達'**
  String get peakPowerReached;

  /// No description provided for @chartPowerHp.
  ///
  /// In ja, this message translates to:
  /// **'馬力 (HP)'**
  String get chartPowerHp;

  /// No description provided for @chartRpmX1000.
  ///
  /// In ja, this message translates to:
  /// **'RPM x1000'**
  String get chartRpmX1000;

  /// No description provided for @chartRpmAxis.
  ///
  /// In ja, this message translates to:
  /// **'回転数軸'**
  String get chartRpmAxis;

  /// No description provided for @chartTimeElapsed.
  ///
  /// In ja, this message translates to:
  /// **'時間経過 (s)'**
  String get chartTimeElapsed;

  /// No description provided for @envInputTemp.
  ///
  /// In ja, this message translates to:
  /// **'気温 (任意)'**
  String get envInputTemp;

  /// No description provided for @envInputPressure.
  ///
  /// In ja, this message translates to:
  /// **'大気圧 (任意)'**
  String get envInputPressure;

  /// No description provided for @stat0To100.
  ///
  /// In ja, this message translates to:
  /// **'0-100 KM/H'**
  String get stat0To100;

  /// No description provided for @statHumidity.
  ///
  /// In ja, this message translates to:
  /// **'湿度'**
  String get statHumidity;

  /// No description provided for @statMaxTorque.
  ///
  /// In ja, this message translates to:
  /// **'最大トルク'**
  String get statMaxTorque;

  /// No description provided for @showDetailLog.
  ///
  /// In ja, this message translates to:
  /// **'詳細ログを表示'**
  String get showDetailLog;

  /// No description provided for @measuredVehicle.
  ///
  /// In ja, this message translates to:
  /// **'計測車両'**
  String get measuredVehicle;

  /// No description provided for @vehicleDetailDisplacement.
  ///
  /// In ja, this message translates to:
  /// **'排気量'**
  String get vehicleDetailDisplacement;

  /// No description provided for @vehicleDetailDrivetrain.
  ///
  /// In ja, this message translates to:
  /// **'駆動方式'**
  String get vehicleDetailDrivetrain;

  /// No description provided for @vehicleDetailWeight.
  ///
  /// In ja, this message translates to:
  /// **'車両重量'**
  String get vehicleDetailWeight;

  /// No description provided for @noData.
  ///
  /// In ja, this message translates to:
  /// **'データなし'**
  String get noData;

  /// No description provided for @vehicleNoteHint.
  ///
  /// In ja, this message translates to:
  /// **'車両に関する特記事項を入力...'**
  String get vehicleNoteHint;

  /// No description provided for @measurementConditions.
  ///
  /// In ja, this message translates to:
  /// **'計測環境'**
  String get measurementConditions;

  /// No description provided for @condRoadCondition.
  ///
  /// In ja, this message translates to:
  /// **'路面状況'**
  String get condRoadCondition;

  /// No description provided for @condAltitude.
  ///
  /// In ja, this message translates to:
  /// **'標高（平均）'**
  String get condAltitude;

  /// No description provided for @condDriveLoss.
  ///
  /// In ja, this message translates to:
  /// **'駆動ロス係数'**
  String get condDriveLoss;

  /// No description provided for @condTireSize.
  ///
  /// In ja, this message translates to:
  /// **'タイヤサイズ'**
  String get condTireSize;

  /// No description provided for @condMeasurementGear.
  ///
  /// In ja, this message translates to:
  /// **'計測ギア'**
  String get condMeasurementGear;

  /// No description provided for @measurementMemo.
  ///
  /// In ja, this message translates to:
  /// **'計測記録メモ'**
  String get measurementMemo;

  /// No description provided for @measurementMemoHint.
  ///
  /// In ja, this message translates to:
  /// **'この計測に関するメモを残す...'**
  String get measurementMemoHint;

  /// No description provided for @resetLossCoefficient.
  ///
  /// In ja, this message translates to:
  /// **'係数を1にリセット'**
  String get resetLossCoefficient;

  /// No description provided for @shareImage.
  ///
  /// In ja, this message translates to:
  /// **'画像をシェア'**
  String get shareImage;

  /// No description provided for @tweetResult.
  ///
  /// In ja, this message translates to:
  /// **'ツイートする'**
  String get tweetResult;

  /// No description provided for @complete.
  ///
  /// In ja, this message translates to:
  /// **'完了'**
  String get complete;

  /// No description provided for @lifetimeRuns.
  ///
  /// In ja, this message translates to:
  /// **'Lifetime Runs'**
  String get lifetimeRuns;

  /// No description provided for @records.
  ///
  /// In ja, this message translates to:
  /// **'Records'**
  String get records;

  /// No description provided for @peakStats.
  ///
  /// In ja, this message translates to:
  /// **'Peak Stats'**
  String get peakStats;

  /// No description provided for @maxHp.
  ///
  /// In ja, this message translates to:
  /// **'MAX HP'**
  String get maxHp;

  /// No description provided for @trendNeutral.
  ///
  /// In ja, this message translates to:
  /// **'-- HP'**
  String get trendNeutral;

  /// No description provided for @ecuSyncDescription.
  ///
  /// In ja, this message translates to:
  /// **'Synchronize with ECU to import historical dyno data automatically.'**
  String get ecuSyncDescription;

  /// No description provided for @latitude.
  ///
  /// In ja, this message translates to:
  /// **'LATITUDE'**
  String get latitude;

  /// No description provided for @longitude.
  ///
  /// In ja, this message translates to:
  /// **'LONGITUDE'**
  String get longitude;

  /// No description provided for @altitude.
  ///
  /// In ja, this message translates to:
  /// **'ALTITUDE'**
  String get altitude;

  /// No description provided for @gps10Hz.
  ///
  /// In ja, this message translates to:
  /// **'GPS 10Hz'**
  String get gps10Hz;

  /// No description provided for @systemActive.
  ///
  /// In ja, this message translates to:
  /// **'SYSTEM ACTIVE'**
  String get systemActive;

  /// No description provided for @systemInactive.
  ///
  /// In ja, this message translates to:
  /// **'SYSTEM INACTIVE'**
  String get systemInactive;

  /// No description provided for @locationDenied.
  ///
  /// In ja, this message translates to:
  /// **'位置情報の利用を許可してください'**
  String get locationDenied;

  /// No description provided for @locationPermanentlyDenied.
  ///
  /// In ja, this message translates to:
  /// **'位置情報の利用を許可してください'**
  String get locationPermanentlyDenied;

  /// No description provided for @locationServiceDisabled.
  ///
  /// In ja, this message translates to:
  /// **'位置情報の利用を許可してください'**
  String get locationServiceDisabled;

  /// No description provided for @locationPermissionMessage.
  ///
  /// In ja, this message translates to:
  /// **'位置情報が許可されていません'**
  String get locationPermissionMessage;

  /// No description provided for @locationPermissionAction.
  ///
  /// In ja, this message translates to:
  /// **'許可する'**
  String get locationPermissionAction;

  /// No description provided for @loadError.
  ///
  /// In ja, this message translates to:
  /// **'データ読み込みエラー'**
  String get loadError;

  /// No description provided for @loadErrorMessage.
  ///
  /// In ja, this message translates to:
  /// **'車両データの読み込みに失敗しました。'**
  String get loadErrorMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
