import 'package:flutter/foundation.dart';
import '../services/gps_service.dart';

export '../services/gps_service.dart' show GpsPermissionStatus;

class GpsViewModel extends ChangeNotifier {
  GpsViewModel(this._service) {
    _service.addListener(_onServiceChanged);
  }

  final GpsService _service;

  GpsPermissionStatus get permissionStatus => _service.permissionStatus;

  bool get showPermissionBanner =>
      _service.permissionStatus != GpsPermissionStatus.granted &&
      _service.permissionStatus != GpsPermissionStatus.unknown;

  Future<void> retryPermission() => _service.retryPermission();

  Future<void> openSettings() => _service.openSettings();

  Future<void> handlePermissionAction() {
    return switch (_service.permissionStatus) {
      GpsPermissionStatus.denied => _service.retryPermission(),
      _ => _service.openSettings(),
    };
  }

  void _onServiceChanged() => notifyListeners();

  @override
  void dispose() {
    _service.removeListener(_onServiceChanged);
    super.dispose();
  }
}
