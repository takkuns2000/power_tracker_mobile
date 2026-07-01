import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../l10n/app_localizations.dart';

enum ProLockMode { upgrade, notMeasured }

class ProLockWrapper extends StatelessWidget {
  const ProLockWrapper({
    super.key,
    required this.isPro,
    required this.child,
    this.mode = ProLockMode.upgrade,
  });
  final bool isPro;
  final Widget child;
  final ProLockMode mode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (isPro) return child;

    final icon = mode == ProLockMode.notMeasured
        ? Icons.info_outline
        : Icons.lock_outline;
    final label = mode == ProLockMode.notMeasured
        ? l10n.proNotMeasuredLabel
        : l10n.proModeLimited;
    final sub = mode == ProLockMode.notMeasured
        ? l10n.proNotMeasuredSub
        : l10n.upgradeToUnlock;

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
              border: mode == ProLockMode.notMeasured
                  ? null
                  : Border.all(
                      color: AppColors.tertiary.withValues(alpha: 0.4),
                    ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: AppColors.tertiary, size: 24),
                const SizedBox(height: 8),
                Text(label,
                    style: AppTextStyles.labelCaps(context).copyWith(
                      color: AppColors.tertiary,
                      fontSize: 11,
                    )),
                const SizedBox(height: 4),
                Text(sub,
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
