import 'package:flutter/foundation.dart';
import '../models/measurement.dart';
import '../repositories/measurement_repository.dart';

class RecordsViewModel extends ChangeNotifier {
  RecordsViewModel(this._repository) {
    load();
  }

  final MeasurementRepository _repository;

  List<Measurement> _records = [];
  bool _isLoading = false;
  String? _loadError;

  List<Measurement> get records => List.unmodifiable(_records);
  bool get isLoading => _isLoading;
  String? get loadError => _loadError;

  void clearLoadError() {
    _loadError = null;
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      _records = await _repository.getAll();
    } catch (e) {
      debugPrint('[RecordsViewModel] load error: $e');
      _loadError = '記録の読み込みに失敗しました。';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
