import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:horsepower_tracker_mobile/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../app_theme.dart';
import '../../viewmodels/measurement_viewmodel.dart';
import 'measuring_view.dart';
import '../widgets/glass_card.dart';

class MeasurementPreparationView extends StatelessWidget {
  const MeasurementPreparationView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MeasurementViewModel>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _TrackAppBar(),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(),
              const SizedBox(height: 24),
              _VehicleCard(selectedVehicleId: vm.selectedVehicleId),
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
              const SizedBox(height: 32),
              _StartButton(
                enabled: vm.selectedVehicleId != null,
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
  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                    const SizedBox(width: 8),
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
        Row(
          children: [
            Text(
              l10n.measurementPrep,
              style: GoogleFonts.sora(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          l10n.measurementPrepSubtitle,
          style: AppTextStyles.bodyMd(context)
              .copyWith(color: AppColors.onSurfaceVariant, fontSize: 13),
        ),
      ],
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({required this.selectedVehicleId});
  final String? selectedVehicleId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GlassCard(
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Icon(
              Icons.directions_car,
              size: 60,
              color: AppColors.onSurface.withValues(alpha: 0.05),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.selectVehicle,
                  style: AppTextStyles.labelCaps(context)
                      .copyWith(color: AppColors.primary)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedVehicleId,
                hint: Text(l10n.selectVehicleHint,
                    style: AppTextStyles.statsMd(context)),
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
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
                dropdownColor: AppColors.surfaceContainer,
                style: AppTextStyles.statsMd(context),
                items: const [],
                onChanged: (value) {
                  if (value != null) {
                    context
                        .read<MeasurementViewModel>()
                        .selectVehicle(value);
                  }
                },
              ),
            ],
          ),
        ],
      ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.labelCaps(context)
                  .copyWith(color: AppColors.primary)),
          const SizedBox(height: 12),
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

class _VehicleStatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GlassCard(
      leftBorderColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('—', style: AppTextStyles.statsMd(context)),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.gpsPrecision,
                      style: AppTextStyles.labelCaps(context)
                          .copyWith(fontSize: 10)),
                  Text(l10n.gpsLock10Hz,
                      style: AppTextStyles.labelCaps(context)
                          .copyWith(color: AppColors.primary, fontSize: 10)),
                ],
              ),
              const SizedBox(height: 8),
              GaugeSegmentRow(filledCount: 4, totalCount: 8),
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
                fontStyle: FontStyle.italic,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
