import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_spacing.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';
import 'package:banabana_b2b/features/wholesaler/providers/wholesaler_order_providers.dart';
import 'package:banabana_b2b/shared/models/order.dart';
import 'package:banabana_b2b/shared/widgets/empty_state_widget.dart';
import 'package:banabana_b2b/shared/widgets/error_state_widget.dart';
import 'package:banabana_b2b/shared/widgets/loading_shimmer.dart';
import 'package:banabana_b2b/shared/widgets/order_status_badge.dart';
import 'package:intl/intl.dart';

typedef _Tab = (OrderStatus?, String, IconData);

const List<_Tab> _tabs = [
  (null,                    'Toutes',      Symbols.list),
  (OrderStatus.created,     'En attente',  Symbols.schedule),
  (OrderStatus.preparing,   'En cours',    Symbols.hourglass),
  (OrderStatus.shipped,     'Expédiées',   Symbols.local_shipping),
  (OrderStatus.delivered,   'Livrées',     Symbols.check_circle),
  (OrderStatus.cancelled,   'Annulées',    Symbols.cancel),
];

String _relativeDate(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
  if (diff.inDays == 1) return 'Hier';
  if (diff.inDays < 7) return 'Il y a ${diff.inDays} jours';
  return DateFormat('d MMM', 'fr_FR').format(dt);
}

class WholesalerOrdersScreen extends ConsumerStatefulWidget {
  const WholesalerOrdersScreen({super.key});

  @override
  ConsumerState<WholesalerOrdersScreen> createState() =>
      _WholesalerOrdersScreenState();
}

class _WholesalerOrdersScreenState
    extends ConsumerState<WholesalerOrdersScreen> {
  OrderStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ordersAsync = ref.watch(wholesalerOrdersProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.gray50,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.white,
        elevation: 0,
        title: Text(
          'Mes commandes',
          style: AppTextStyles.sectionTitle.copyWith(
            color: isDark ? AppColors.white : AppColors.gray900,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: isDark ? AppColors.darkBg : AppColors.white,
            child: Column(
              children: [
                Divider(
                  height: 1,
                  color: isDark ? AppColors.darkBorder : AppColors.gray200,
                ),
                SizedBox(
                  height: 50,
                  child: ordersAsync.whenOrNull(
                    data: (orders) => ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s16,
                        vertical: AppSpacing.s8,
                      ),
                      itemCount: _tabs.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: AppSpacing.s8),
                      itemBuilder: (_, i) {
                        final (status, label, icon) = _tabs[i];
                        final count = status == null
                            ? orders.length
                            : orders
                                .where((o) => o.status == status)
                                .length;
                        final isActive = _filter == status;
                        return _FilterChip(
                          label: '$label ($count)',
                          icon: icon,
                          isActive: isActive,
                          isDark: isDark,
                          onTap: () => setState(() => _filter = status),
                        );
                      },
                    ),
                  ) ??
                      ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s16,
                          vertical: AppSpacing.s8,
                        ),
                        itemCount: _tabs.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: AppSpacing.s8),
                        itemBuilder: (_, i) {
                          final (status, label, icon) = _tabs[i];
                          final isActive = _filter == status;
                          return _FilterChip(
                            label: label,
                            icon: icon,
                            isActive: isActive,
                            isDark: isDark,
                            onTap: () => setState(() => _filter = status),
                          );
                        },
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () =>
                  ref.read(wholesalerOrdersProvider.notifier).load(),
              child: ordersAsync.when(
                loading: () => ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSpacing.s8),
                  itemCount: 5,
                  itemBuilder: (_, __) => const OrderCardShimmer(),
                ),
                error: (e, _) => ErrorStateWidget(
                  message: e.toString(),
                  onRetry: () =>
                      ref.read(wholesalerOrdersProvider.notifier).load(),
                ),
                data: (orders) {
                  final filtered = _filter == null
                      ? orders
                      : orders
                          .where((o) => o.status == _filter)
                          .toList();

                  if (filtered.isEmpty) {
                    return EmptyStateWidget(
                      icon: Symbols.receipt_long,
                      title: 'Aucune commande',
                      subtitle: _filter == null
                          ? 'Vos commandes apparaîtront ici.'
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
                          context.push('/shop/orders/${filtered[i].id}'),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s12,
          vertical: AppSpacing.s4,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary
              : (isDark ? AppColors.darkSurface : AppColors.gray100),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? AppColors.primary
                : (isDark ? AppColors.darkBorder : AppColors.gray200),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive
                  ? AppColors.white
                  : (isDark ? AppColors.gray400 : AppColors.gray500),
            ),
            const SizedBox(width: AppSpacing.s4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: isActive
                    ? AppColors.white
                    : (isDark ? AppColors.gray400 : AppColors.gray600),
              ),
            ),
          ],
        ),
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
            border: isDark
                ? Border.all(color: AppColors.darkBorder)
                : null,
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Symbols.receipt_long,
                        size: 16,
                        color: isDark
                            ? AppColors.gray400
                            : AppColors.gray500,
                      ),
                      const SizedBox(width: AppSpacing.s4),
                      Text(
                        '#${order.id.substring(0, 8).toUpperCase()}',
                        style: AppTextStyles.label.copyWith(
                          color: isDark
                              ? AppColors.gray100
                              : AppColors.gray900,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  OrderStatusBadge(status: order.status),
                ],
              ),
              const SizedBox(height: AppSpacing.s8),
              Row(
                children: [
                  Icon(
                    Symbols.inventory_2,
                    size: 14,
                    color: isDark ? AppColors.gray500 : AppColors.gray400,
                  ),
                  const SizedBox(width: AppSpacing.s6),
                  Text(
                    '${order.items.length} article${order.items.length > 1 ? 's' : ''}',
                    style: AppTextStyles.caption.copyWith(
                      color: isDark
                          ? AppColors.gray400
                          : AppColors.gray500,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Icon(
                    Symbols.schedule,
                    size: 14,
                    color: isDark ? AppColors.gray500 : AppColors.gray400,
                  ),
                  const SizedBox(width: AppSpacing.s6),
                  Text(
                    _relativeDate(order.createdAt),
                    style: AppTextStyles.caption.copyWith(
                      color: isDark
                          ? AppColors.gray400
                          : AppColors.gray500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s8),
              Divider(
                height: 1,
                color: isDark ? AppColors.darkBorder : AppColors.gray100,
              ),
              const SizedBox(height: AppSpacing.s8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: AppTextStyles.caption.copyWith(
                      color: isDark
                          ? AppColors.gray400
                          : AppColors.gray500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '${fmt.format(order.totalAmount.toInt())} FCFA',
                        style: AppTextStyles.price.copyWith(fontSize: 13),
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      Icon(
                        Symbols.chevron_right,
                        size: 16,
                        color: isDark
                            ? AppColors.gray600
                            : AppColors.gray300,
                      ),
                    ],
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
