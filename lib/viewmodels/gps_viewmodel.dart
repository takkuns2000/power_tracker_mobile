import 'package:flutter/foundation.dart';
import '../services/gps_service.dart';

export '../services/gps_service.dart' show GpsPermissionStatus;

class GpsViewModel extends ChangeNotifier {
  GpsViewModel(this._service) {
    _service.addListener(_onServiceChanged);
  }

  final GpsService _service;

  GpsPermissionStatus get permissionStatus => _service.permissionStatus;

  Future<void> retryPermission() => _service.retryPermission();

  Future<void> openSettings() => _service.openSettings();

  void _onServiceChanged() => notifyListeners();

  @override
  void dispose() {
    _service.removeListener(_onServiceChanged);
    super.dispose();
  }
}
