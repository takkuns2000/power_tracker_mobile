import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:horsepower_tracker_mobile/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../app_theme.dart';
import '../../viewmodels/measurement_viewmodel.dart';
import '../../viewmodels/garage_viewmodel.dart';
import '../widgets/pro_lock_wrapper.dart';
import 'measurement_result_view.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/glass_card.dart';

class MeasuringView extends StatelessWidget {
  const MeasuringView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MeasurementViewModel>();
    final isPro = context.watch<GarageViewModel>().isPro;
    final l10n = AppLocalizations.of(context)!;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (vm.saveError != null) {
        final error = vm.saveError!;
        vm.clearSaveError();
        showConfirmDialog<void>(
          context: context,
          icon: Icons.error_outline,
          title: l10n.inputError,
          content: Text(error),
          okLabel: l10n.close,
        );
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.background,
      appBar: _MeasuringAppBar(),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _StatusCard(startTime: vm.startTime),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _HpCard(
                              currentPs: vm.currentPs, maxPs: vm.maxPs),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ProLockWrapper(
                            isPro: isPro,
                            child: _TorqueCard(vm: vm),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _StopButton(
                  onTap: () async {
                    final vm = context.read<MeasurementViewModel>();
                    await vm.stopMeasurement();
                    if (!context.mounted) return;
                    if (vm.savedMeasurement != null) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => MeasurementResultView(
                            viewModel: vm.createResultViewModel(),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MeasuringAppBar extends StatelessWidget implements PreferredSizeWidget {
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
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.arrow_back_ios,
                          color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.timer,
                        color: AppColors.primary, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      l10n.measuring,
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


class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.startTime});
  final DateTime? startTime;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GlassCard(
      leftBorderColor: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.statusLabel,
                  style: AppTextStyles.labelCaps(context)
                      .copyWith(fontSize: 10)),
              const SizedBox(height: 4),
              Text(
                l10n.realtimeTracking,
                style: GoogleFonts.sora(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(l10n.elapsedTime,
                  style: AppTextStyles.labelCaps(context)
                      .copyWith(fontSize: 10)),
              const SizedBox(height: 4),
              StreamBuilder<int>(
                stream: Stream.periodic(
                  const Duration(milliseconds: 100),
                  (tick) => tick,
                ),
                builder: (context, _) {
                  if (startTime == null) {
                    return Text('00:00.0',
                        style: AppTextStyles.statsMd(context));
                  }
                  final elapsed = DateTime.now().difference(startTime!);
                  final minutes = elapsed.inMinutes.remainder(60)
                      .toString()
                      .padLeft(2, '0');
                  final seconds = elapsed.inSeconds.remainder(60)
                      .toString()
                      .padLeft(2, '0');
                  final tenths =
                      (elapsed.inMilliseconds ~/ 100).remainder(10);
                  return Text(
                    '$minutes:$seconds.$tenths',
                    style: AppTextStyles.statsMd(context),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HpCard extends StatelessWidget {
  const _HpCard({required this.currentPs, required this.maxPs});
  final double? currentPs;
  final double maxPs;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displayPs = currentPs != null ? currentPs!.toStringAsFixed(1) : '--';
    final peakLabel = maxPs > 0
        ? 'PEAK ${maxPs.toStringAsFixed(1)} ${l10n.unitPs}'
        : l10n.peakPowerDefault;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      fillHeight: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.estimatedPower,
                  style: AppTextStyles.labelCaps(context)
                      .copyWith(color: AppColors.onSurfaceVariant)),
              Text(peakLabel,
                  style: AppTextStyles.statsMd(context)
                      .copyWith(color: AppColors.primary, fontSize: 14)),
            ],
          ),
          Expanded(
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    displayPs,
                    style: GoogleFonts.sora(
                      fontSize: 72,
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.italic,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(l10n.unitPs,
                      style: GoogleFonts.sora(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                        color: AppColors.onSurfaceVariant,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TorqueCard extends StatelessWidget {
  const _TorqueCard({required this.vm});
  final MeasurementViewModel vm;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final torque = vm.currentTorqueKgm;
    final peak = vm.maxTorqueKgm;
    final displayTorque = torque != null ? torque.toStringAsFixed(1) : '--';
    final peakLabel = peak > 0
        ? 'PEAK ${peak.toStringAsFixed(1)} ${l10n.unitKgm}'
        : l10n.peakTorqueDefault;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      fillHeight: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.estimatedTorque,
                  style: AppTextStyles.labelCaps(context)
                      .copyWith(color: AppColors.onSurfaceVariant)),
              Text(peakLabel,
                  style: AppTextStyles.statsMd(context)
                      .copyWith(color: AppColors.primary, fontSize: 14)),
            ],
          ),
          Expanded(
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    displayTorque,
                    style: GoogleFonts.sora(
                      fontSize: 72,
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.italic,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(l10n.unitKgm,
                      style: GoogleFonts.sora(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                        color: AppColors.onSurfaceVariant,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StopButton extends StatelessWidget {
  const _StopButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            AppColors.background,
            AppColors.background.withValues(alpha: 0.8),
            Colors.transparent,
          ],
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 30,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.stop_circle_outlined,
                  color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Text(
                l10n.stopMeasurement,
                style: GoogleFonts.sora(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

