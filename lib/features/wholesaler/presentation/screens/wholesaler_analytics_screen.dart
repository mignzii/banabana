import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_spacing.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';
import 'package:banabana_b2b/features/wholesaler/providers/wholesaler_order_providers.dart';
import 'package:banabana_b2b/shared/models/order.dart';
import 'package:banabana_b2b/shared/widgets/loading_shimmer.dart';
import 'package:banabana_b2b/shared/widgets/error_state_widget.dart';

enum _Period { week, month, year }

extension _PeriodLabel on _Period {
  String get label => switch (this) {
        _Period.week => 'Semaine',
        _Period.month => 'Mois',
        _Period.year => 'Année',
      };
}

class WholesalerAnalyticsScreen extends ConsumerStatefulWidget {
  const WholesalerAnalyticsScreen({super.key});

  @override
  ConsumerState<WholesalerAnalyticsScreen> createState() =>
      _WholesalerAnalyticsScreenState();
}

class _WholesalerAnalyticsScreenState
    extends ConsumerState<WholesalerAnalyticsScreen> {
  _Period _period = _Period.month;

  DateTime get _cutoff {
    final now = DateTime.now();
    return switch (_period) {
      _Period.week => now.subtract(const Duration(days: 7)),
      _Period.month => DateTime(now.year, now.month - 1, now.day),
      _Period.year => DateTime(now.year - 1, now.month, now.day),
    };
  }

  DateTime get _prevCutoff {
    final c = _cutoff;
    final diff = DateTime.now().difference(c);
    return c.subtract(diff);
  }

  List<Order> _filter(List<Order> orders, DateTime from) =>
      orders.where((o) => o.createdAt.isAfter(from)).toList();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBg : AppColors.gray50;
    final surface = isDark ? AppColors.darkSurface : AppColors.white;
    final textPrimary = isDark ? AppColors.gray100 : AppColors.gray900;
    final border = isDark ? AppColors.darkBorder : AppColors.gray200;

    final ordersAsync = ref.watch(wholesalerOrdersProvider);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg : surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back),
          onPressed: () => context.pop(),
          color: textPrimary,
        ),
        title: Text(
          'Analytiques',
          style: AppTextStyles.sectionTitle.copyWith(color: textPrimary),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: border),
        ),
      ),
      body: ordersAsync.when(
        loading: () => _LoadingSkeleton(isDark: isDark),
        error: (e, _) => ErrorStateWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(wholesalerOrdersProvider),
        ),
        data: (allOrders) {
          final current = _filter(allOrders, _cutoff);
          final previous = _filter(allOrders, _prevCutoff)
              .where((o) => o.createdAt.isBefore(_cutoff))
              .toList();

          final totalSpent = current
              .where((o) => o.status != OrderStatus.cancelled)
              .fold<double>(0, (s, o) => s + o.totalAmount);
          final prevSpent = previous
              .where((o) => o.status != OrderStatus.cancelled)
              .fold<double>(0, (s, o) => s + o.totalAmount);

          final trend = prevSpent > 0
              ? ((totalSpent - prevSpent) / prevSpent * 100)
              : null;

          final pendingCount = current
              .where((o) =>
                  o.status == OrderStatus.created ||
                  o.status == OrderStatus.preparing)
              .length;

          final totalQty = current
              .expand((o) => o.items)
              .fold<int>(0, (s, i) => s + i.quantity);

          // Build top products map
          final Map<String, ({String name, int qty, double amount})> topMap = {};
          for (final o in current.where((o) => o.status != OrderStatus.cancelled)) {
            for (final i in o.items) {
              final key = i.productId;
              final prev = topMap[key];
              topMap[key] = (
                name: i.productName ?? key.substring(0, 8).toUpperCase(),
                qty: (prev?.qty ?? 0) + i.quantity,
                amount: (prev?.amount ?? 0) + i.unitPrice * i.quantity,
              );
            }
          }
          final topProducts = topMap.entries.toList()
            ..sort((a, b) => b.value.amount.compareTo(a.value.amount));
          final maxAmount = topProducts.isEmpty
              ? 1.0
              : topProducts.first.value.amount;

          final fmt = NumberFormat('#,###', 'fr_FR');

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.s16),
            children: [
              // Period selector
              _PeriodSelector(
                current: _period,
                onChanged: (p) => setState(() => _period = p),
                isDark: isDark,
              ),
              const SizedBox(height: AppSpacing.s16),

              // Revenue card
              _RevenueCard(
                totalSpent: totalSpent,
                trend: trend,
                period: _period,
                isDark: isDark,
                fmt: fmt,
              ),
              const SizedBox(height: AppSpacing.s16),

              // Stats grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: AppSpacing.s12,
                mainAxisSpacing: AppSpacing.s12,
                childAspectRatio: 1.6,
                children: [
                  _StatCard(
                    icon: Symbols.shopping_bag,
                    label: 'Commandes',
                    value: '${current.length}',
                    color: AppColors.primary,
                    isDark: isDark,
                  ),
                  _StatCard(
                    icon: Symbols.inventory_2,
                    label: 'Produits commandés',
                    value: '$totalQty',
                    color: AppColors.secondary,
                    isDark: isDark,
                  ),
                  _StatCard(
                    icon: Symbols.check_circle,
                    label: 'Livrées',
                    value:
                        '${current.where((o) => o.status == OrderStatus.delivered).length}',
                    color: AppColors.success,
                    isDark: isDark,
                  ),
                  _StatCard(
                    icon: Symbols.pending_actions,
                    label: 'En attente',
                    value: '$pendingCount',
                    color: AppColors.warning,
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s16),

              // Top products
              if (topProducts.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusLarge),
                    border:
                        isDark ? Border.all(color: AppColors.darkBorder) : null,
                    boxShadow: isDark
                        ? null
                        : [
                            BoxShadow(
                              color: AppColors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Top produits commandés',
                        style: AppTextStyles.sectionTitle.copyWith(
                            fontSize: 15, color: textPrimary),
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      ...topProducts.take(5).toList().asMap().entries.map((e) {
                        final rank = e.key + 1;
                        final p = e.value.value;
                        final ratio = maxAmount > 0
                            ? (p.amount / maxAmount).clamp(0.0, 1.0)
                            : 0.0;
                        return _TopProductRow(
                          rank: rank,
                          name: p.name,
                          qty: p.qty,
                          amount: p.amount,
                          ratio: ratio,
                          isDark: isDark,
                          fmt: fmt,
                        );
                      }),
                    ],
                  ),
                ),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }
}

