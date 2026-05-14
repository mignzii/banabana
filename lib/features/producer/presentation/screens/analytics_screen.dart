import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';
import 'package:banabana_b2b/core/theme/app_spacing.dart';
import 'package:banabana_b2b/features/producer/data/analytics_repository.dart';
import 'package:banabana_b2b/features/producer/providers/analytics_providers.dart';
import 'package:banabana_b2b/shared/widgets/error_state_widget.dart';
import 'package:banabana_b2b/shared/widgets/loading_shimmer.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBg : AppColors.gray50;
    final textPrimary = isDark ? AppColors.gray100 : AppColors.gray900;
    final border = isDark ? AppColors.darkBorder : AppColors.gray100;
    final analyticsAsync = ref.watch(analyticsSummaryProvider);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.white,
        elevation: 0,
        title: Text('Analytiques', style: AppTextStyles.sectionTitle.copyWith(color: textPrimary)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: border),
        ),
      ),
      body: analyticsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              ShimmerBox(height: 200),
              SizedBox(height: 16),
              ShimmerBox(height: 200),
            ],
          ),
        ),
        error: (e, _) => ErrorStateWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(analyticsSummaryProvider),
        ),
        data: (summary) => ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            _SummaryRow(summary: summary),
            SizedBox(height: AppSpacing.s24),
            _RevenueChart(data: summary.revenueByDay),
            SizedBox(height: AppSpacing.s24),
            if (summary.topProducts.isNotEmpty)
              _TopProductsChart(products: summary.topProducts),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final AnalyticsSummary summary;
  const _SummaryRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###', 'fr_FR');
    return Row(
      children: [
        Expanded(
          child: _InfoCard(
            label: 'Revenus totaux',
            value: '${fmt.format(summary.totalRevenue)} FCFA',
            color: AppColors.success,
          ),
        ),
        SizedBox(width: AppSpacing.s12),
        Expanded(
          child: _InfoCard(
            label: 'Commandes',
            value: '${summary.totalOrders}',
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: AppSpacing.s12),
        Expanded(
          child: _InfoCard(
            label: 'En attente',
            value: '${summary.pendingOrders}',
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _InfoCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.white;
    final shadowColor = isDark
        ? AppColors.black.withValues(alpha: 0.2)
        : AppColors.black.withValues(alpha: 0.05);
    final textSecondary = isDark ? AppColors.gray500 : AppColors.gray400;

    return Container(
      padding: EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall + 2),
        boxShadow: [BoxShadow(color: shadowColor, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTextStyles.label.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: AppSpacing.s4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: textSecondary),
          ),
        ],
      ),
    );
  }
}

class _RevenueChart extends StatelessWidget {
  final List<DailyRevenue> data;
  const _RevenueChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.white;
    final shadowColor = isDark
        ? AppColors.black.withValues(alpha: 0.2)
        : AppColors.black.withValues(alpha: 0.05);
    final textPrimary = isDark ? AppColors.gray100 : AppColors.gray900;

    final spots = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.revenue))
        .toList();

    return Container(
      padding: EdgeInsets.all(AppSpacing.screenPadding),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        boxShadow: [BoxShadow(color: shadowColor, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Revenus (30 derniers jours)',
            style: AppTextStyles.label.copyWith(
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.s16),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopProductsChart extends StatelessWidget {
  final List<TopProduct> products;
  const _TopProductsChart({required this.products});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.white;
    final shadowColor = isDark
        ? AppColors.black.withValues(alpha: 0.2)
        : AppColors.black.withValues(alpha: 0.05);
    final textPrimary = isDark ? AppColors.gray100 : AppColors.gray900;

    final maxQty = products
        .map((p) => p.totalQuantity)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    return Container(
      padding: EdgeInsets.all(AppSpacing.screenPadding),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        boxShadow: [BoxShadow(color: shadowColor, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top 5 produits (quantité)',
            style: AppTextStyles.label.copyWith(
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.s16),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                maxY: maxQty * 1.2,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(show: false),
                barGroups: products
                    .asMap()
                    .entries
                    .map(
                      (e) => BarChartGroupData(
                        x: e.key,
                        barRods: [
                          BarChartRodData(
                            toY: e.value.totalQuantity.toDouble(),
                            color: AppColors.primary,
                            width: 18,
                            borderRadius: BorderRadius.circular(AppSpacing.s4.toDouble()),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
