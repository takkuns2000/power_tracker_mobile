import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:horsepower_tracker_mobile/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../app_theme.dart';
import '../../viewmodels/measurement_viewmodel.dart';
import '../widgets/glass_card.dart';

class MeasurementResultView extends StatelessWidget {
  const MeasurementResultView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.background,
      appBar: _ResultAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DateHeader(),
              const SizedBox(height: 8),
              _PeakHpSection(),
              const SizedBox(height: 24),
              _ChartCard(),
              const SizedBox(height: 16),
              _EnvInputRow(),
              const SizedBox(height: 16),
              _StatsBento(),
              const SizedBox(height: 16),
              _VehicleCard(),
              const SizedBox(height: 16),
              _ConditionsCard(),
              const SizedBox(height: 16),
              _MemoCard(),
              const SizedBox(height: 24),
              _ActionButtons(
                onComplete: () {
                  context.read<MeasurementViewModel>().reset();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultAppBar extends StatelessWidget implements PreferredSizeWidget {
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
                    const Icon(Icons.analytics_outlined,
                        color: AppColors.primary, size: 24),
                    const SizedBox(width: 8),
                    Text(l10n.measurementResult,
                        style: AppTextStyles.headlineLg(context)),
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

class _DateHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Text(l10n.measurementDateTime,
            style: AppTextStyles.labelCaps(context)
                .copyWith(fontSize: 10, letterSpacing: 2)),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '2023.10.24 ',
                style: AppTextStyles.bodyMd(context)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              TextSpan(
                text: '14:30',
                style: AppTextStyles.bodyMd(context)
                    .copyWith(color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PeakHpSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Text(l10n.peakPowerReached,
            style: AppTextStyles.labelCaps(context)
                .copyWith(color: AppColors.primary.withValues(alpha: 0.7))),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '582',
                style: GoogleFonts.sora(
                  fontSize: 64,
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                  color: AppColors.primary,
                  letterSpacing: -2.5,
                  shadows: [
                    Shadow(
                      color: AppColors.primary.withValues(alpha: 0.6),
                      blurRadius: 15,
                    ),
                    Shadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 30,
                    ),
                  ],
                ),
              ),
              TextSpan(
                text: ' ${l10n.unitHp}',
                style: GoogleFonts.sora(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(l10n.chartPowerHp,
                          style: AppTextStyles.labelCaps(context)),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(l10n.chartRpmX1000,
                          style: AppTextStyles.labelCaps(context)),
                    ],
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Text(l10n.pro,
                        style: AppTextStyles.labelCaps(context)
                            .copyWith(color: AppColors.primary, fontSize: 10)),
                    const SizedBox(width: 8),
                    Text(l10n.chartRpmAxis,
                        style: AppTextStyles.labelCaps(context).copyWith(
                            color: AppColors.onSurfaceVariant, fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: CustomPaint(
              painter: _HpChartPainter(),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 8),
          Text(l10n.chartTimeElapsed,
              style: AppTextStyles.labelCaps(context)
                  .copyWith(fontSize: 10)),
        ],
      ),
    );
  }
}

class _HpChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    for (final y in [size.height * 0.17, size.height * 0.5, size.height * 0.83]) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final rpmPaint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.4)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final rpmPath = Path();
    rpmPath.moveTo(0, size.height * 0.93);
    rpmPath.cubicTo(
      size.width * 0.2, size.height * 0.8,
      size.width * 0.4, size.height * 0.6,
      size.width * 0.6, size.height * 0.47,
    );
    rpmPath.cubicTo(
      size.width * 0.7, size.height * 0.43,
      size.width * 0.9, size.height * 0.43,
      size.width, size.height * 0.5,
    );
    canvas.drawPath(rpmPath, rpmPaint);

    final hpPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final hpPath = Path();
    hpPath.moveTo(0, size.height * 0.97);
    hpPath.cubicTo(
      size.width * 0.2, size.height * 0.83,
      size.width * 0.4, size.height * 0.53,
      size.width * 0.6, size.height * 0.27,
    );
    hpPath.cubicTo(
      size.width * 0.7, size.height * 0.13,
      size.width * 0.85, size.height * 0.13,
      size.width, size.height * 0.2,
    );
    canvas.drawPath(hpPath, hpPaint);

    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.13),
      5,
      Paint()..color = AppColors.primary,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EnvInputRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(child: _EnvInput(label: l10n.envInputTemp, unit: '°C')),
        const SizedBox(width: 16),
        Expanded(child: _EnvInput(label: l10n.envInputPressure, unit: 'hPa')),
      ],
    );
  }
}

