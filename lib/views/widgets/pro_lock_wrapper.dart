import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../l10n/app_localizations.dart';

class ProLockWrapper extends StatelessWidget {
  const ProLockWrapper({super.key, required this.isPro, required this.child});
  final bool isPro;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (isPro) return child;
    return Stack(
      fit: StackFit.passthrough,
      children: [
        IgnorePointer(
          child: Opacity(opacity: 0.35, child: child),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.tertiary.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline,
                    color: AppColors.tertiary, size: 24),
                const SizedBox(height: 8),
                Text(l10n.proModeLimited,
                    style: AppTextStyles.labelCaps(context).copyWith(
                      color: AppColors.tertiary,
                      fontSize: 11,
                    )),
                const SizedBox(height: 4),
                Text(l10n.upgradeToUnlock,
                    style: AppTextStyles.labelCaps(context).copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 10,
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
