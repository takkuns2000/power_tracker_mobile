import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';

const _kGlassBorder = Color(0x1AFFB3B1);
const _kGlassGlow   = Color(0x0DFFB3B1);

/// 汎用確認ダイアログ。
///
/// ```dart
/// showConfirmDialog(
///   context: context,
///   icon: Icons.warning_amber_outlined,
///   title: '計測を中断しますか？',
///   content: Text('現在の計測データは失われます。'),
///   actions: [
///     ConfirmDialogButton(label: 'キャンセル', onPressed: () => Navigator.pop(context)),
///   ],
/// );
/// ```
Future<T?> showConfirmDialog<T>({
  required BuildContext context,
  IconData? icon,
  String? title,
  required Widget content,
  List<ConfirmDialogButton>? actions,
  String okLabel = 'OK',
  VoidCallback? onOk,
}) {
  return showDialog<T>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    builder: (ctx) => ConfirmDialog(
      icon: icon,
      title: title,
      content: content,
      actions: actions,
      okLabel: okLabel,
      onOk: onOk ?? () => Navigator.of(ctx).pop(),
    ),
  );
}

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    this.icon,
    this.title,
    required this.content,
    this.actions,
    this.okLabel = 'OK',
    this.onOk,
  });

  final IconData? icon;
  final String? title;
  final Widget content;
  final List<ConfirmDialogButton>? actions;
  final String okLabel;
  final VoidCallback? onOk;

  @override
  Widget build(BuildContext context) {
    final effectiveOnOk = onOk ?? () => Navigator.of(context).pop();

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0x661D3557),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _kGlassBorder, width: 1),
              boxShadow: const [
                BoxShadow(color: _kGlassGlow, blurRadius: 15),
              ],
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DialogHeader(icon: icon, title: title),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: DefaultTextStyle(
                        style: AppTextStyles.bodyMd(context)
                            .copyWith(color: AppColors.onSurfaceVariant),
                        child: content,
                      ),
                    ),
                    Container(height: 1, color: _kGlassBorder),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (actions != null)
                            ...actions!.map((b) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: b,
                                )),
                          ConfirmDialogButton(
                            label: okLabel,
                            isPrimary: true,
                            onPressed: effectiveOnOk,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(painter: _InsetGlowPainter()),
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

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({this.icon, this.title});
  final IconData? icon;
  final String? title;

  @override
  Widget build(BuildContext context) {
    if (icon == null && title == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(width: 10),
          ],
          if (title != null)
            Expanded(
              child: Text(
                title!,
                style: GoogleFonts.sora(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ConfirmDialogButton extends StatelessWidget {
  const ConfirmDialogButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.4),
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _InsetGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(8),
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
