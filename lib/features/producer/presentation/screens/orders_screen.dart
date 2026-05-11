import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_spacing.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';
import 'package:banabana_b2b/features/producer/providers/order_providers.dart';
import 'package:banabana_b2b/shared/models/order.dart';
import 'package:banabana_b2b/shared/widgets/empty_state_widget.dart';
import 'package:banabana_b2b/shared/widgets/error_state_widget.dart';
import 'package:banabana_b2b/shared/widgets/loading_shimmer.dart';
import 'package:banabana_b2b/shared/widgets/order_status_badge.dart';
import 'package:intl/intl.dart';

// (filterStatus: null = all)
const _tabs = [
  (null,                   'Toutes'),
  (OrderStatus.created,    'Nouvelles'),
  (OrderStatus.preparing,  'En cours'),
  (OrderStatus.shipped,    'Expédiées'),
];

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.gray50,
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.darkBg : AppColors.white,
          title: Text(
            'Commandes',
            style: AppTextStyles.sectionTitle.copyWith(
              color: isDark ? AppColors.white : AppColors.gray900,
            ),
          ),
          elevation: 0,
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor:
                isDark ? AppColors.gray500 : AppColors.gray400,
            indicatorColor: AppColors.primary,
            indicatorWeight: 2,
            labelStyle:
                AppTextStyles.label.copyWith(fontWeight: FontWeight.w600),
            unselectedLabelStyle: AppTextStyles.label,
            tabs: _tabs.map((t) => Tab(text: t.$2)).toList(),
          ),
        ),
        body: TabBarView(
          children: _tabs
              .map(
                (t) => _OrdersList(
                  filterStatus: t.$1,
                  isDark: isDark,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _OrdersList extends ConsumerWidget {
  const _OrdersList({required this.filterStatus, required this.isDark});

  final OrderStatus? filterStatus;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersNotifierProvider);

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async =>
          ref.read(ordersNotifierProvider.notifier).load(),
      child: ordersAsync.when(
        loading: () => ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
          itemCount: 5,
          itemBuilder: (_, __) => const OrderCardShimmer(),
        ),
        error: (e, _) => ErrorStateWidget(
          message: e.toString(),
          onRetry: () => ref.read(ordersNotifierProvider.notifier).load(),
        ),
        data: (orders) {
          final filtered = filterStatus == null
              ? orders
              : orders.where((o) => o.status == filterStatus).toList();

          if (filtered.isEmpty) {
            return EmptyStateWidget(
              icon: Symbols.receipt_long,
              title: 'Aucune commande',
              subtitle: filterStatus == null
                  ? 'Vous recevrez vos commandes ici.'
                  : 'Aucune commande dans cet état.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16,
              vertical: AppSpacing.s12,
            ),
            itemCount: filtered.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.s8),
            itemBuilder: (_, i) => _OrderCard(
              order: filtered[i],
              isDark: isDark,
              onTap: () =>
                  context.push('/producer/orders/${filtered[i].id}'),
            ),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.isDark,
    required this.onTap,
  });

  final Order order;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###', 'fr_FR');
    final date = DateFormat('dd/MM/yyyy').format(order.createdAt);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.s16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            border: isDark ? Border.all(color: AppColors.darkBorder) : null,
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                    ),
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
                        color:
                            isDark ? AppColors.gray100 : AppColors.gray900,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    Text(
                      date,
                      style: AppTextStyles.caption.copyWith(
                        color:
                            isDark ? AppColors.gray500 : AppColors.gray400,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    Text(
                      '${fmt.format(order.totalAmount.toInt())} FCFA',
                      style: AppTextStyles.price.copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  OrderStatusBadge(status: order.status),
                  const SizedBox(height: AppSpacing.s8),
                  Icon(
                    Symbols.chevron_right,
                    size: 18,
                    color: isDark ? AppColors.gray600 : AppColors.gray300,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