// ── Period selector ────────────────────────────────────────────────────────────
class _PeriodSelector extends StatelessWidget {
  final _Period current;
  final void Function(_Period) onChanged;
  final bool isDark;

  const _PeriodSelector({
    required this.current,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : AppColors.white;
    final border = isDark ? AppColors.darkBorder : AppColors.gray200;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(color: border),
      ),
      child: Row(
        children: _Period.values.map((p) {
          final selected = p == current;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.transparent,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusMedium),
                ),
                child: Text(
                  p.label,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.label.copyWith(
                    fontSize: 13,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected
                        ? AppColors.white
                        : (isDark ? AppColors.gray400 : AppColors.gray600),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Revenue card ──────────────────────────────────────────────────────────────
class _RevenueCard extends StatelessWidget {
  final double totalSpent;
  final double? trend;
  final _Period period;
  final bool isDark;
  final NumberFormat fmt;

  const _RevenueCard({
    required this.totalSpent,
    required this.trend,
    required this.period,
    required this.isDark,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    final trendUp = (trend ?? 0) >= 0;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Symbols.payments, color: AppColors.white, size: 18),
              const SizedBox(width: 6),
              Text(
                'Total dépensé — ${period.label}',
                style: AppTextStyles.caption.copyWith(
                    color: AppColors.white.withValues(alpha: 0.8),
                    fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            '${fmt.format(totalSpent)} FCFA',
            style: AppTextStyles.price.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.white),
          ),
          if (trend != null) ...[
            const SizedBox(height: AppSpacing.s8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    trendUp
                        ? Symbols.trending_up
                        : Symbols.trending_down,
                    size: 14,
                    color: AppColors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${trendUp ? '+' : ''}${trend!.toStringAsFixed(1)}% vs période précédente',
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Stat card ──────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : AppColors.white;
    final textPrimary = isDark ? AppColors.gray100 : AppColors.gray900;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: isDark ? Border.all(color: AppColors.darkBorder) : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                )
              ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.s10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: AppSpacing.s10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: AppTextStyles.label.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: textPrimary),
                ),
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                      color: AppColors.gray500,
                      fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Top product row ────────────────────────────────────────────────────────────
class _TopProductRow extends StatelessWidget {
  final int rank;
  final String name;
  final int qty;
  final double amount;
  final double ratio;
  final bool isDark;
  final NumberFormat fmt;

  const _TopProductRow({
    required this.rank,
    required this.name,
    required this.qty,
    required this.amount,
    required this.ratio,
    required this.isDark,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? AppColors.gray100 : AppColors.gray900;
    final rankColor = rank == 1
        ? const Color(0xFFFFD700)
        : rank == 2
            ? const Color(0xFFC0C0C0)
            : rank == 3
                ? const Color(0xFFCD7F32)
                : AppColors.gray500;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 24,
                child: Text(
                  '$rank',
                  style: AppTextStyles.label.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: rankColor),
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Expanded(
                child: Text(
                  name,
                  style: AppTextStyles.label.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${fmt.format(amount)} FCFA',
                    style: AppTextStyles.label.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary),
                  ),
                  Text(
                    '$qty unités',
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.gray500, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s6),
          LinearProgressIndicator(
            value: ratio,
            backgroundColor:
                isDark ? AppColors.darkBorder : AppColors.gray100,
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4),
            minHeight: 4,
          ),
        ],
      ),
    );
  }
}

// ── Loading skeleton ───────────────────────────────────────────────────────────
class _LoadingSkeleton extends StatelessWidget {
  final bool isDark;
  const _LoadingSkeleton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.s16),
      children: [
        const ShimmerBox(height: 44),
        const SizedBox(height: AppSpacing.s16),
        const ShimmerBox(height: 110),
        const SizedBox(height: AppSpacing.s16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppSpacing.s12,
          mainAxisSpacing: AppSpacing.s12,
          childAspectRatio: 1.6,
          children: List.generate(4, (_) => const ShimmerBox(height: 80)),
        ),
        const SizedBox(height: AppSpacing.s16),
        const ShimmerBox(height: 200),
      ],
    );
  }
}
