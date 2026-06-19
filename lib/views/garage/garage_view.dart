import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../app_theme.dart';
import '../../models/vehicle.dart';
import '../../viewmodels/garage_viewmodel.dart';
import 'vehicle_settings_view.dart';
import '../widgets/glass_card.dart';

class GarageView extends StatelessWidget {
  const GarageView({super.key});

  void _openVehicleSettings(BuildContext context, {Vehicle? vehicle}) {
    debugPrint('[Garage] _openVehicleSettings: vehicle=${vehicle?.name}');
    final garageVm = context.read<GarageViewModel>();
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) {
              debugPrint('[Garage] MaterialPageRoute builder called');
              return ChangeNotifierProvider(
                create: (_) {
                  debugPrint('[Garage] VehicleSettingsViewModel create start');
                  final vm = garageVm.createSettingsViewModel(vehicle: vehicle);
                  debugPrint('[Garage] VehicleSettingsViewModel create done');
                  return vm;
                },
                child: const VehicleSettingsView(),
              );
            },
          ),
        )
        .then((_) {
      debugPrint('[Garage] returned from VehicleSettingsView');
      if (context.mounted) {
        context.read<GarageViewModel>().loadVehicles();
      }
    });
  }

  void _onAddTap(BuildContext context) {
    debugPrint('[Garage] _onAddTap called');
    final vm = context.read<GarageViewModel>();
    final isPro = vm.isPro;
    final vehicleCount = vm.vehicles.length;
    debugPrint('[Garage] isPro=$isPro, vehicleCount=$vehicleCount');
    if (!isPro && vehicleCount >= 1) {
      showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('Pro Mode が必要です',
              style: AppTextStyles.headlineLg(context)),
          content: const Text('複数車両の登録には Pro Mode へのアップグレードが必要です。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('閉じる'),
            ),
          ],
        ),
      );
      return;
    }
    _openVehicleSettings(context);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GarageViewModel>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.background,
      appBar: _GarageAppBar(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        onPressed: () => _onAddTap(context),
        child: const Icon(Icons.add_circle_outlined, size: 28),
      ),
      body: SafeArea(
        child: vm.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FleetHeader(count: vm.vehicles.length),
                    const SizedBox(height: 24),
                    ...vm.vehicles.map(
                      (v) => _VehicleCard(
                        vehicle: v,
                        onTap: () =>
                            _openVehicleSettings(context, vehicle: v),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _GarageAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
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
                    const SizedBox(width: 12),
                    Text(
                      'VEHICLES',
                      style: GoogleFonts.sora(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.settings_outlined,
                    color: AppColors.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FleetHeader extends StatelessWidget {
  const _FleetHeader({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Fleet Overview',
            style: AppTextStyles.labelCaps(context)
                .copyWith(color: AppColors.primary, letterSpacing: 1.5)),
        Text('ガレージ', style: AppTextStyles.headlineLg(context)),
      ],
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({required this.vehicle, required this.onTap});
  final Vehicle vehicle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    vehicle.name,
                    style: AppTextStyles.headlineLg(context),
                  ),
                  const Icon(Icons.chevron_right,
                      color: AppColors.onSurfaceVariant),
                ],
              ),
              Divider(
                height: 24,
                color: AppColors.outline.withValues(alpha: 0.2),
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Weight',
                            style: AppTextStyles.labelCaps(context)
                                .copyWith(fontSize: 10)),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: vehicle.weightKg.toStringAsFixed(0),
                                style: AppTextStyles.statsMd(context),
                              ),
                              TextSpan(
                                text: ' kg',
                                style: AppTextStyles.statsMd(context).copyWith(
                                  fontSize: 12,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Power',
                            style: AppTextStyles.labelCaps(context)
                                .copyWith(fontSize: 10)),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '--',
                                style: AppTextStyles.statsMd(context)
                                    .copyWith(color: AppColors.primary),
                              ),
                              TextSpan(
                                text: ' hp',
                                style: AppTextStyles.statsMd(context).copyWith(
                                  fontSize: 12,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.outline.withValues(alpha: 0.1),
                  ),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.directions_car,
                        color:
                            AppColors.onSurfaceVariant.withValues(alpha: 0.2),
                        size: 48),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
