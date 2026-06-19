import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/vehicle.dart';

/// 計測準備画面・LIVE画面で共用する車両選択カード。
class VehicleDropdownCard extends StatelessWidget {
  const VehicleDropdownCard({
    super.key,
    required this.vehicles,
    required this.selectedId,
    required this.onChanged,
  });

  final List<Vehicle> vehicles;
  final String? selectedId;
  final void Function(Vehicle?) onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selectedVehicle = selectedId != null
        ? vehicles.where((v) => v.id?.toString() == selectedId).firstOrNull
        : null;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0x661D3557),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x1AFFB3B1), width: 1),
      ),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.selectVehicle,
                  style: AppTextStyles.labelCaps(context)
                      .copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Vehicle>(
                  key: ValueKey(selectedId),
                  initialValue: selectedVehicle,
                  hint: Text(
                    l10n.selectVehicleHint,
                    style: AppTextStyles.statsMd(context),
                  ),
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
                  items: vehicles
                      .map(
                        (v) => DropdownMenuItem<Vehicle>(
                          value: v,
                          child: Text(v.name),
                        ),
                      )
                      .toList(),
                  onChanged: onChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
