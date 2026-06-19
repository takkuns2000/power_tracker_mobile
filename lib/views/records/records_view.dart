import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:horsepower_tracker_mobile/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';
import '../widgets/glass_card.dart';

const _mockRecords = [
  {
    'date': '2023.10.24 14:30',
    'vehicle': 'PORSCHE 911 GT3',
    'hp': 582,
    'tags': ['Stage 2', '98 OCT'],
    'trend': 12,
    'month': null,
  },
  {
    'date': '2023.10.22 09:15',
    'vehicle': 'Supra MK4',
    'hp': 415,
    'tags': ['Stock Turbo'],
    'trend': -4,
    'month': null,
  },
  {
    'date': null,
    'vehicle': null,
    'hp': null,
    'tags': null,
    'trend': null,
    'month': 'September 2023',
  },
  {
    'date': '2023.09.30 16:45',
    'vehicle': 'Nissan GT-R R35',
    'hp': 600,
    'tags': ['Nismo Pack'],
    'trend': 0,
    'month': null,
  },
  {
    'date': '2023.09.12 11:20',
    'vehicle': 'PORSCHE 911 GT3',
    'hp': 510,
    'tags': ['Stage 1 Baseline'],
    'trend': 8,
    'month': null,
  },
];

class RecordsView extends StatelessWidget {
  const RecordsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.background,
      appBar: _HistoryAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SummarySection(),
              const SizedBox(height: 24),
              ..._mockRecords.map((item) {
                if (item['month'] != null) {
                  return _MonthSeparator(label: item['month'] as String);
                }
                return _RecordCard(item: item);
              }),
              const SizedBox(height: 16),
              _EcuSyncSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryAppBar extends StatelessWidget implements PreferredSizeWidget {
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
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.filter_list,
                      color: AppColors.onSurfaceVariant, size: 20),
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
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                    text: '128 ',
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
                    text: '742 ',
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
  const _RecordCard({required this.item});
  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final trend = item['trend'] as int? ?? 0;
    final hp = item['hp'] as int? ?? 0;
    final tags = item['tags'] as List<String>? ?? [];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
                    item['date'] as String? ?? '',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      color: AppColors.secondary.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['vehicle'] as String? ?? '',
                    style: GoogleFonts.sora(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: tags.map((tag) => _Tag(label: tag)).toList(),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$hp',
                        style: GoogleFonts.sora(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: trend > 0
                              ? AppColors.primary
                              : AppColors.onSurface,
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
                const SizedBox(height: 4),
                _TrendIndicator(trend: trend),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _TrendIndicator extends StatelessWidget {
  const _TrendIndicator({required this.trend});
  final int trend;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (trend == 0) {
      return Row(
        children: [
          const Icon(Icons.horizontal_rule,
              color: AppColors.onSurfaceVariant, size: 16),
          Text(l10n.trendNeutral,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              )),
        ],
      );
    }
    final isUp = trend > 0;
    return Row(
      children: [
        Icon(
          isUp ? Icons.trending_up : Icons.trending_down,
          color: isUp ? AppColors.tertiary : AppColors.error,
          size: 16,
        ),
        Text(
          '${isUp ? '+' : ''}$trend HP',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 13,
            color: isUp ? AppColors.tertiary : AppColors.error,
          ),
        ),
      ],
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

class _EcuSyncSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          style: BorderStyle.solid,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.analytics_outlined,
              color: AppColors.primary, size: 36),
          const SizedBox(height: 12),
          Text(
            l10n.ecuSyncDescription,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMd(context)
                .copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
