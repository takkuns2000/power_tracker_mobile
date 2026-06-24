import 'dart:ui';
import 'package:flutter/material.dart';
import '../../app_theme.dart';

// Stitch glass-panel: border rgba(255,179,177,0.1), glow rgba(255,179,177,0.05)
const _kGlassBorder = Color(0x1AFFB3B1);
const _kGlassGlow   = Color(0x0DFFB3B1);

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 8.0,
    this.leftBorderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? leftBorderColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0x661D3557),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: _kGlassBorder, width: 1),
            boxShadow: const [
              BoxShadow(color: _kGlassGlow, blurRadius: 15),
            ],
          ),
          child: Stack(
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (leftBorderColor != null)
                      Container(width: 4, color: leftBorderColor),
                    Expanded(
                      child: Padding(padding: padding, child: child),
                    ),
                  ],
                ),
              ),
              // CSS inset 0 0 10px rgba(255,179,177,0.1) の近似
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _InsetGlowPainter(borderRadius: borderRadius),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InsetGlowPainter extends CustomPainter {
  const _InsetGlowPainter({required this.borderRadius});
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );
    canvas.save();
    canvas.clipRRect(rrect);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color(0x1AFFB3B1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GaugeSegmentRow extends StatelessWidget {
  const GaugeSegmentRow({
    super.key,
    required this.filledCount,
    this.totalCount = 10,
    this.activeIndex,
    this.color,
  });

  final int filledCount;
  final int totalCount;
  final int? activeIndex;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final fillColor = color ?? AppColors.primary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalCount, (i) {
        final isFilled = i < filledCount;
        final isActive = i == (activeIndex ?? filledCount - 1) && isFilled;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: _GaugeSegment(
            color: isFilled ? fillColor : AppColors.surface,
            opacity: isActive ? 1.0 : isFilled ? 0.8 : 0.25,
          ),
        );
      }),
    );
  }
}

class _GaugeSegment extends StatelessWidget {
  const _GaugeSegment({required this.color, required this.opacity});
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: ClipPath(
        clipper: _ParallelogramClipper(),
        child: Container(
          width: 22,
          height: 8,
          color: color,
        ),
      ),
    );
  }
}

class _ParallelogramClipper extends CustomClipper<Path> {
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
