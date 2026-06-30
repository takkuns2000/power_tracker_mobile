import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:horsepower_tracker_mobile/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../app_theme.dart';
import '../../models/measurement.dart';
import '../../viewmodels/measurement_result_viewmodel.dart';
import '../../viewmodels/measurement_viewmodel.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/glass_card.dart';
import '../widgets/pro_lock_wrapper.dart';

class MeasurementResultView extends StatelessWidget {
  const MeasurementResultView({super.key, required this.viewModel});

  final MeasurementResultViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MeasurementResultViewModel>.value(
      value: viewModel,
      child: const _MeasurementResultBody(),
    );
  }
}

class _MeasurementResultBody extends StatelessWidget {
  const _MeasurementResultBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MeasurementResultViewModel>();
    final isPro = vm.isMeasurementPro;
    final m = vm.measurement;
    final l10n = AppLocalizations.of(context)!;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      final String? err = vm.saveError ?? vm.shareError;
      if (err != null) {
        if (vm.saveError != null) vm.clearSaveError();
        if (vm.shareError != null) vm.clearShareError();
        showConfirmDialog<void>(
          context: context,
          icon: Icons.error_outline,
          title: l10n.inputError,
          content: Text(err),
          okLabel: l10n.close,
        );
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.background,
      appBar: _ResultAppBar(
        onClose: () async {
          final resultVm = context.read<MeasurementResultViewModel>();
          if (resultVm.hasPendingChanges) {
            final shouldSave = await showDialog<bool>(
              context: context,
              barrierColor: Colors.black.withValues(alpha: 0.6),
              builder: (ctx) => ConfirmDialog(
                icon: Icons.edit_note_outlined,
                title: 'メモの変更',
                content: const Text('入力中のメモを保存しますか？'),
                actions: [
                  ConfirmDialogButton(
                    label: '変更を削除',
                    onPressed: () => Navigator.of(ctx).pop(false),
                  ),
                ],
                okLabel: '保存する',
                onOk: () => Navigator.of(ctx).pop(true),
              ),
            );
            if (!context.mounted) return;
            if (shouldSave == true) {
              await resultVm.savePendingMemo();
              if (!context.mounted) return;
            }
          }
          context.read<MeasurementViewModel>().reset();
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DateHeader(measuredAt: m.measuredAt),
              const SizedBox(height: 8),
              _PeakHpSection(maxHp: vm.maxHp),
              const SizedBox(height: 24),
              _ChartCard(
                hpValues: vm.graphAxisMode == GraphAxisMode.rpm
                    ? vm.rpmChartPoints
                    : vm.hpValues,
                isPro: isPro,
              ),
              const SizedBox(height: 16),
              _ProBento(
                isPro: isPro,
                maxTorqueKgm: vm.maxTorqueKgm,
                isRpmMode: vm.graphAxisMode == GraphAxisMode.rpm,
                canToggleRpmAxis: isPro && vm.canToggleRpmAxis,
                onToggleAxis: () => context
                    .read<MeasurementResultViewModel>()
                    .toggleGraphAxis(),
                isLossOverrideActive: vm.isLossOverrideActive,
                onToggleLoss: () => context
                    .read<MeasurementResultViewModel>()
                    .toggleLossOverride(),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<bool>(
                valueListenable: vm.vehicleExpandedNotifier,
                builder: (_, isExpanded, _) => _VehicleCard(
                  measurement: m,
                  isExpanded: isExpanded,
                  onToggle: () => context
                      .read<MeasurementResultViewModel>()
                      .toggleVehicleExpanded(),
                ),
              ),
              const SizedBox(height: 16),
              _ConditionsCard(measurement: m),
              const SizedBox(height: 16),
              _MemoCard(
                initialMemo: m.memo,
                onSave: (memo) =>
                    context.read<MeasurementResultViewModel>().saveMemo(memo),
                onChanged: (text) => context
                    .read<MeasurementResultViewModel>()
                    .updatePendingMemo(text),
              ),
              const SizedBox(height: 24),
              const _ShareRow(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ResultAppBar({required this.onClose});
  final Future<void> Function() onClose;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ClipRRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 64 + MediaQuery.of(context).padding.top,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.8),
            border: Border(
              bottom: BorderSide(
                color: AppColors.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.analytics_outlined,
                        color: AppColors.primary, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      l10n.measurementResult,
                      style: GoogleFonts.sora(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close,
                      color: AppColors.onSurfaceVariant),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.measuredAt});
  final DateTime measuredAt;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final date =
        '${measuredAt.year}.${measuredAt.month.toString().padLeft(2, '0')}.${measuredAt.day.toString().padLeft(2, '0')}';
    final time =
        '${measuredAt.hour.toString().padLeft(2, '0')}:${measuredAt.minute.toString().padLeft(2, '0')}';
    return Column(
      children: [
        Text(l10n.measurementDateTime,
            style: AppTextStyles.labelCaps(context)
                .copyWith(fontSize: 10, letterSpacing: 2)),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$date ',
                style: AppTextStyles.bodyMd(context)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              TextSpan(
                text: time,
                style: AppTextStyles.bodyMd(context)
                    .copyWith(color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PeakHpSection extends StatelessWidget {
  const _PeakHpSection({required this.maxHp});
  final double maxHp;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Text(l10n.peakPowerReached,
            style: AppTextStyles.labelCaps(context)
                .copyWith(color: AppColors.primary.withValues(alpha: 0.7))),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: maxHp.toStringAsFixed(1),
                style: GoogleFonts.sora(
                  fontSize: 64,
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                  color: AppColors.primary,
                  letterSpacing: -2.5,
                  shadows: [
                    Shadow(
                        color: AppColors.primary.withValues(alpha: 0.6),
                        blurRadius: 15),
                    Shadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 30),
                  ],
                ),
              ),
              TextSpan(
                text: ' ${l10n.unitHp}',
                style: GoogleFonts.sora(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

HpPoint _findNearestPoint(
    double tapX, double chartWidth, List<HpPoint> points,
    {GraphAxisMode axisMode = GraphAxisMode.time}) {
  if (axisMode == GraphAxisMode.rpm) {
    final rpmPoints = points.where((p) => p.rpm != null).toList();
    if (rpmPoints.isNotEmpty) {
      final minRpm = rpmPoints.map((p) => p.rpm!).reduce((a, b) => a < b ? a : b);
      final maxRpm = rpmPoints.map((p) => p.rpm!).reduce((a, b) => a > b ? a : b);
      final range = (maxRpm - minRpm).toDouble();
      if (range > 0) {
        return rpmPoints.reduce((a, b) {
          final ax = chartWidth * (a.rpm! - minRpm) / range;
          final bx = chartWidth * (b.rpm! - minRpm) / range;
          return (tapX - ax).abs() < (tapX - bx).abs() ? a : b;
        });
      }
    }
  }
  final firstMs = points.first.offsetMs;
  final totalMs = points.last.offsetMs - firstMs;
  return points.reduce((a, b) {
    final ax = chartWidth * (a.offsetMs - firstMs) / totalMs;
    final bx = chartWidth * (b.offsetMs - firstMs) / totalMs;
    return (tapX - ax).abs() < (tapX - bx).abs() ? a : b;
  });
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.hpValues, required this.isPro});
  final List<HpPoint> hpValues;
  final bool isPro;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vm = context.watch<MeasurementResultViewModel>();
    final axisMode = vm.graphAxisMode;
    final isRpm = axisMode == GraphAxisMode.rpm;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.chartPowerHp,
                    style: AppTextStyles.labelCaps(context),
                  ),
                ],
              ),
              if (isPro)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isRpm
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(l10n.pro,
                          style: AppTextStyles.labelCaps(context).copyWith(
                            color: AppColors.primary,
                            fontSize: 10,
                          )),
                      const SizedBox(width: 8),
                      Text(l10n.chartRpmAxis,
                          style: AppTextStyles.labelCaps(context).copyWith(
                            color: isRpm
                                ? AppColors.primary
                                : AppColors.onSurfaceVariant,
                            fontSize: 10,
                          )),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: hpValues.isEmpty
                ? Center(
                    child: Text(l10n.noData,
                        style: AppTextStyles.labelCaps(context)
                            .copyWith(color: AppColors.onSurfaceVariant)),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return ValueListenableBuilder<HpPoint?>(
                        valueListenable: vm.selectedPointNotifier,
                        builder: (context, selectedPoint, _) {
                          final firstMs = hpValues.first.offsetMs;
                          final totalMs =
                              (hpValues.last.offsetMs - firstMs).toDouble();
                          final maxHp = hpValues
                              .map((p) => p.ps)
                              .reduce((a, b) => a > b ? a : b);

                          // X 座標の正規化（時間 or RPM）
                          double xFracForPoint(HpPoint p) {
                            if (isRpm && p.rpm != null) {
                              final rpmPoints = hpValues
                                  .where((h) => h.rpm != null)
                                  .toList();
                              if (rpmPoints.length >= 2) {
                                final minRpm = rpmPoints
                                    .map((h) => h.rpm!)
                                    .reduce((a, b) => a < b ? a : b);
                                final maxRpm = rpmPoints
                                    .map((h) => h.rpm!)
                                    .reduce((a, b) => a > b ? a : b);
                                final range = (maxRpm - minRpm).toDouble();
                                if (range > 0) {
                                  return (p.rpm! - minRpm) / range;
                                }
                              }
                            }
                            return totalMs > 0
                                ? (p.offsetMs - firstMs) / totalMs
                                : 0.0;
                          }

                          Positioned? tooltip;
                          if (selectedPoint != null) {
                            final xFrac = xFracForPoint(selectedPoint);
                            const cardWidth = 88.0;
                            final left =
                                (constraints.maxWidth * xFrac - cardWidth / 2)
                                    .clamp(0.0, constraints.maxWidth - cardWidth);
                            final pointY = constraints.maxHeight *
                                (1 - selectedPoint.ps / maxHp);
                            final hasTorqueRow =
                                isPro && selectedPoint.torqueKgm != null;
                            final cardHeight = hasTorqueRow ? 72.0 : 52.0;
                            final showBelow =
                                pointY < constraints.maxHeight / 2;
                            final top = showBelow
                                ? (pointY + 24).clamp(
                                    0.0, constraints.maxHeight - cardHeight)
                                : (pointY - cardHeight - 24).clamp(
                                    0.0, constraints.maxHeight - cardHeight);
                            tooltip = Positioned(
                              left: left,
                              top: top,
                              child: _ChartTooltipContent(
                                point: selectedPoint,
                                firstMs: firstMs,
                                isPro: isPro,
                                axisMode: axisMode,
                              ),
                            );
                          }
                          return GestureDetector(
                            onTapDown: (details) {
                              final point = _findNearestPoint(
                                details.localPosition.dx,
                                constraints.maxWidth,
                                hpValues,
                                axisMode: axisMode,
                              );
                              vm.selectChartPoint(point);
                            },
                            onTapCancel: () => vm.selectChartPoint(null),
                            child: Stack(
                              children: [
                                CustomPaint(
                                  painter: _HpChartPainter(
                                    hpValues: hpValues,
                                    selectedPoint: selectedPoint,
                                    isPro: isPro,
                                    axisMode: axisMode,
                                  ),
                                  child: const SizedBox.expand(),
                                ),
                                ?tooltip,
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            isRpm ? l10n.chartRpmX1000 : l10n.chartTimeElapsed,
            style: AppTextStyles.labelCaps(context).copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _ChartTooltipContent extends StatelessWidget {
  const _ChartTooltipContent({
    required this.point,
    required this.firstMs,
    required this.isPro,
    this.axisMode = GraphAxisMode.time,
  });
  final HpPoint point;
  final int firstMs;
  final bool isPro;
  final GraphAxisMode axisMode;

  @override
  Widget build(BuildContext context) {
    final elapsedSec = (point.offsetMs - firstMs) / 1000.0;
    final xLabel = axisMode == GraphAxisMode.rpm && point.rpm != null
        ? '${point.rpm!} RPM'
        : '${elapsedSec.toStringAsFixed(1)} 秒';

    return Container(
      width: 88,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${point.ps.toStringAsFixed(1)} PS',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (isPro && point.torqueKgm != null) ...[
            const SizedBox(height: 2),
            Text(
              '${point.torqueKgm!.toStringAsFixed(1)} kgm',
              style: const TextStyle(color: AppColors.secondary, fontSize: 11),
            ),
          ],
          const SizedBox(height: 2),
          Text(
            xLabel,
            style: const TextStyle(
                color: AppColors.onSurfaceVariant, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _HpChartPainter extends CustomPainter {
  const _HpChartPainter({
    required this.hpValues,
    this.selectedPoint,
    this.isPro = false,
    this.axisMode = GraphAxisMode.time,
  });
  final List<HpPoint> hpValues;
  final HpPoint? selectedPoint;
  final bool isPro;
  final GraphAxisMode axisMode;

  static const _torqueColor = Color(0xFFFFB347);

  // X 座標正規化（時間 or RPM）
  double _xFrac(HpPoint p, int firstMs, double totalMs,
      int minRpm, int maxRpm) {
    if (axisMode == GraphAxisMode.rpm && p.rpm != null) {
      final range = (maxRpm - minRpm).toDouble();
      if (range > 0) return (p.rpm! - minRpm) / range;
    }
    return totalMs > 0 ? (p.offsetMs - firstMs) / totalMs : 0.0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (hpValues.length < 2) return;

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    for (final y in [
      size.height * 0.17,
      size.height * 0.5,
      size.height * 0.83,
    ]) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final maxHp = hpValues.map((p) => p.ps).reduce((a, b) => a > b ? a : b);
    if (maxHp <= 0) return;

    final firstMs = hpValues.first.offsetMs;
    final totalMs = (hpValues.last.offsetMs - firstMs).toDouble();

    // RPM 軸のレンジ計算
    final rpmPoints = hpValues.where((p) => p.rpm != null).toList();
    final minRpm = rpmPoints.isNotEmpty
        ? rpmPoints.map((p) => p.rpm!).reduce((a, b) => a < b ? a : b)
        : 0;
    final maxRpm = rpmPoints.isNotEmpty
        ? rpmPoints.map((p) => p.rpm!).reduce((a, b) => a > b ? a : b)
        : 0;

    // 描画対象点（RPM モードは rpm != null のみ）
    final drawPoints = axisMode == GraphAxisMode.rpm
        ? rpmPoints
        : hpValues;
    if (drawPoints.length < 2) return;

    // トルク曲線（PRO、データあり）
    if (isPro) {
      final torquePoints = drawPoints.where((p) => p.torqueKgm != null).toList();
      if (torquePoints.length >= 2) {
        final maxTorque = torquePoints
            .map((p) => p.torqueKgm!)
            .reduce((a, b) => a > b ? a : b);
        if (maxTorque > 0) {
          final torquePaint = Paint()
            ..color = _torqueColor.withValues(alpha: 0.7)
            ..strokeWidth = 2
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke;
          final torquePath = Path();
          var first = true;
          for (final p in torquePoints) {
            final x = size.width *
                _xFrac(p, firstMs, totalMs, minRpm, maxRpm);
            final y = size.height * (1 - 0.5 * p.torqueKgm! / maxTorque);
            if (first) {
              torquePath.moveTo(x, y);
              first = false;
            } else {
              torquePath.lineTo(x, y);
            }
          }
          canvas.drawPath(torquePath, torquePaint);
        }
      }
    }

    // 馬力曲線
    final hpPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (var i = 0; i < drawPoints.length; i++) {
      final x = size.width *
          _xFrac(drawPoints[i], firstMs, totalMs, minRpm, maxRpm);
      final y = size.height * (1 - drawPoints[i].ps / maxHp);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, hpPaint);

    final peakIndex = drawPoints.indexWhere((p) => p.ps == maxHp);
    if (peakIndex >= 0) {
      final peakX = size.width *
          _xFrac(drawPoints[peakIndex], firstMs, totalMs, minRpm, maxRpm);
      canvas.drawCircle(
          Offset(peakX, 0), 5, Paint()..color = AppColors.primary);
    }

    if (selectedPoint != null) {
      final selX = size.width *
          _xFrac(selectedPoint!, firstMs, totalMs, minRpm, maxRpm);
      canvas.drawLine(
        Offset(selX, 0),
        Offset(selX, size.height),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.3)
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(_HpChartPainter old) =>
      hpValues != old.hpValues ||
      selectedPoint != old.selectedPoint ||
      isPro != old.isPro ||
      axisMode != old.axisMode;
}

class _ProBento extends StatelessWidget {
  const _ProBento({
    required this.isPro,
    required this.maxTorqueKgm,
    required this.isRpmMode,
    required this.canToggleRpmAxis,
    required this.onToggleAxis,
    required this.isLossOverrideActive,
    required this.onToggleLoss,
  });
  final bool isPro;
  final double? maxTorqueKgm;
  final bool isRpmMode;
  final bool canToggleRpmAxis;
  final VoidCallback onToggleAxis;
  final bool isLossOverrideActive;
  final VoidCallback onToggleLoss;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 110),
            child: ProLockWrapper(
              isPro: isPro,
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.statMaxTorque,
                        style: AppTextStyles.labelCaps(context)
                            .copyWith(fontSize: 10)),
                    const SizedBox(height: 12),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: maxTorqueKgm != null
                                ? maxTorqueKgm!.toStringAsFixed(1)
                                : '--',
                            style: GoogleFonts.sora(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondary,
                            ),
                          ),
                          TextSpan(
                            text: ' kgm',
                            style: AppTextStyles.labelCaps(context)
                                .copyWith(color: AppColors.secondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ProLockWrapper(
            isPro: isPro,
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.proSettings,
                    style: AppTextStyles.labelCaps(context).copyWith(
                      color: AppColors.primary,
                      fontSize: 9,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _LossToggleChip(
                    label: l10n.chartRpmAxis,
                    active: isRpmMode,
                    onTap: onToggleAxis,
                    disabled: !canToggleRpmAxis,
                  ),
                  const SizedBox(height: 8),
                  _LossToggleChip(
                    label: l10n.lossCoeffOverride,
                    active: isLossOverrideActive,
                    onTap: onToggleLoss,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    required this.measurement,
    required this.isExpanded,
    required this.onToggle,
  });
  final Measurement measurement;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final v = measurement.vehicleSnapshot;
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.measuredVehicle,
                                style: AppTextStyles.labelCaps(context)
                                    .copyWith(color: AppColors.primary)),
                            const SizedBox(height: 4),
                            Text(measurement.vehicleName,
                                style: AppTextStyles.headlineLg(context)),
                            const SizedBox(height: 2),
                            Text(
                                '${l10n.vehicleDetailWeight}: ${measurement.vehicleWeightKg.toStringAsFixed(0)} kg',
                                style: AppTextStyles.labelCaps(context)
                                    .copyWith(color: AppColors.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                  if (v.imagePath != null) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.file(
                        File(v.imagePath!),
                        width: double.infinity,
                        fit: BoxFit.fitWidth,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            Divider(
                height: 1, color: AppColors.primary.withValues(alpha: 0.1)),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Wrap(
                spacing: 0,
                runSpacing: 16,
                children: [
                  if (v.modelCode != null)
                    SizedBox(
                      width: 160,
                      child: _VehicleDetail(
                          label: l10n.labelModelCode,
                          value: v.modelCode!),
                    ),
                  if (v.displacementCc != null)
                    SizedBox(
                      width: 160,
                      child: _VehicleDetail(
                          label: l10n.vehicleDetailDisplacement,
                          value: '${v.displacementCc} cc'),
                    ),
                  SizedBox(
                    width: 160,
                    child: _VehicleDetail(
                        label: l10n.vehicleDetailDrivetrain,
                        value: v.drivetrain.label),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VehicleDetail extends StatelessWidget {
  const _VehicleDetail({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.labelCaps(context).copyWith(fontSize: 10)),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.bodyMd(context)),
      ],
    );
  }
}

class _ConditionsCard extends StatelessWidget {
  const _ConditionsCard({required this.measurement});
  final Measurement measurement;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lossPercent =
        (measurement.driveLossCoefficient * 100).toStringAsFixed(0);
    final temp = measurement.temperatureCelsius;
    final pressure = measurement.pressureHpa;

    return GlassCard(
      leftBorderColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.thermostat_outlined,
                  color: AppColors.primary, size: 16),
              const SizedBox(width: 8),
              Text(l10n.measurementConditions,
                  style: AppTextStyles.labelCaps(context)
                      .copyWith(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 0,
            runSpacing: 16,
            children: [
              if (temp != null)
                SizedBox(
                  width: 160,
                  child: _CondDetail(
                      label: l10n.labelTemperature,
                      value: '${temp.toStringAsFixed(1)} °C'),
                ),
              if (pressure != null)
                SizedBox(
                  width: 160,
                  child: _CondDetail(
                      label: l10n.labelPressure,
                      value: '${pressure.toStringAsFixed(1)} hPa'),
                ),
              SizedBox(
                width: 160,
                child: _CondDetail(
                    label: l10n.condDriveLoss,
                    value:
                        '${measurement.vehicleSnapshot.drivetrain.label} ($lossPercent%)'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LossToggleChip extends StatelessWidget {
  const _LossToggleChip({
    required this.label,
    required this.active,
    required this.onTap,
    this.disabled = false,
  });
  final String label;
  final bool active;
  final VoidCallback? onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color borderColor;
    final Color textColor;
    if (disabled) {
      bgColor = Colors.transparent;
      borderColor = AppColors.outline.withValues(alpha: 0.25);
      textColor = AppColors.onSurfaceVariant.withValues(alpha: 0.4);
    } else if (active) {
      bgColor = AppColors.primary.withValues(alpha: 0.15);
      borderColor = AppColors.primary;
      textColor = AppColors.primary;
    } else {
      bgColor = AppColors.surfaceContainer;
      borderColor = AppColors.primary.withValues(alpha: 0.3);
      textColor = AppColors.onSurfaceVariant;
    }

    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelCaps(context).copyWith(
            color: textColor,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}

class _CondDetail extends StatelessWidget {
  const _CondDetail({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.labelCaps(context).copyWith(fontSize: 10)),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.bodyMd(context)),
      ],
    );
  }
}

class _MemoCard extends StatelessWidget {
  const _MemoCard({
    required this.initialMemo,
    required this.onSave,
    required this.onChanged,
  });
  final String? initialMemo;
  final Future<void> Function(String?) onSave;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_note,
                  color: AppColors.onSurfaceVariant, size: 16),
              const SizedBox(width: 8),
              Text(l10n.measurementMemo,
                  style: AppTextStyles.labelCaps(context)
                      .copyWith(letterSpacing: 1.5)),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: initialMemo,
            maxLines: 3,
            style: AppTextStyles.bodyMd(context),
            decoration: InputDecoration(
              hintText: l10n.measurementMemoHint,
              contentPadding: const EdgeInsets.all(16),
              filled: true,
              fillColor: AppColors.surfaceContainer,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
            onChanged: onChanged,
            onFieldSubmitted: onSave,
          ),
        ],
      ),
    );
  }
}

class _ShareRow extends StatelessWidget {
  const _ShareRow();

  static Rect _originOf(BuildContext ctx) {
    final box = ctx.findRenderObject() as RenderBox?;
    return box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : Rect.fromLTWH(0, 0, 10, 10);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: GlassCard(
            padding: EdgeInsets.zero,
            child: Builder(
              builder: (ctx) => TextButton.icon(
                onPressed: () {
                  ctx.read<MeasurementResultViewModel>().shareImage(_originOf(ctx));
                },
                icon: const Icon(Icons.image_outlined, size: 18),
                label: Text(l10n.shareImage,
                    style: AppTextStyles.labelCaps(context)),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.onSurface,
                  minimumSize: const Size.fromHeight(52),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassCard(
            padding: EdgeInsets.zero,
            child: Builder(
              builder: (ctx) => TextButton.icon(
                onPressed: () {
                  ctx.read<MeasurementResultViewModel>().tweetImage(_originOf(ctx));
                },
                icon: const Icon(Icons.alternate_email, size: 18),
                label: Text(l10n.tweetResult,
                    style: AppTextStyles.labelCaps(context)),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.onSurface,
                  minimumSize: const Size.fromHeight(52),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