class _EnvInput extends StatelessWidget {
  const _EnvInput({required this.label, required this.unit});
  final String label;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.labelCaps(context)
                  .copyWith(fontSize: 10)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextFormField(
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: AppTextStyles.statsMd(context)
                      .copyWith(fontSize: 24),
                  decoration: InputDecoration(
                    hintText: '--',
                    hintStyle: AppTextStyles.statsMd(context)
                        .copyWith(fontSize: 24, color: AppColors.onSurfaceVariant),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Text(unit,
                  style: AppTextStyles.labelCaps(context)
                      .copyWith(color: AppColors.onSurface.withValues(alpha: 0.5))),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsBento extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _StatCell(
            label: l10n.stat0To100,
            value: '3.42',
            unit: l10n.unitSeconds,
            valueColor: AppColors.primary),
        _StatCell(label: l10n.statHumidity, value: '42', unit: '%'),
        _ProStatCell(
            label: l10n.statMaxTorque,
            value: '720',
            unit: 'NM',
            valueColor: AppColors.secondary),
        _ProLogCell(),
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.value,
    required this.unit,
    this.valueColor,
  });
  final String label;
  final String value;
  final String unit;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTextStyles.labelCaps(context).copyWith(fontSize: 10)),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: GoogleFonts.sora(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: valueColor ?? AppColors.onSurface,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: AppTextStyles.labelCaps(context)
                      .copyWith(color: valueColor ?? AppColors.onSurface),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProStatCell extends StatelessWidget {
  const _ProStatCell({
    required this.label,
    required this.value,
    required this.unit,
    this.valueColor,
  });
  final String label;
  final String value;
  final String unit;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          GlassCard(
            borderRadius: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label,
                    style: AppTextStyles.labelCaps(context).copyWith(fontSize: 10)),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: value,
                        style: GoogleFonts.sora(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: valueColor ?? AppColors.onSurface,
                        ),
                      ),
                      TextSpan(
                        text: ' $unit',
                        style: AppTextStyles.labelCaps(context)
                            .copyWith(color: valueColor ?? AppColors.onSurface),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              color: AppColors.primary,
              child: Text(l10n.pro,
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProLogCell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          GlassCard(
            borderRadius: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.analytics_outlined,
                    color: AppColors.primary, size: 28),
                const SizedBox(height: 4),
                Text(l10n.showDetailLog,
                    style: AppTextStyles.labelCaps(context)
                        .copyWith(color: AppColors.primary, fontSize: 10)),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              color: AppColors.primary,
              child: Text(l10n.pro,
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.measuredVehicle,
                        style: AppTextStyles.labelCaps(context)
                            .copyWith(color: AppColors.primary)),
                    const SizedBox(height: 4),
                    Text('PORSCHE 911 GT3',
                        style: AppTextStyles.headlineLg(context)),
                    const SizedBox(height: 2),
                    Text('車両重量: 1,435 kg',
                        style: AppTextStyles.labelCaps(context)
                            .copyWith(color: AppColors.onSurfaceVariant)),
                  ],
                ),
                const Icon(Icons.expand_more, color: AppColors.primary),
              ],
            ),
          ),
          Divider(
              height: 1, color: AppColors.primary.withValues(alpha: 0.1)),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _VehicleDetail(
                          label: l10n.vehicleDetailDisplacement,
                          value: '3,996 cc'),
                    ),
                    Expanded(
                      child: _VehicleDetail(
                          label: l10n.vehicleDetailDrivetrain, value: 'RR'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  maxLines: 2,
                  style: AppTextStyles.bodyMd(context),
                  decoration: InputDecoration(
                    hintText: l10n.vehicleNoteHint,
                    contentPadding: const EdgeInsets.all(12),
                    filled: true,
                    fillColor: AppColors.surfaceContainer,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleDetail extends StatelessWidget {
  const _VehicleDetail({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.labelCaps(context).copyWith(fontSize: 10)),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.bodyMd(context)),
      ],
    );
  }
}

class _ConditionsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GlassCard(
      leftBorderColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline,
                  color: AppColors.primary, size: 16),
              const SizedBox(width: 8),
              Text(l10n.measurementConditions,
                  style: AppTextStyles.labelCaps(context)
                      .copyWith(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 0,
            runSpacing: 16,
            children: [
              _CondDetail(label: l10n.condRoadCondition, value: 'アスファルト (ドライ)'),
              _CondDetail(label: l10n.condAltitude, value: '142m (海抜)'),
              _CondDetail(label: l10n.condDriveLoss, value: 'SAE J1349'),
              _CondDetail(label: l10n.condTireSize, value: 'F: 32 PSI / R: 30 PSI'),
              _CondDetail(label: l10n.condMeasurementGear, value: '4速プル'),
            ],
          ),
        ],
      ),
    );
  }
}

class _CondDetail extends StatelessWidget {
  const _CondDetail({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.labelCaps(context).copyWith(fontSize: 10)),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.bodyMd(context)),
        ],
      ),
    );
  }
}

class _MemoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_note,
                  color: AppColors.onSurfaceVariant, size: 16),
              const SizedBox(width: 8),
              Text(l10n.measurementMemo,
                  style: AppTextStyles.labelCaps(context).copyWith(
                    letterSpacing: 1.5,
                  )),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            maxLines: 3,
            style: AppTextStyles.bodyMd(context),
            decoration: InputDecoration(
              hintText: l10n.measurementMemoHint,
              contentPadding: const EdgeInsets.all(16),
              filled: true,
              fillColor: AppColors.surfaceContainer,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.onComplete});
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.ios_share,
                      color: AppColors.onSurface, size: 20),
                  const SizedBox(width: 8),
                  Text(l10n.exportData,
                      style: AppTextStyles.labelCaps(context)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: onComplete,
            child: ClipPath(
              clipper: _SlantedClipper(),
              child: Container(
                height: 56,
                color: AppColors.primary,
                alignment: Alignment.center,
                child: Text(
                  l10n.complete,
                  style: GoogleFonts.sora(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SlantedClipper extends CustomClipper<Path> {
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
