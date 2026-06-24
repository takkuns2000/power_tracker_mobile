import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/vehicle.dart';
import 'glass_card.dart';

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

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.selectVehicle,
            style: AppTextStyles.labelCaps(context)
                .copyWith(color: AppColors.primary, fontSize: 15),
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField<Vehicle>(
            key: ValueKey(selectedId),
            initialValue: selectedVehicle,
            hint: Text(
              l10n.selectVehicleHint,
              style: AppTextStyles.statsMd(context).copyWith(fontSize: 15),
            ),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: false,
            ),
            dropdownColor: AppColors.surfaceContainer,
            style: AppTextStyles.statsMd(context).copyWith(fontSize: 18),
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
    );
  }
}
