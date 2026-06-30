import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:horsepower_tracker_mobile/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../app_theme.dart';
import '../../viewmodels/garage_viewmodel.dart';
import '../../viewmodels/measurement_viewmodel.dart';
import 'measuring_view.dart';
import '../widgets/glass_card.dart';
import '../widgets/vehicle_dropdown_card.dart';

class MeasurementPreparationView extends StatelessWidget {
  const MeasurementPreparationView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MeasurementViewModel>();
    final garageVm = context.watch<GarageViewModel>();
    final isPro = garageVm.isPro;
    final proModeActive = vm.proModeActive(isPro);
    final l10n = AppLocalizations.of(context)!;

    String? validationError;
    if (proModeActive && vm.selectedVehicleId != null) {
      final vehicle = vm.selectedVehicle;
      final hasGearRatios = vehicle?.gearRatios.isNotEmpty == true;
      final hasTireSize = vehicle?.tireSize != null;
      if (!hasGearRatios) {
        validationError = l10n.errorSetGearRatio;
      } else if (!hasTireSize) {
        validationError = l10n.errorSetTireSize;
      } else if (vm.selectedGearIndex == null) {
        validationError = l10n.errorSelectGear;
      }
    }
    final canStart = vm.selectedVehicleId != null &&
        (!proModeActive || (vm.canSelectGear && vm.selectedGearIndex != null));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _TrackAppBar(proModeActive: proModeActive),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SectionTitle(),
              const SizedBox(height: 6),
              Text(
                validationError ?? '',
                style: AppTextStyles.bodyMd(context).copyWith(
                  color: AppColors.error,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              VehicleDropdownCard(
                vehicles: garageVm.vehicles,
                selectedId: vm.selectedVehicleId,
                onChanged: (vehicle) =>
                    context.read<MeasurementViewModel>().selectVehicle(vehicle),
              ),
              if (proModeActive && vm.canSelectGear) ...[
                const SizedBox(height: 12),
                _GearSelectorCard(vm: vm),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _EnvInputCard(
                      label: l10n.labelTemperature,
                      unit: '°C',
                      onChanged: (v) => context
                          .read<MeasurementViewModel>()
                          .setTemperature(double.tryParse(v)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _EnvInputCard(
                      label: l10n.labelPressure,
                      unit: 'hPa',
                      onChanged: (v) => context
                          .read<MeasurementViewModel>()
                          .setPressure(double.tryParse(v)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _VehicleStatusCard(),
              const SizedBox(height: 16),
              _GpsRateCard(),
              const Spacer(),
              _StartButton(
                enabled: canStart,
                onTap: () {
                  context.read<MeasurementViewModel>().startMeasurement();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const MeasuringView()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrackAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _TrackAppBar({required this.proModeActive});
  final bool proModeActive;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final garageVm = context.watch<GarageViewModel>();
    final isPro = garageVm.isPro;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
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
                    const Icon(Icons.timer_outlined,
                        color: AppColors.primary, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      l10n.navTrack,
                      style: GoogleFonts.sora(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: isPro
                      ? () => context
                          .read<MeasurementViewModel>()
                          .toggleProMode(proModeActive)
                      : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: proModeActive
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: proModeActive
                            ? AppColors.primary
                            : AppColors.outline.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      proModeActive ? l10n.proModeOn : l10n.proModeOff,
                      style: AppTextStyles.labelCaps(context).copyWith(
                        fontSize: 10,
                        color: proModeActive
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.measurementPrep,
          style: GoogleFonts.sora(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _EnvInputCard extends StatelessWidget {
  const _EnvInputCard({
    required this.label,
    required this.unit,
    required this.onChanged,
  });
  final String label;
  final String unit;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.labelCaps(context)
                  .copyWith(color: AppColors.primary, fontSize: 9)),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextFormField(
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: AppTextStyles.statsMd(context),
                  decoration: InputDecoration(
                    hintText: '--',
                    hintStyle: AppTextStyles.statsMd(context)
                        .copyWith(color: AppColors.onSurfaceVariant),
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: AppColors.primary, width: 2),
                    ),
                    filled: false,
                  ),
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(width: 8),
              Text(unit, style: AppTextStyles.statsMd(context)),
            ],
          ),
        ],
      ),
    );
  }
}

class _GearSelectorCard extends StatelessWidget {
  const _GearSelectorCard({required this.vm});
  final MeasurementViewModel vm;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final gears = vm.selectableGears;
    final gearLabels = [
      l10n.labelGear1, l10n.labelGear2, l10n.labelGear3, l10n.labelGear4,
      l10n.labelGear5, l10n.labelGear6, l10n.labelGear7,
    ];

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Text(l10n.condMeasurementGear,
              style: AppTextStyles.labelCaps(context)
                  .copyWith(fontSize: 10, color: AppColors.onSurface)),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...gears.map((g) {
                    final idx = g.gearNumber - 1;
                    final label = idx < gearLabels.length
                        ? gearLabels[idx]
                        : '${g.gearNumber}速';
                    return _GearChip(
                      label: label,
                      selected: vm.selectedGearIndex == g.gearNumber,
                      onTap: () => vm.setSelectedGear(g.gearNumber),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GearChip extends StatelessWidget {
  const _GearChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.2)
                : Colors.transparent,
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.outline.withValues(alpha: 0.4),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: AppTextStyles.labelCaps(context).copyWith(
              fontSize: 10,
              color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _VehicleStatusCard extends StatelessWidget {
  static const _kGpsBlue = AppColors.secondary;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MeasurementViewModel>();
    final l10n = AppLocalizations.of(context)!;
    final isLocked = vm.isGpsLocked;
    final accuracyM = vm.gpsAccuracyM;
    final segments = vm.gpsPrecisionSegments;

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      leftBorderColor: _kGpsBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.gpsPrecision,
              style: AppTextStyles.labelCaps(context)
                  .copyWith(color: _kGpsBlue)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                isLocked
                    ? accuracyM!.toStringAsFixed(1)
                    : l10n.gpsNoSignal,
                style: AppTextStyles.statsMd(context).copyWith(
                  color: isLocked
                      ? AppColors.onSurface
                      : AppColors.onSurfaceVariant,
                ),
              ),
              if (isLocked) ...[
                const SizedBox(width: 4),
                Text('m', style: AppTextStyles.statsMd(context)),
              ],
              const Spacer(),
              GaugeSegmentRow(
                filledCount: segments,
                totalCount: 8,
                color: _kGpsBlue,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GpsRateCard extends StatelessWidget {
  static const _kGpsBlue = AppColors.secondary;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MeasurementViewModel>();
    final l10n = AppLocalizations.of(context)!;
    final hz = vm.gpsUpdateHz;
    final segments = vm.gpsHzSegments;

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      leftBorderColor: _kGpsBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.gpsUpdateRate,
              style: AppTextStyles.labelCaps(context).copyWith(color: _kGpsBlue)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                hz != null ? hz.toStringAsFixed(1) : '--',
                style: AppTextStyles.statsMd(context).copyWith(
                  color: hz != null ? AppColors.onSurface : AppColors.onSurfaceVariant,
                ),
              ),
              if (hz != null) ...[
                const SizedBox(width: 4),
                Text('Hz', style: AppTextStyles.statsMd(context)),
              ],
              const Spacer(),
              GaugeSegmentRow(filledCount: segments, totalCount: 8, color: _kGpsBlue),
            ],
          ),
        ],
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.enabled, required this.onTap});
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary.withValues(alpha: 0.85)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timer, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Text(
              l10n.startMeasurement,
              style: GoogleFonts.sora(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
