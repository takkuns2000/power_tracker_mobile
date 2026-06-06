import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';
import '../widgets/glass_card.dart';

enum _Drivetrain { fwd, rwd, awd }

class VehicleSettingsView extends StatelessWidget {
  const VehicleSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.background,
      appBar: _VehicleSettingsAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeroSection(),
              const SizedBox(height: 24),
              _BasicInfoModule(),
              const SizedBox(height: 16),
              _DrivetrainModule(),
              const SizedBox(height: 16),
              _GearRatiosModule(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _SaveButton(onTap: () => Navigator.of(context).pop()),
    );
  }
}

class _VehicleSettingsAppBar extends StatelessWidget
    implements PreferredSizeWidget {
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
            color: AppColors.surface.withValues(alpha: 0.8),
            border: Border(
              bottom: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.1),
                blurRadius: 15,
              ),
            ],
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
                    Text('車両設定',
                        style: AppTextStyles.headlineLg(context)),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
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

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ガレージ登録',
            style: AppTextStyles.labelCaps(context)
                .copyWith(color: AppColors.secondary, letterSpacing: 1.5)),
        const SizedBox(height: 4),
        Text('車両設定', style: AppTextStyles.headlineLg(context)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.tertiary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.tertiary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.stars_outlined,
                  color: AppColors.tertiary, size: 14),
              const SizedBox(width: 8),
              Text('Pro Mode：複数車両登録可能',
                  style: AppTextStyles.labelCaps(context).copyWith(
                    color: AppColors.tertiary,
                    fontSize: 10,
                  )),
            ],
          ),
        ),
      ],
    );
  }
}

class _BasicInfoModule extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      leftBorderColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _UnderlineField(
            label: '車両ニックネーム',
            placeholder: '例：エイペックス・プレデター',
            suffix: const Icon(Icons.edit_outlined,
                color: AppColors.onSurfaceVariant, size: 18),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _UnderlineField(
                  label: '車両重量 (KG)',
                  placeholder: '1450',
                  keyboardType: TextInputType.number,
                  suffix: Text('KG',
                      style: AppTextStyles.statsMd(context)
                          .copyWith(color: AppColors.secondary.withValues(alpha: 0.6))),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _UnderlineField(
                  label: '排気量 (CC)',
                  placeholder: '1998',
                  keyboardType: TextInputType.number,
                  suffix: Text('CC',
                      style: AppTextStyles.statsMd(context)
                          .copyWith(color: AppColors.secondary.withValues(alpha: 0.6))),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _UnderlineField(
            label: '車両メモ',
            placeholder: 'チューニング内容や特記事項を入力...',
            maxLines: 2,
            suffix: const Icon(Icons.notes_outlined,
                color: AppColors.onSurfaceVariant, size: 18),
          ),
        ],
      ),
    );
  }
}

class _UnderlineField extends StatelessWidget {
  const _UnderlineField({
    required this.label,
    required this.placeholder,
    this.keyboardType = TextInputType.text,
    this.suffix,
    this.maxLines = 1,
  });
  final String label;
  final String placeholder;
  final TextInputType keyboardType;
  final Widget? suffix;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.labelCaps(context)
                .copyWith(color: AppColors.onSurfaceVariant.withValues(alpha: 0.7))),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextFormField(
                keyboardType: keyboardType,
                maxLines: maxLines,
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
                    borderSide: BorderSide(
                      color: AppColors.outline,
                    ),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
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
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      leftBorderColor: AppColors.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('駆動方式設定',
              style: AppTextStyles.labelCaps(context)
                  .copyWith(color: AppColors.onSurfaceVariant.withValues(alpha: 0.7))),
          const SizedBox(height: 16),
          _DrivetrainSelector(),
        ],
      ),
    );
  }
}

class _DrivetrainSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const options = [
      (_Drivetrain.fwd, 'FWD', Icons.directions_car_outlined),
      (_Drivetrain.rwd, 'RWD', Icons.local_shipping_outlined),
      (_Drivetrain.awd, 'AWD', Icons.directions_outlined),
    ];

    return Row(
      children: options.map((opt) {
        final (drivetrain, label, icon) = opt;
        final isActive = drivetrain == _Drivetrain.rwd;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
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
                  Icon(icon,
                      color: isActive
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
                      size: 24),
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
        );
      }).toList(),
    );
  }
}

class _GearRatiosModule extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      leftBorderColor: AppColors.tertiary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pro Mode：ギア比設定',
                  style: AppTextStyles.labelCaps(context)
                      .copyWith(color: AppColors.onSurfaceVariant.withValues(alpha: 0.7))),
              const Icon(Icons.settings_input_component_outlined,
                  color: AppColors.tertiary, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 24,
            mainAxisSpacing: 16,
            childAspectRatio: 2.8,
            children: [
              _GearInput(label: '1速', placeholder: '3.500'),
              _GearInput(label: '2速', placeholder: '2.000'),
              _GearInput(label: '3速', placeholder: '1.400'),
              _GearInput(label: '4速', placeholder: '1.100'),
              _GearInput(label: '5速', placeholder: '0.900'),
              _GearInput(label: '6速', placeholder: '0.750'),
              _GearInput(label: '7速', placeholder: '0.650'),
              _GearInput(label: '8速', placeholder: '0.550'),
            ],
          ),
          const SizedBox(height: 16),
          _GearInput(
            label: 'ファイナルギア比',
            placeholder: '4.100',
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
    this.labelColor,
    this.borderColor,
  });
  final String label;
  final String placeholder;
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
              color: labelColor ?? AppColors.onSurfaceVariant.withValues(alpha: 0.5),
            )),
        const SizedBox(height: 4),
        TextFormField(
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
  const _SaveButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: ClipPath(
          clipper: _SlantClipper(),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary,
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
                const Icon(Icons.save_outlined, color: Colors.white, size: 22),
                const SizedBox(width: 12),
                Text(
                  '車両を保存',
                  style: GoogleFonts.sora(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                    letterSpacing: -0.5,
                    color: Colors.white,
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

class _SlantClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final offset = size.width * 0.1;
    path.moveTo(offset, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width - offset, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
