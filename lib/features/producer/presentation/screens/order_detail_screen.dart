import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_spacing.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';
import 'package:banabana_b2b/features/producer/providers/order_providers.dart';
import 'package:banabana_b2b/features/producer/presentation/widgets/order_actions_sheet.dart';
import 'package:banabana_b2b/shared/models/order.dart';
import 'package:banabana_b2b/shared/widgets/order_progress_bar.dart';
import 'package:banabana_b2b/shared/widgets/order_status_badge.dart';
import 'package:banabana_b2b/shared/widgets/error_state_widget.dart';
import 'package:banabana_b2b/shared/widgets/loading_shimmer.dart';

// Maps OrderStatus enum → string accepted by OrderProgressBar
String _statusToProgressString(OrderStatus status) => switch (status) {
      OrderStatus.created => 'pending',
      OrderStatus.preparing => 'accepted',
      OrderStatus.shipped => 'shipped',
      OrderStatus.delivered => 'delivered',
      OrderStatus.cancelled => 'pending',
    };

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final orderAsync = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.gray50,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.white,
        elevation: 0,
        title: Text(
          'Détail commande',
          style: AppTextStyles.sectionTitle.copyWith(
            color: isDark ? AppColors.white : AppColors.gray900,
          ),
        ),
        iconTheme: IconThemeData(
          color: isDark ? AppColors.white : AppColors.gray900,
        ),
      ),
      body: orderAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.s16),
          child: ShimmerBox(height: 400),
        ),
        error: (e, _) => ErrorStateWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(orderDetailProvider(orderId)),
        ),
        data: (order) => ListView(
          padding: const EdgeInsets.all(AppSpacing.s16),
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(AppSpacing.s16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                border:
                    isDark ? Border.all(color: AppColors.darkBorder) : null,
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
                      Text(
                        '#${order.id.substring(0, 8).toUpperCase()}',
                        style: AppTextStyles.sectionTitle.copyWith(
                          fontSize: 18,
                          color:
                              isDark ? AppColors.white : AppColors.gray900,
                        ),
                      ),
                      OrderStatusBadge(status: order.status),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt),
                    style: AppTextStyles.caption.copyWith(
                      color: isDark ? AppColors.gray500 : AppColors.gray400,
                    ),
                  ),
                ],
              ),
            ),
            // Progress bar
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s16,
                AppSpacing.s16,
                AppSpacing.s16,
                AppSpacing.s8,
              ),
              child: OrderProgressBar(
                currentStatus: _statusToProgressString(order.status),
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            // Items card
            Container(
              padding: const EdgeInsets.all(AppSpacing.s16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                border:
                    isDark ? Border.all(color: AppColors.darkBorder) : null,
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
                    children: [
                      Icon(
                        Symbols.inventory_2,
                        size: 16,
                        color: isDark ? AppColors.gray400 : AppColors.gray500,
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      Text(
                        'Articles',
                        style: AppTextStyles.label.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.white : AppColors.gray900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  ...order.items.map(
                    (item) => Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.s8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Produit • Qté ${item.quantity}',
                              style: AppTextStyles.label.copyWith(
                                color: isDark
                                    ? AppColors.gray200
                                    : AppColors.gray800,
                              ),
                            ),
                          ),
                          Text(
                            '${(item.unitPrice * item.quantity).toStringAsFixed(0)} FCFA',
                            style: AppTextStyles.label.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.white
                                  : AppColors.gray900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: AppSpacing.s24,
                    color:
                        isDark ? AppColors.darkBorder : AppColors.gray200,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: AppTextStyles.label.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color:
                              isDark ? AppColors.white : AppColors.gray900,
                        ),
                      ),
                      Text(
                        '${order.totalAmount.toStringAsFixed(0)} FCFA',
                        style: AppTextStyles.price.copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s32),
            if (order.status == OrderStatus.created)
              FilledButton.icon(
                onPressed: () =>
                    OrderActionsSheet.show(context, order: order),
                icon: const Icon(Symbols.touch_app),
                label: const Text('Actions'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(AppSpacing.touchTarget),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
