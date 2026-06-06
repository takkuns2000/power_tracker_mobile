import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';
import 'vehicle_settings_view.dart';
import '../widgets/glass_card.dart';

const _mockVehicles = [
  {
    'name': 'Supra MK4',
    'weight': '1,510',
    'power': '320',
    'status': 'active',
  },
  {
    'name': 'M3 Competition',
    'weight': '1,730',
    'power': '510',
    'status': 'stable',
  },
];

class GarageView extends StatelessWidget {
  const GarageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.background,
      appBar: _GarageAppBar(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const VehicleSettingsView()),
          );
        },
        child: const Icon(Icons.add_circle_outlined, size: 28),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FleetHeader(count: _mockVehicles.length),
              const SizedBox(height: 24),
              ..._mockVehicles.map((v) => _VehicleCard(vehicle: v)),
              const SizedBox(height: 16),
              _AddVehicleCard(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const VehicleSettingsView()),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fleet Overview',
                style: AppTextStyles.labelCaps(context)
                    .copyWith(color: AppColors.primary, letterSpacing: 1.5)),
            Text('ガレージ', style: AppTextStyles.headlineLg(context)),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              count.toString().padLeft(2, '0'),
              style: AppTextStyles.statsMd(context)
                  .copyWith(color: AppColors.secondary),
            ),
            Text('Registered',
                style: AppTextStyles.labelCaps(context)
                    .copyWith(fontSize: 10)),
          ],
        ),
      ],
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({required this.vehicle});
  final Map<String, dynamic> vehicle;

  @override
  Widget build(BuildContext context) {
    final isActive = vehicle['status'] == 'active';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const VehicleSettingsView()),
        ),
        child: GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.primary
                                  : AppColors.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isActive ? 'Active' : 'Stable',
                            style: AppTextStyles.labelCaps(context).copyWith(
                              fontSize: 10,
                              color: isActive
                                  ? AppColors.primary
                                  : AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vehicle['name'] as String,
                        style: AppTextStyles.headlineLg(context),
                      ),
                    ],
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
                                text: '${vehicle['weight']}',
                                style: AppTextStyles.statsMd(context),
                              ),
                              TextSpan(
                                text: ' kg',
                                style: AppTextStyles.statsMd(context)
                                    .copyWith(
                                        fontSize: 12,
                                        color: AppColors.onSurfaceVariant),
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
                                text: '${vehicle['power']}',
                                style: AppTextStyles.statsMd(context)
                                    .copyWith(color: AppColors.primary),
                              ),
                              TextSpan(
                                text: ' hp',
                                style: AppTextStyles.statsMd(context)
                                    .copyWith(
                                        fontSize: 12,
                                        color: AppColors.onSurfaceVariant),
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
                        color: AppColors.onSurfaceVariant
                            .withValues(alpha: 0.2),
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

class _AddVehicleCard extends StatelessWidget {
  const _AddVehicleCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.outline.withValues(alpha: 0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.4),
                ),
              ),
              child: const Icon(Icons.add, color: AppColors.primary, size: 24),
            ),
            const SizedBox(height: 16),
            Text('車両を追加',
                style: AppTextStyles.statsMd(context)
                    .copyWith(fontSize: 17)),
            const SizedBox(height: 4),
            Text('Register New Asset',
                style: AppTextStyles.labelCaps(context).copyWith(
                  fontSize: 10,
                  color: AppColors.onSurfaceVariant,
                )),
          ],
        ),
      ),
    );
  }
}
