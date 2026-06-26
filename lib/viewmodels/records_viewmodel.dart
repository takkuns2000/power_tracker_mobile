import 'package:flutter/foundation.dart';
import '../models/measurement.dart';
import '../repositories/measurement_repository.dart';
import 'measurement_result_viewmodel.dart';
import 'navigation_viewmodel.dart';

class RecordsViewModel extends ChangeNotifier {
  RecordsViewModel(this._repository, this._navigation) {
    _navigation.addListener(_onNavigate);
    load();
  }

  final MeasurementRepository _repository;
  final NavigationViewModel _navigation;

  List<Measurement> _records = [];
  bool _isLoading = false;
  String? _loadError;
  String? _deleteError;

  List<Measurement> get records => List.unmodifiable(_records);
  bool get isLoading => _isLoading;
  String? get loadError => _loadError;
  String? get deleteError => _deleteError;

  MeasurementResultViewModel createResultViewModel(Measurement m) {
    return MeasurementResultViewModel(_repository, m);
  }

  void _onNavigate() {
    if (_navigation.currentIndex == 2) load();
  }

  void clearLoadError() {
    _loadError = null;
  }

  void clearDeleteError() {
    _deleteError = null;
  }

  Future<void> delete(int id) async {
    try {
      await _repository.delete(id);
      _records = _records.where((r) => r.id != id).toList();
    } catch (e) {
      debugPrint('[RecordsViewModel] delete error: $e');
      _deleteError = '記録の削除に失敗しました。';
    }
    notifyListeners();
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

  @override
  void dispose() {
    _navigation.removeListener(_onNavigate);
    super.dispose();
  }
}
