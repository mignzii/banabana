import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_spacing.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';
import 'package:banabana_b2b/features/wholesaler/providers/wholesaler_order_providers.dart';
import 'package:banabana_b2b/features/wholesaler/presentation/widgets/cart_badge.dart';
import 'package:banabana_b2b/shared/models/order.dart';
import 'package:banabana_b2b/shared/widgets/stat_card.dart';
import 'package:banabana_b2b/shared/widgets/order_status_badge.dart';
import 'package:banabana_b2b/shared/widgets/error_state_widget.dart';
import 'package:banabana_b2b/shared/widgets/loading_shimmer.dart';

class ShopDashboardScreen extends ConsumerWidget {
  const ShopDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBg : AppColors.gray50;
    final textPrimary = isDark ? AppColors.gray100 : AppColors.gray900;

    final ordersAsync = ref.watch(wholesalerOrdersProvider);

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            snap: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s20, 60, AppSpacing.s20, AppSpacing.s16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Bienvenue',
                      style: AppTextStyles.bodySecondary.copyWith(
                          color: AppColors.white.withValues(alpha: 0.7),
                          fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'BanaBana Shop',
                      style: AppTextStyles.screenTitle.copyWith(
                          color: AppColors.white, fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              CartBadge(
                child: IconButton(
                  icon: const Icon(Symbols.shopping_cart,
                      color: AppColors.white),
                  onPressed: () => context.push('/shop/cart'),
                ),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.s16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                ordersAsync.when(
                  loading: () => GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: AppSpacing.s12,
                    mainAxisSpacing: AppSpacing.s12,
                    childAspectRatio: 1.4,
                    children: List.generate(
                        4, (_) => const ShimmerBox(height: 90)),
                  ),
                  error: (e, _) => ErrorStateWidget(
                    message: e.toString(),
                    onRetry: () => ref.invalidate(wholesalerOrdersProvider),
                  ),
                  data: (orders) {
                    final fmt = NumberFormat('#,###', 'fr_FR');
                    final totalSpent = orders
                        .where((o) => o.status != OrderStatus.cancelled)
                        .fold<double>(0, (s, o) => s + o.totalAmount);
                    final pending = orders
                        .where((o) =>
                            o.status == OrderStatus.created ||
                            o.status == OrderStatus.preparing)
                        .length;
                    return GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: AppSpacing.s12,
                      mainAxisSpacing: AppSpacing.s12,
                      childAspectRatio: 1.4,
                      children: [
                        StatCard(
                          label: 'Commandes',
                          value: '${orders.length}',
                          icon: Symbols.shopping_bag,
                        ),
                        StatCard(
                          label: 'Dépenses FCFA',
                          value: fmt.format(totalSpent),
                          icon: Symbols.payments,
                          iconColor: AppColors.secondary,
                        ),
                        StatCard(
                          label: 'En cours',
                          value: '$pending',
                          icon: Symbols.pending_actions,
                          iconColor: AppColors.warning,
                        ),
                        StatCard(
                          label: 'Livrées',
                          value:
                              '${orders.where((o) => o.status == OrderStatus.delivered).length}',
                          icon: Symbols.check_circle,
                          iconColor: AppColors.success,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.s16),
                FilledButton.icon(
                  onPressed: () => context.push('/shop/catalog'),
                  icon: const Icon(Symbols.search),
                  label: const Text('Explorer le catalogue'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    minimumSize: const Size.fromHeight(AppSpacing.touchTarget),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusLarge)),
                  ),
                ),
                const SizedBox(height: AppSpacing.s24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Commandes récentes',
                      style: AppTextStyles.sectionTitle.copyWith(
                          color: textPrimary, fontSize: 16),
                    ),
                    TextButton(
                      onPressed: () => context.push('/shop/orders'),
                      child: const Text('Voir tout'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s8),
                ordersAsync.when(
                  loading: () => const ShimmerBox(height: 160),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (orders) {
                    final recent = orders.take(3).toList();
                    if (recent.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.s24),
                        child: Center(
                          child: Text(
                            'Aucune commande',
                            style: AppTextStyles.bodySecondary.copyWith(
                                color: AppColors.gray500),
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: recent
                          .map((o) => _RecentOrderTile(order: o))
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentOrderTile extends StatelessWidget {
  final Order order;
  const _RecentOrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.gray100 : AppColors.gray900;

    return GestureDetector(
      onTap: () => context.push('/shop/orders/${order.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.s8),
        padding: const EdgeInsets.all(AppSpacing.s12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          border: isDark ? Border.all(color: AppColors.darkBorder) : null,
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.04),
                      blurRadius: 6),
                ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${order.id.substring(0, 8).toUpperCase()}',
                    style: AppTextStyles.label.copyWith(
                        color: textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${order.totalAmount.toStringAsFixed(0)} FCFA',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.gray500, fontSize: 12),
                  ),
                ],
              ),
            ),
            OrderStatusBadge(status: order.status),
          ],
        ),
      ),
    );
  }
}
