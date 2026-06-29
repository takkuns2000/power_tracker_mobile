import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:horsepower_tracker_mobile/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../app_theme.dart';
import '../../models/drivetrain.dart';
import '../../viewmodels/vehicle_settings_viewmodel.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/glass_card.dart';
import '../widgets/pro_lock_wrapper.dart';

class VehicleSettingsView extends StatelessWidget {
  const VehicleSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VehicleSettingsViewModel>();
    final isPro = vm.isPro;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.background,
      appBar: _VehicleSettingsAppBar(
        onClose: () async {
          if (vm.hasPendingChanges) {
            final discard = await showDialog<bool>(
              context: context,
              barrierColor: Colors.black.withValues(alpha: 0.6),
              builder: (ctx) => ConfirmDialog(
                icon: Icons.warning_amber_outlined,
                title: l10n.unsavedChangesTitle,
                content: Text(l10n.unsavedChangesMessage),
                actions: [
                  ConfirmDialogButton(
                    label: l10n.cancel,
                    onPressed: () => Navigator.of(ctx).pop(false),
                  ),
                ],
                okLabel: l10n.discardChanges,
                onOk: () => Navigator.of(ctx).pop(true),
              ),
            );
            if (!context.mounted) return;
            if (discard != true) return;
          }
          Navigator.of(context).pop();
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BasicInfoModule(vm: vm),
                    const SizedBox(height: 16),
                    _DrivetrainModule(vm: vm),
                    const SizedBox(height: 16),
                    _PhotoModule(vm: vm),
                    const SizedBox(height: 16),
                    ProLockWrapper(
                      isPro: isPro,
                      child: _TireSizeModule(vm: vm),
                    ),
                    const SizedBox(height: 16),
                    ProLockWrapper(
                      isPro: isPro,
                      child: _GearRatiosModule(vm: vm),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            _SaveButton(
              isSaving: vm.isSaving,
              onTap: () async {
                final success = await vm.save();
                if (!context.mounted) return;
                if (success) {
                  Navigator.of(context).pop();
                } else {
                  showConfirmDialog<void>(
                    context: context,
                    icon: Icons.error_outline,
                    title: l10n.inputError,
                    content: Text(l10n.requiredFieldsError),
                    okLabel: l10n.close,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleSettingsAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _VehicleSettingsAppBar({required this.onClose});
  final Future<void> Function() onClose;

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
                    const Icon(Icons.settings_outlined,
                        color: AppColors.primary, size: 24),
                    const SizedBox(width: 12),
                    Text(l10n.vehicleSettings,
                        style: GoogleFonts.sora(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        )),
                  ],
                ),
                GestureDetector(
                  onTap: onClose,
                  child: const Icon(Icons.close,
                      color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _BasicInfoModule extends StatelessWidget {
  const _BasicInfoModule({required this.vm});
  final VehicleSettingsViewModel vm;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GlassCard(
      leftBorderColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _UnderlineField(
            label: l10n.labelVehicleNickname,
            isRequired: true,
            placeholder: '',
            controller: vm.nameController,
          ),
          const SizedBox(height: 24),
          _UnderlineField(
            label: l10n.labelModelCode,
            placeholder: l10n.placeholderModelCode,
            controller: vm.modelCodeController,
            keyboardType: TextInputType.visiblePassword,
            inputFormatters: [_UpperCaseAlphanumericFormatter()],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _UnderlineField(
                  label: l10n.labelVehicleWeight,
                  isRequired: true,
                  placeholder: '1450',
                  controller: vm.weightController,
                  keyboardType: TextInputType.number,
                  suffix: Text(l10n.unitKg,
                      style: AppTextStyles.statsMd(context).copyWith(
                          color: AppColors.secondary.withValues(alpha: 0.6))),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _UnderlineField(
                  label: l10n.labelDisplacement,
                  placeholder: '1998',
                  controller: vm.displacementController,
                  keyboardType: TextInputType.number,
                  suffix: Text(l10n.unitCc,
                      style: AppTextStyles.statsMd(context).copyWith(
                          color: AppColors.secondary.withValues(alpha: 0.6))),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _UnderlineField(
            label: l10n.labelVehicleMemo,
            placeholder: '',
            controller: vm.memoController,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

class _UpperCaseAlphanumericFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final filtered =
        newValue.text.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    final offset = filtered.length.clamp(0, filtered.length);
    return TextEditingValue(
      text: filtered,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}

class _UnderlineField extends StatelessWidget {
  const _UnderlineField({
    required this.label,
    required this.placeholder,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.suffix,
    this.maxLines = 1,
    this.isRequired = false,
    this.inputFormatters,
  });
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final Widget? suffix;
  final int maxLines;
  final bool isRequired;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final labelStyle = AppTextStyles.labelCaps(context)
        .copyWith(color: AppColors.onSurfaceVariant.withValues(alpha: 0.7));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isRequired)
          RichText(
            text: TextSpan(children: [
              TextSpan(text: label, style: labelStyle),
              TextSpan(
                  text: ' *',
                  style: labelStyle.copyWith(color: AppColors.error)),
            ]),
          )
        else
          Text(label, style: labelStyle),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                maxLines: maxLines,
                inputFormatters: inputFormatters,
                style: AppTextStyles.statsMd(context),
                decoration: InputDecoration(
                  hintText: placeholder,
                  hintStyle: AppTextStyles.statsMd(context).copyWith(
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.3),
                  ),
                  border: InputBorder.none,
                  filled: false,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 8),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.outline),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
            ),
            if (suffix != null) ...[
              const SizedBox(width: 8),
              suffix!,
            ],
          ],
        ),
      ],
    );
  }
}

class _DrivetrainModule extends StatelessWidget {
  const _DrivetrainModule({required this.vm});
  final VehicleSettingsViewModel vm;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GlassCard(
      leftBorderColor: AppColors.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: AppTextStyles.labelCaps(context)
                  .copyWith(color: AppColors.onSurfaceVariant.withValues(alpha: 0.7)),
              children: [
                TextSpan(text: l10n.labelDrivetrain),
                const TextSpan(text: ' *', style: TextStyle(color: AppColors.error)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _DrivetrainSelector(vm: vm),
        ],
      ),
    );
  }
}

class _DrivetrainSelector extends StatelessWidget {
  const _DrivetrainSelector({required this.vm});
  final VehicleSettingsViewModel vm;

  @override
  Widget build(BuildContext context) {
    const options = [
      (Drivetrain.fwd, 'FWD'),
      (Drivetrain.rwd, 'RWD'),
      (Drivetrain.awd, 'AWD'),
    ];

    return Row(
      children: options.map((opt) {
        final (drivetrain, label) = opt;
        final isActive = vm.drivetrain == drivetrain;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => vm.selectDrivetrain(drivetrain),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isActive
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.1),
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 10,
                          )
                        ]
                      : null,
                ),
                child: Column(
                  children: [
                    _DrivetrainDiagram(drivetrain: drivetrain, isActive: isActive),
                    const SizedBox(height: 8),
                    Text(label,
                        style: AppTextStyles.labelCaps(context).copyWith(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.onSurface,
                        )),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DrivetrainDiagram extends StatelessWidget {
  const _DrivetrainDiagram({required this.drivetrain, required this.isActive});
  final Drivetrain drivetrain;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(36, 52),
      painter: _DrivetrainPainter(drivetrain: drivetrain, isActive: isActive),
    );
  }
}

class _DrivetrainPainter extends CustomPainter {
  const _DrivetrainPainter({required this.drivetrain, required this.isActive});
  final Drivetrain drivetrain;
  final bool isActive;

  @override
  void paint(Canvas canvas, Size size) {
    final activeColor = isActive ? AppColors.primary : AppColors.onSurface;
    final dimColor = AppColors.onSurfaceVariant.withValues(alpha: 0.25);
    final bodyColor = AppColors.onSurface.withValues(alpha: 0.15);
    final radius = const Radius.circular(3);
    final wheelRadius = const Radius.circular(2);

    final frontPowered = drivetrain == Drivetrain.fwd || drivetrain == Drivetrain.awd;
    final rearPowered = drivetrain == Drivetrain.rwd || drivetrain == Drivetrain.awd;

    // 車体
    canvas.drawRRect(
      RRect.fromLTRBR(10, 10, 26, 42, radius),
      Paint()..color = bodyColor,
    );

    // 前輪（上）
    final frontPaint = Paint()..color = frontPowered ? activeColor : dimColor;
    canvas.drawRRect(RRect.fromLTRBR(0, 4, 8, 18, wheelRadius), frontPaint);
    canvas.drawRRect(RRect.fromLTRBR(28, 4, 36, 18, wheelRadius), frontPaint);

    // 後輪（下）
    final rearPaint = Paint()..color = rearPowered ? activeColor : dimColor;
    canvas.drawRRect(RRect.fromLTRBR(0, 34, 8, 48, wheelRadius), rearPaint);
    canvas.drawRRect(RRect.fromLTRBR(28, 34, 36, 48, wheelRadius), rearPaint);
  }

  @override
  bool shouldRepaint(_DrivetrainPainter old) =>
      drivetrain != old.drivetrain || isActive != old.isActive;
}

class _PhotoModule extends StatelessWidget {
  const _PhotoModule({required this.vm});
  final VehicleSettingsViewModel vm;

  @override
  Widget build(BuildContext context) {
    final imagePath = vm.imagePath;
    return GlassCard(
      leftBorderColor: AppColors.onSurfaceVariant,
      child: GestureDetector(
        onTap: () async {
          await vm.pickImage();
          if (!context.mounted) return;
          if (vm.imagePickError != null) {
            showConfirmDialog<void>(
              context: context,
              icon: Icons.error_outline,
              title: 'エラー',
              content: const Text('写真の読み込みに失敗しました。'),
              okLabel: '閉じる',
            );
            vm.clearImagePickError();
          }
        },
        child: imagePath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(imagePath),
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                  errorBuilder: (_, _, _) => AspectRatio(
                    aspectRatio: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.outline.withValues(alpha: 0.3),
                          style: BorderStyle.solid,
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.add_photo_alternate_outlined,
                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                        size: 36,
                      ),
                    ),
                  ),
                ),
              )
            : AspectRatio(
                aspectRatio: 3,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.outline.withValues(alpha: 0.3),
                      style: BorderStyle.solid,
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                        size: 36,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'PHOTO',
                      style: AppTextStyles.labelCaps(context).copyWith(
                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
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

// ProLockWrapper は lib/views/widgets/pro_lock_wrapper.dart に移動済み

class _TireSizeModule extends StatelessWidget {
  const _TireSizeModule({required this.vm});
  final VehicleSettingsViewModel vm;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GlassCard(
      leftBorderColor: AppColors.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.proModeTireSize,
                  style: AppTextStyles.labelCaps(context).copyWith(
                      color:
                          AppColors.onSurfaceVariant.withValues(alpha: 0.7))),
              const Icon(Icons.tire_repair_outlined,
                  color: AppColors.secondary, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _UnderlineField(
                  label: l10n.labelTireWidth,
                  placeholder: '225',
                  controller: vm.tireWidthController,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _UnderlineField(
                  label: l10n.labelTireAspect,
                  placeholder: '45',
                  controller: vm.tireAspectController,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _UnderlineField(
                  label: l10n.labelTireRim,
                  placeholder: '17',
                  controller: vm.tireRimController,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GearRatiosModule extends StatelessWidget {
  const _GearRatiosModule({required this.vm});
  final VehicleSettingsViewModel vm;

  static const _gearPlaceholders = [
    '3.500', '2.000', '1.400', '1.100', '0.900', '0.750', '0.650',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final gearLabels = [
      l10n.labelGear1, l10n.labelGear2, l10n.labelGear3, l10n.labelGear4,
      l10n.labelGear5, l10n.labelGear6, l10n.labelGear7,
    ];
    return GlassCard(
      leftBorderColor: AppColors.tertiary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.proModeGearRatio,
                  style: AppTextStyles.labelCaps(context).copyWith(
                      color:
                          AppColors.onSurfaceVariant.withValues(alpha: 0.7))),
              const Icon(Icons.settings_input_component_outlined,
                  color: AppColors.tertiary, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              for (var row = 0; row < 4; row++) ...[
                if (row > 0) const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _GearInput(
                        label: gearLabels[row * 2],
                        placeholder: _gearPlaceholders[row * 2],
                        controller: vm.gearControllers[row * 2],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: row * 2 + 1 < 7
                          ? _GearInput(
                              label: gearLabels[row * 2 + 1],
                              placeholder: _gearPlaceholders[row * 2 + 1],
                              controller: vm.gearControllers[row * 2 + 1],
                            )
                          : const SizedBox(),
                    ),
                  ],
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          _GearInput(
            label: l10n.labelFinalGear,
            placeholder: '4.100',
            controller: vm.finalGearController,
            labelColor: AppColors.secondary,
            borderColor: AppColors.secondary.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}

class _GearInput extends StatelessWidget {
  const _GearInput({
    required this.label,
    required this.placeholder,
    required this.controller,
    this.labelColor,
    this.borderColor,
  });
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final Color? labelColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.labelCaps(context).copyWith(
              fontSize: 10,
              color: labelColor ??
                  AppColors.onSurfaceVariant.withValues(alpha: 0.5),
            )),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          style: GoogleFonts.jetBrainsMono(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: labelColor ?? AppColors.onSurface,
          ),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: GoogleFonts.jetBrainsMono(
              fontSize: 16,
              color: (labelColor ?? AppColors.onSurface)
                  .withValues(alpha: 0.2),
            ),
            border: InputBorder.none,
            filled: false,
            contentPadding: const EdgeInsets.symmetric(vertical: 4),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: borderColor ?? AppColors.outline,
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: borderColor ?? AppColors.tertiary,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.onTap, required this.isSaving});
  final VoidCallback onTap;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: GestureDetector(
        onTap: isSaving ? null : onTap,
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: isSaving
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.primary,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSaving)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              else
                const Icon(Icons.save_outlined,
                    color: Colors.white, size: 22),
              const SizedBox(width: 12),
              Text(
                l10n.vehicleSave,
                style: GoogleFonts.sora(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
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
