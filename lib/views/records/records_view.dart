import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:horsepower_tracker_mobile/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../app_theme.dart';
import '../../models/measurement.dart';
import '../../viewmodels/records_viewmodel.dart';
import '../measurement/measurement_result_view.dart';
import '../widgets/glass_card.dart';

class RecordsView extends StatelessWidget {
  const RecordsView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RecordsViewModel>();
    final l10n = AppLocalizations.of(context)!;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (vm.loadError != null) {
        final error = vm.loadError!;
        vm.clearLoadError();
        showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: Text(l10n.inputError,
                style: AppTextStyles.headlineLg(context)
                    .copyWith(color: AppColors.error)),
            content: Text(error),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.close),
              ),
            ],
          ),
        );
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.background,
      appBar: _HistoryAppBar(onRefresh: vm.load),
      body: SafeArea(
        child: vm.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary))
            : vm.records.isEmpty
                ? _EmptyState()
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SummarySection(records: vm.records),
                        const SizedBox(height: 24),
                        ..._buildRecordList(context, vm.records),
                      ],
                    ),
                  ),
      ),
    );
  }

  List<Widget> _buildRecordList(
      BuildContext context, List<Measurement> records) {
    final widgets = <Widget>[];
    String? lastMonth;

    for (final record in records) {
      final month =
          '${record.measuredAt.year}.${record.measuredAt.month.toString().padLeft(2, '0')}';
      if (month != lastMonth) {
        widgets.add(_MonthSeparator(label: month));
        lastMonth = month;
      }
      widgets.add(_RecordCard(
        measurement: record,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MeasurementResultView(measurement: record),
          ),
        ),
      ));
    }
    return widgets;
  }
}

class _HistoryAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _HistoryAppBar({required this.onRefresh});
  final VoidCallback onRefresh;

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
                    const Icon(Icons.show_chart,
                        color: AppColors.primary, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      l10n.navHistory,
                      style: GoogleFonts.sora(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: onRefresh,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.refresh,
                        color: AppColors.onSurfaceVariant, size: 20),
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

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.records});
  final List<Measurement> records;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final peakHp = records.isEmpty
        ? 0.0
        : records.map((r) => r.maxHp).reduce((a, b) => a > b ? a : b);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.lifetimeRuns,
                style: AppTextStyles.labelCaps(context)
                    .copyWith(color: AppColors.secondary)),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${records.length} ',
                    style: GoogleFonts.sora(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  TextSpan(
                    text: l10n.records,
                    style: AppTextStyles.bodyMd(context)
                        .copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(l10n.peakStats,
                style: AppTextStyles.labelCaps(context)
                    .copyWith(color: AppColors.secondary)),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${peakHp.toStringAsFixed(1)} ',
                    style: GoogleFonts.sora(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  TextSpan(
                    text: l10n.maxHp,
                    style: AppTextStyles.bodyMd(context)
                        .copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.measurement, required this.onTap});
  final Measurement measurement;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final m = measurement;
    final date =
        '${m.measuredAt.year}.${m.measuredAt.month.toString().padLeft(2, '0')}.${m.measuredAt.day.toString().padLeft(2, '0')} '
        '${m.measuredAt.hour.toString().padLeft(2, '0')}:${m.measuredAt.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        color: AppColors.secondary.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      m.vehicleName,
                      style: GoogleFonts.sora(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    if (m.memo != null && m.memo!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        m.memo!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelCaps(context).copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 18),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: m.maxHp.toStringAsFixed(1),
                        style: GoogleFonts.sora(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      TextSpan(
                        text: ' HP',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
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

class _MonthSeparator extends StatelessWidget {
  const _MonthSeparator({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.labelCaps(context).copyWith(
              color: AppColors.secondary.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.analytics_outlined,
              color: AppColors.primary, size: 48),
          const SizedBox(height: 16),
          Text(
            l10n.noData,
            style: AppTextStyles.bodyMd(context)
                .copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
