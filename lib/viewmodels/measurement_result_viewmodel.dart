import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/measurement.dart';
import '../repositories/measurement_repository.dart';
import '../services/ps_calculator.dart';

typedef HpPoint = ({int offsetMs, double ps, double? torqueKgm, int? rpm});

enum GraphAxisMode { time, rpm }

class MeasurementResultViewModel extends ChangeNotifier {
  MeasurementResultViewModel(this._repository, Measurement measurement)
      : _measurement = measurement,
        _hpValues = _computeHpValues(measurement),
        _graphAxisMode = measurement.usedGearRatio != null
            ? GraphAxisMode.rpm
            : GraphAxisMode.time {
    _pendingMemo = measurement.memo;
  }

  final MeasurementRepository _repository;
  Measurement _measurement;
  List<HpPoint> _hpValues;
  String? _pendingMemo;

  String? _saveError;
  String? _shareError;
  GraphAxisMode _graphAxisMode;
  bool _lossOverrideActive = false;
  final vehicleExpandedNotifier = ValueNotifier<bool>(false);
  final selectedPointNotifier = ValueNotifier<HpPoint?>(null);

  Measurement get measurement => _measurement;
  List<HpPoint> get hpValues => _hpValues;
  String? get saveError => _saveError;
  String? get shareError => _shareError;
  bool get hasPendingChanges => _pendingMemo != _measurement.memo;
  GraphAxisMode get graphAxisMode => _graphAxisMode;
  bool get canToggleRpmAxis => hasRpmData;
  bool get isLossOverrideActive => _lossOverrideActive;

  void toggleGraphAxis() {
    if (!canToggleRpmAxis) return;
    _graphAxisMode = _graphAxisMode == GraphAxisMode.time
        ? GraphAxisMode.rpm
        : GraphAxisMode.time;
    selectedPointNotifier.value = null;
    notifyListeners();
  }

  void toggleLossOverride() {
    _lossOverrideActive = !_lossOverrideActive;
    _hpValues = _computeHpValues(
      _measurement,
      lossOverride: _lossOverrideActive ? 0.0 : null,
    );
    final prev = selectedPointNotifier.value;
    if (prev != null) {
      if (_graphAxisMode == GraphAxisMode.rpm) {
        selectedPointNotifier.value = null;
      } else {
        selectedPointNotifier.value = _hpValues.firstWhere(
          (p) => p.offsetMs == prev.offsetMs,
          orElse: () => _hpValues.isEmpty ? prev : _hpValues.first,
        );
      }
    }
    notifyListeners();
  }

  void clearSaveError() {
    _saveError = null;
  }

  void clearShareError() {
    _shareError = null;
  }

  void toggleVehicleExpanded() {
    vehicleExpandedNotifier.value = !vehicleExpandedNotifier.value;
  }

  void selectChartPoint(HpPoint? point) {
    selectedPointNotifier.value = point;
  }

  @override
  void dispose() {
    vehicleExpandedNotifier.dispose();
    selectedPointNotifier.dispose();
    super.dispose();
  }

  void updatePendingMemo(String text) {
    _pendingMemo = text.isEmpty ? null : text;
  }

  Future<void> savePendingMemo() async {
    if (_pendingMemo == _measurement.memo) return;
    await saveMemo(_pendingMemo);
  }

  Future<void> saveMemo(String? memo) async {
    final id = _measurement.id;
    if (id == null) return;
    final normalized = memo?.isEmpty ?? true ? null : memo;
    try {
      await _repository.updateMemo(id, normalized);
      _measurement = _measurement.copyWith(memo: normalized);
      _pendingMemo = normalized;
    } catch (e) {
      debugPrint('[MeasurementResultViewModel] saveMemo error: $e');
      _saveError = 'メモの保存に失敗しました。';
    }
    notifyListeners();
  }

  Future<void> saveDriveLossCoefficient(double coefficient) async {
    final id = _measurement.id;
    if (id == null) return;
    try {
      await _repository.updateDriveLossCoefficient(id, coefficient);
      _measurement = _measurement.copyWith(driveLossCoefficient: coefficient);
      _lossOverrideActive = false;
      _hpValues = _computeHpValues(_measurement);
    } catch (e) {
      debugPrint('[MeasurementResultViewModel] saveDriveLoss error: $e');
      _saveError = '駆動ロス係数の保存に失敗しました。';
    }
    notifyListeners();
  }

