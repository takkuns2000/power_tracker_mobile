import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../app_theme.dart';
import '../../viewmodels/measurement_viewmodel.dart';
import 'measurement_result_view.dart';
import '../widgets/glass_card.dart';

class MeasuringView extends StatelessWidget {
  const MeasuringView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MeasurementViewModel>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.background,
      appBar: _MeasuringAppBar(),
      body: Stack(
        children: [
          _SpeedStreaks(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 140),
              child: Column(
                children: [
                  _StatusCard(startTime: vm.startTime),
                  const SizedBox(height: 16),
                  _HpCard(),
                  const SizedBox(height: 16),
                  _TorqueCard(),
                ],
              ),
            ),
          ),
          _StopButton(
            onTap: () {
              context.read<MeasurementViewModel>().stopMeasurement();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (_) => const MeasurementResultView()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MeasuringAppBar extends StatelessWidget implements PreferredSizeWidget {
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
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '計測中',
                  style: GoogleFonts.sora(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 3,
                    color: AppColors.primary,
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

class _SpeedStreaks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(painter: _StreakPainter()),
      ),
    );
  }
}

class _StreakPainter extends CustomPainter {
  const _StreakPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          AppColors.primary.withValues(alpha: 0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, 2, size.height))
      ..strokeWidth = 1;

    for (final xFraction in [0.15, 0.25, 0.45, 0.75, 0.85]) {
      final x = size.width * xFraction;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.startTime});
  final DateTime? startTime;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      leftBorderColor: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ステータス',
                  style: AppTextStyles.labelCaps(context)
                      .copyWith(fontSize: 10)),
              const SizedBox(height: 4),
              Text(
                'リアルタイム追跡中',
                style: GoogleFonts.sora(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('経過時間',
                  style: AppTextStyles.labelCaps(context)
                      .copyWith(fontSize: 10)),
              const SizedBox(height: 4),
              // TODO: 実装時は ViewModel の Stream<Duration> に置き換える
              StreamBuilder<int>(
                stream: Stream.periodic(
                  const Duration(milliseconds: 100),
                  (tick) => tick,
                ),
                builder: (context, _) {
                  if (startTime == null) {
                    return Text('00:00.0',
                        style: AppTextStyles.statsMd(context));
                  }
                  final elapsed = DateTime.now().difference(startTime!);
                  final minutes = elapsed.inMinutes.remainder(60)
                      .toString()
                      .padLeft(2, '0');
                  final seconds = elapsed.inSeconds.remainder(60)
                      .toString()
                      .padLeft(2, '0');
                  final tenths =
                      (elapsed.inMilliseconds ~/ 100).remainder(10);
                  return Text(
                    '$minutes:$seconds.$tenths',
                    style: AppTextStyles.statsMd(context),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HpCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.primary.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('推定馬力',
                  style: AppTextStyles.labelCaps(context)
                      .copyWith(color: AppColors.onSurfaceVariant)),
              Text('ピーク: -- PS',
                  style: AppTextStyles.statsMd(context)
                      .copyWith(color: AppColors.primary, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '--',
                style: GoogleFonts.sora(
                  fontSize: 72,
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text('PS',
                  style: GoogleFonts.sora(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                    color: AppColors.onSurfaceVariant,
                  )),
            ],
          ),
          const SizedBox(height: 16),
          _MeasurementGauge(fillRatio: 0.4),
        ],
      ),
    );
  }
}

class _TorqueCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.primary.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('推定トルク',
                      style: AppTextStyles.labelCaps(context)
                          .copyWith(color: AppColors.onSurfaceVariant)),
                  Text('ピーク: -- kgm',
                      style: AppTextStyles.statsMd(context)
                          .copyWith(color: AppColors.primary, fontSize: 14)),
                ],
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Row(
                  children: [
                    const Icon(Icons.workspace_premium,
                        color: AppColors.primary, size: 14),
                    const SizedBox(width: 4),
                    Text('PRO機能',
                        style: AppTextStyles.labelCaps(context)
                            .copyWith(color: AppColors.primary, fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '--',
                style: GoogleFonts.sora(
                  fontSize: 72,
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text('kgm',
                  style: GoogleFonts.sora(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                    color: AppColors.onSurfaceVariant,
                  )),
            ],
          ),
          const SizedBox(height: 16),
          _MeasurementGauge(fillRatio: 0.25),
        ],
      ),
    );
  }
}

class _MeasurementGauge extends StatelessWidget {
  const _MeasurementGauge({required this.fillRatio});
  final double fillRatio;

  @override
  Widget build(BuildContext context) {
    const totalSegments = 30;
    final filledCount = (totalSegments * fillRatio).round();
    final dangerThreshold = (totalSegments * 0.85).round();

    return Row(
      children: List.generate(totalSegments, (i) {
        Color color;
        if (i < filledCount) {
          color = i >= dangerThreshold
              ? const Color(0xFFFF535B)
              : AppColors.primary;
        } else {
          color = AppColors.surface;
        }
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.skewX(-0.26),
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  boxShadow: i < filledCount
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.5),
                            blurRadius: 4,
                          )
                        ]
                      : null,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _StopButton extends StatelessWidget {
  const _StopButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              AppColors.background,
              AppColors.background.withValues(alpha: 0.8),
              Colors.transparent,
            ],
          ),
        ),
        child: GestureDetector(
          onTap: onTap,
          child: ClipPath(
            clipper: _SlantClipper(),
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.9),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 30,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.stop_circle_outlined,
                          color: Colors.white, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        '計測を停止',
                        style: GoogleFonts.sora(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '結果詳細を確認する',
                    style: AppTextStyles.labelCaps(context)
                        .copyWith(color: Colors.white70, fontSize: 10),
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

class _SlantClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final offset = size.width * 0.05;
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
