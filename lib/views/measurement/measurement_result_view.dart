import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:horsepower_tracker_mobile/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../app_theme.dart';
import '../../models/measurement.dart';
import '../../viewmodels/garage_viewmodel.dart';
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
    final isPro = context.watch<GarageViewModel>().isPro;
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
              _PeakHpSection(maxHp: m.maxHp),
              const SizedBox(height: 24),
              _ChartCard(hpValues: vm.hpValues),
              const SizedBox(height: 16),
              _ProBento(isPro: isPro),
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
              _ConditionsCard(
                measurement: m,
                isPro: isPro,
                onResetLoss: () => context
                    .read<MeasurementResultViewModel>()
                    .saveDriveLossCoefficient(0.0),
              ),
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

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.hpValues});
  final List<double> hpValues;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                  Text(l10n.chartPowerHp,
                      style: AppTextStyles.labelCaps(context)),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Text(l10n.pro,
                        style: AppTextStyles.labelCaps(context)
                            .copyWith(color: AppColors.primary, fontSize: 10)),
                    const SizedBox(width: 8),
                    Text(l10n.chartRpmAxis,
                        style: AppTextStyles.labelCaps(context).copyWith(
                            color: AppColors.onSurfaceVariant, fontSize: 10)),
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
                : CustomPaint(
                    painter: _HpChartPainter(hpValues: hpValues),
                    child: const SizedBox.expand(),
                  ),
          ),
          const SizedBox(height: 8),
          Text(l10n.chartTimeElapsed,
              style: AppTextStyles.labelCaps(context).copyWith(fontSize: 10)),
        ],
      ),
    );
  }
}

class _HpChartPainter extends CustomPainter {
  const _HpChartPainter({required this.hpValues});
  final List<double> hpValues;

  @override
  void paint(Canvas canvas, Size size) {
    if (hpValues.length < 2) return;

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    for (final y in [
      size.height * 0.17,
      size.height * 0.5,
      size.height * 0.83
    ]) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final maxHp = hpValues.reduce((a, b) => a > b ? a : b);
    if (maxHp <= 0) return;

    final hpPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (var i = 0; i < hpValues.length; i++) {
      final x = size.width * i / (hpValues.length - 1);
      final y = size.height * (1 - hpValues[i] / maxHp);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, hpPaint);

    final peakIndex = hpValues.indexOf(maxHp);
    final peakX = size.width * peakIndex / (hpValues.length - 1);
    canvas.drawCircle(
        Offset(peakX, 0), 5, Paint()..color = AppColors.primary);
  }

  @override
  bool shouldRepaint(_HpChartPainter old) => hpValues != old.hpValues;
}

class _ProBento extends StatelessWidget {
  const _ProBento({required this.isPro});
  final bool isPro;

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
                            text: '--',
                            style: GoogleFonts.sora(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondary,
                            ),
                          ),
                          TextSpan(
                            text: ' NM',
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
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 110),
            child: ProLockWrapper(
              isPro: isPro,
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.analytics_outlined,
                        color: AppColors.primary, size: 28),
                    const SizedBox(height: 4),
                    Text(l10n.showDetailLog,
                        style: AppTextStyles.labelCaps(context)
                            .copyWith(color: AppColors.primary, fontSize: 10)),
                  ],
                ),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
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
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.primary,
                  ),
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
  const _ConditionsCard({
    required this.measurement,
    required this.isPro,
    required this.onResetLoss,
  });
  final Measurement measurement;
  final bool isPro;
  final VoidCallback onResetLoss;

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
          if (isPro) ...[
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: onResetLoss,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Text(l10n.resetLossCoefficient,
                      style: AppTextStyles.labelCaps(context)
                          .copyWith(color: AppColors.primary, fontSize: 10)),
                ),
              ),
            ),
          ],
        ],
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