  Future<void> shareImage(Rect origin) async {
    String? err;
    try {
      final file = await _createShareImage(_measurement);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          sharePositionOrigin: origin,
        ),
      );
    } catch (e) {
      debugPrint('[MeasurementResultViewModel] shareImage error: $e');
      err = '画像の共有に失敗しました。';
    }
    if (err != null) {
      _shareError = err;
      notifyListeners();
    }
  }

  Future<void> tweetImage(Rect origin) async {
    final text =
        '${_measurement.vehicleName} — ${_measurement.maxHp.toStringAsFixed(1)} PS 計測しました！ #HorsepowerTracker';
    String? err;
    try {
      final file = await _createShareImage(_measurement);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: text,
          sharePositionOrigin: origin,
        ),
      );
    } catch (e) {
      debugPrint('[MeasurementResultViewModel] tweetImage error: $e');
      err = '画像の共有に失敗しました。';
    }
    if (err != null) {
      _shareError = err;
      notifyListeners();
    }
  }

  static List<HpPoint> _computeHpValues(Measurement m, {double? lossOverride}) {
    if (m.dataPoints.isEmpty) return [];
    final calculator = PsCalculatorService();
    final lossCoeff = lossOverride ?? m.driveLossCoefficient;
    final driveEfficiency = 1.0 - lossCoeff;

    final usedGear = m.usedGearRatio;
    final finalGear = m.finalGearRatio;
    final tireOuter = m.vehicleSnapshot.tireSize?.outerDiameterM;
    final canCalcTorque =
        usedGear != null && finalGear != null && tireOuter != null;

    return m.dataPoints.map((dp) {
      final time = m.measuredAt.add(Duration(milliseconds: dp.offsetMs));
      final speedMs = dp.speedKmh / 3.6;
      final ps = calculator.calculate(
        currentSpeedMs: speedMs,
        currentAltitudeM: dp.altitudeM,
        currentTime: time,
        vehicleMassKg: m.vehicleWeightKg,
        driveEfficiency: driveEfficiency,
      );
      final torqueKgm = canCalcTorque
          ? PsCalculatorService.calcTorqueKgm(
              powerPs: ps,
              speedMs: speedMs,
              gearRatio: usedGear,
              finalRatio: finalGear,
              tireOuterDiameterM: tireOuter,
            )
          : null;
      final rpm = canCalcTorque
          ? PsCalculatorService.calcEngineRpm(
              speedMs: speedMs,
              gearRatio: usedGear,
              finalRatio: finalGear,
              tireOuterDiameterM: tireOuter,
            )
          : null;
      return (offsetMs: dp.offsetMs, ps: ps, torqueKgm: torqueKgm, rpm: rpm);
    }).toList();
  }

  double get maxHp {
    if (_hpValues.isEmpty) return _measurement.maxHp;
    return _hpValues.map((p) => p.ps).reduce(math.max);
  }

  double? get maxTorqueKgm {
    final values =
        _hpValues.map((p) => p.torqueKgm).whereType<double>().toList();
    if (values.isEmpty) return null;
    return values.reduce(math.max);
  }

  bool get isMeasurementPro => _measurement.usedGearRatio != null;
  bool get hasTorqueData => _hpValues.any((p) => p.torqueKgm != null);
  bool get hasRpmData => _hpValues.any((p) => p.rpm != null);

  List<HpPoint> get rpmChartPoints {
    final points = _hpValues.where((p) => p.rpm != null).toList();
    if (points.isEmpty) return [];
    final result = <HpPoint>[];
    int maxRpmSeen = 0;
    for (final p in points) {
      if (p.rpm! > maxRpmSeen) {
        result.add(p);
        maxRpmSeen = p.rpm!;
      }
    }
    return result;
  }

  Future<File> _createShareImage(Measurement m) async {
    const w = 800.0;
    const h = 600.0;
    const bg = Color(0xFF0D1B2A);
    const primary = Color(0xFFFFB3B1);
    const onSurface = Color(0xFFE8E8F0);
    const muted = Color(0xFF8890A4);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, w, h));

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = bg);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, 5), Paint()..color = primary);

    void drawText(
      String text,
      double x,
      double y, {
      double fontSize = 16,
      Color color = onSurface,
      FontWeight weight = FontWeight.w400,
      bool italic = false,
    }) {
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: fontSize,
            color: color,
            fontWeight: weight,
            fontStyle: italic ? FontStyle.italic : FontStyle.normal,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: w - x - 40);
      tp.paint(canvas, Offset(x, y));
    }

    drawText('#HorsepowerTracker', 48, 28, fontSize: 13, color: muted);
    drawText(
      m.maxHp.toStringAsFixed(1),
      48,
      80,
      fontSize: 180,
      color: primary,
      weight: FontWeight.w800,
      italic: true,
    );
    drawText('PS', 48, 280,
        fontSize: 48,
        color: primary.withValues(alpha: 0.7),
        weight: FontWeight.w700);
    canvas.drawLine(
      const Offset(48, 380),
      const Offset(752, 380),
      Paint()
        ..color = primary.withValues(alpha: 0.2)
        ..strokeWidth = 1,
    );
    drawText(m.vehicleName, 48, 400, fontSize: 36, weight: FontWeight.w700);

    final date =
        '${m.measuredAt.year}.${m.measuredAt.month.toString().padLeft(2, '0')}.${m.measuredAt.day.toString().padLeft(2, '0')}  '
        '${m.measuredAt.hour.toString().padLeft(2, '0')}:${m.measuredAt.minute.toString().padLeft(2, '0')}';
    drawText(date, 48, 460, fontSize: 18, color: muted);
    drawText('${m.vehicleWeightKg.toStringAsFixed(0)} kg', 48, 496,
        fontSize: 16, color: muted);

    final picture = recorder.endRecording();
    final image = await picture.toImage(w.toInt(), h.toInt());
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = Uint8List.view(data!.buffer);

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/hp_share.png');
    await file.writeAsBytes(bytes);
    return file;
  }
}
