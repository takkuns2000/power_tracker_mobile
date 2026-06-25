import 'dart:async';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';

enum GpsPermissionStatus {
  unknown,
  granted,
  denied,
  permanentlyDenied,
  serviceDisabled,
}

class GpsService extends ChangeNotifier with WidgetsBindingObserver {
  GpsPermissionStatus _permissionStatus = GpsPermissionStatus.unknown;
  Position? _lastPosition;
  StreamSubscription<Position>? _positionSub;
  bool _observerRegistered = false;

  GpsPermissionStatus get permissionStatus => _permissionStatus;
  Position? get lastPosition => _lastPosition;

  Future<void> initialize() async {
    if (!_observerRegistered) {
      WidgetsBinding.instance.addObserver(this);
      _observerRegistered = true;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _permissionStatus = GpsPermissionStatus.serviceDisabled;
      notifyListeners();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      _permissionStatus = GpsPermissionStatus.permanentlyDenied;
      notifyListeners();
      return;
    }

    if (permission == LocationPermission.denied) {
      _permissionStatus = GpsPermissionStatus.denied;
      notifyListeners();
      return;
    }

    _permissionStatus = GpsPermissionStatus.granted;
    notifyListeners();
    _startStream();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _permissionStatus != GpsPermissionStatus.granted) {
      _recheckPermission();
    }
  }

  Future<void> _recheckPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _permissionStatus = GpsPermissionStatus.serviceDisabled;
      notifyListeners();
      return;
    }

    final permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.deniedForever) {
      _permissionStatus = GpsPermissionStatus.permanentlyDenied;
      notifyListeners();
      return;
    }

    if (permission == LocationPermission.denied) {
      _permissionStatus = GpsPermissionStatus.denied;
      notifyListeners();
      return;
    }

    _permissionStatus = GpsPermissionStatus.granted;
    notifyListeners();
    _startStream();
  }

  void _startStream() {
    _positionSub?.cancel();
    late final LocationSettings settings;
    if (defaultTargetPlatform == TargetPlatform.android) {
      settings = AndroidSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
        intervalDuration: Duration.zero,
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
               defaultTargetPlatform == TargetPlatform.macOS) {
      settings = AppleSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
        activityType: ActivityType.automotiveNavigation,
      );
    } else {
      settings = const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
      );
    }
    _positionSub = Geolocator.getPositionStream(locationSettings: settings)
        .listen((position) {
      _lastPosition = position;
      notifyListeners();
    });
  }

  Future<void> retryPermission() async => initialize();

  Future<void> openSettings() async => Geolocator.openAppSettings();

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _positionSub?.cancel();
    super.dispose();
  }
}
