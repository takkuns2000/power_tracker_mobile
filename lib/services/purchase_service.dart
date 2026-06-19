import 'package:flutter/foundation.dart';

class PurchaseService extends ChangeNotifier {
  bool _isPro = false;

  bool get isPro => _isPro;

  /// DEV: 開発中の Pro 切り替え用。課金実装時に in_app_purchase へ差し替える。
  void debugTogglePro() {
    assert(kDebugMode, 'debugTogglePro はデバッグビルド専用です');
    _isPro = !_isPro;
    notifyListeners();
  }

  /// アプリ起動時・フォアグラウンド復帰時に呼ぶ。
  /// TODO: in_app_purchase でサブスク状態を確認する実装に差し替える。
  Future<void> checkStatus() async {
    // mock: 現状は何もしない
  }
}
