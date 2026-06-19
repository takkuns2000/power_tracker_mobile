import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:horsepower_tracker_mobile/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../app_theme.dart';
import '../../viewmodels/garage_viewmodel.dart';
import '../../viewmodels/gps_viewmodel.dart';
import '../../viewmodels/realtime_viewmodel.dart';
import '../widgets/glass_card.dart';
import '../widgets/vehicle_dropdown_card.dart';

class RealtimeView extends StatelessWidget {
  const RealtimeView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RealtimeViewModel>();
    final gps = context.watch<GpsViewModel>();
    final garage = context.watch<GarageViewModel>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _RealtimeAppBar(),
      body: CustomPaint(
        painter: _GridPainter(),
        child: Container(
          color: AppColors.background,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                children: [
                  VehicleDropdownCard(
                    vehicles: garage.vehicles,
                    selectedId: vm.selectedVehicleId,
                    onChanged: (vehicle) =>
                        context.read<RealtimeViewModel>().selectVehicle(vehicle),
                  ),
                  const SizedBox(height: 16),
                  _CentralGaugeCard(
                    ps: vm.ps,
                    speedKmh: vm.speedKmh,
                  ),
                  const SizedBox(height: 16),
                  if (gps.permissionStatus != GpsPermissionStatus.granted &&
                      gps.permissionStatus != GpsPermissionStatus.unknown) ...[
                    _GpsPermissionBanner(gps: gps),
                    const SizedBox(height: 16),
                  ],
                  _GpsGrid(
                    latitude: vm.latitude,
                    longitude: vm.longitude,
                    altitudeM: vm.altitudeM,
                  ),
                  const SizedBox(height: 16),
                  _HudInfoBar(
                    isGpsActive: vm.isGpsActive,
                    gpsUpdateHz: vm.gpsUpdateHz,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.04)
      ..strokeWidth = 1;
    const spacing = 30.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _RealtimeAppBar extends StatelessWidget implements PreferredSizeWidget {
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
                    const Icon(Icons.speed,
                        color: AppColors.primary, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      l10n.navLive,
                      style: GoogleFonts.sora(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.more_vert,
                    color: AppColors.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CentralGaugeCard extends StatelessWidget {
  const _CentralGaugeCard({required this.ps, required this.speedKmh});
  final double? ps;
  final double? speedKmh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filledCount = ps != null
        ? (ps! / 30).floor().clamp(0, 10)
        : 0;

    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        children: [
          GaugeSegmentRow(filledCount: filledCount),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                ps != null
                    ? ps!.toStringAsFixed(0)
                    : '-',
                style: GoogleFonts.sora(
                  fontSize: 96,
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                  color: AppColors.primary,
                  shadows: [
                    Shadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 30,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(l10n.unitPs, style: AppTextStyles.labelCaps(context)),
            ],
          ),
          Container(
            width: 120,
            height: 1,
            margin: const EdgeInsets.symmetric(vertical: 16),
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                speedKmh != null
                    ? speedKmh!.toStringAsFixed(0)
                    : '-',
                style: GoogleFonts.sora(
                  fontSize: 64,
                  fontWeight: FontWeight.w800,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 8),
              Text(l10n.unitKmh, style: AppTextStyles.labelCaps(context)),
            ],
          ),
        ],
      ),
    );
  }
}

class _GpsGrid extends StatelessWidget {
  const _GpsGrid({
    required this.latitude,
    required this.longitude,
    required this.altitudeM,
  });
  final double? latitude;
  final double? longitude;
  final double? altitudeM;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(12),
            leftBorderColor: AppColors.primary,
            child: _GpsItem(
              label: l10n.latitude,
              value: latitude != null
                  ? '${latitude!.toStringAsFixed(4)}°N'
                  : '-',
              icon: Icons.location_on_outlined,
              iconColor: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(12),
            leftBorderColor: AppColors.secondary,
            child: _GpsItem(
              label: l10n.longitude,
              value: longitude != null
                  ? '${longitude!.toStringAsFixed(4)}°E'
                  : '-',
              icon: Icons.explore_outlined,
              iconColor: AppColors.secondary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(12),
            leftBorderColor: AppColors.tertiary,
            child: _GpsItem(
              label: l10n.altitude,
              value: altitudeM != null
                  ? '${altitudeM!.toStringAsFixed(0)} m'
                  : '-',
              icon: Icons.landscape_outlined,
              iconColor: AppColors.tertiary,
            ),
          ),
        ),
      ],
    );
  }
}

class _GpsItem extends StatelessWidget {
  const _GpsItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.labelCaps(context)
                    .copyWith(fontSize: 9),
              ),
            ),
            Icon(icon,
                color: iconColor.withValues(alpha: 0.4), size: 16),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.statsMd(context).copyWith(fontSize: 13),
        ),
      ],
    );
  }
}

class _HudInfoBar extends StatelessWidget {
  const _HudInfoBar({required this.isGpsActive, required this.gpsUpdateHz});
  final bool isGpsActive;
  final double? gpsUpdateHz;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hzLabel = gpsUpdateHz != null
        ? 'GPS ${gpsUpdateHz!.toStringAsFixed(0)}Hz'
        : 'GPS --Hz';

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isGpsActive ? AppColors.primary : AppColors.error,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.satellite_alt,
                  color: AppColors.onSurfaceVariant, size: 14),
              const SizedBox(width: 4),
              Text(
                hzLabel,
                style: AppTextStyles.labelCaps(context).copyWith(fontSize: 10),
              ),
            ],
          ),
          Text(
            isGpsActive ? l10n.systemActive : l10n.systemInactive,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _GpsPermissionBanner extends StatelessWidget {
  const _GpsPermissionBanner({required this.gps});
  final GpsViewModel gps;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (IconData icon, String message, VoidCallback? onTap) =
        switch (gps.permissionStatus) {
      GpsPermissionStatus.denied => (
          Icons.location_off_outlined,
          l10n.locationDenied,
          gps.retryPermission,
        ),
      GpsPermissionStatus.permanentlyDenied => (
          Icons.settings_outlined,
          l10n.locationPermanentlyDenied,
          gps.openSettings,
        ),
      _ => (
          Icons.gps_off_outlined,
          l10n.locationServiceDisabled,
          null,
        ),
    };

    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        leftBorderColor: AppColors.error,
        child: Row(
          children: [
            Icon(icon, color: AppColors.error, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMd(context).copyWith(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
