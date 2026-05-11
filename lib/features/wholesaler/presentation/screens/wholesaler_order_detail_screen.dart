import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_spacing.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';
import 'package:banabana_b2b/features/wholesaler/providers/wholesaler_order_providers.dart';
import 'package:banabana_b2b/shared/models/order.dart';
import 'package:banabana_b2b/shared/widgets/order_progress_bar.dart';
import 'package:banabana_b2b/shared/widgets/order_status_badge.dart';
import 'package:banabana_b2b/shared/widgets/error_state_widget.dart';
import 'package:banabana_b2b/shared/widgets/loading_shimmer.dart';

String _statusToProgressString(OrderStatus status) => switch (status) {
  OrderStatus.created   => 'pending',
  OrderStatus.preparing => 'accepted',
  OrderStatus.shipped   => 'shipped',
  OrderStatus.delivered => 'delivered',
  OrderStatus.cancelled => 'pending',
};

class WholesalerOrderDetailScreen extends ConsumerStatefulWidget {
  final String orderId;
  const WholesalerOrderDetailScreen({super.key, required this.orderId});

  @override
  ConsumerState<WholesalerOrderDetailScreen> createState() =>
      _WholesalerOrderDetailScreenState();
}

class _WholesalerOrderDetailScreenState
    extends ConsumerState<WholesalerOrderDetailScreen> {
  Future<void> _cancelOrder(String orderId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Annuler la commande ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Retour'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Annuler',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ref.read(wholesalerOrdersProvider.notifier).cancel(orderId);
      if (!mounted) return;
      ref.invalidate(wholesalerOrderDetailProvider(orderId));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final orderAsync = ref.watch(wholesalerOrderDetailProvider(widget.orderId));

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.gray50,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.white,
        foregroundColor: isDark ? AppColors.gray100 : AppColors.gray900,
        elevation: 0,
        title: Text(
          'Détail commande',
          style: AppTextStyles.sectionTitle.copyWith(
            color: isDark ? AppColors.gray100 : AppColors.gray900,
          ),
        ),
      ),
      body: orderAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: ShimmerBox(height: 400),
        ),
        error: (e, _) => ErrorStateWidget(
          message: e.toString(),
          onRetry: () =>
              ref.invalidate(wholesalerOrderDetailProvider(widget.orderId)),
        ),
        data: (order) => ListView(
          padding: const EdgeInsets.all(AppSpacing.s16),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.s16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.gray200,
                ),
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
                          color: isDark ? AppColors.gray100 : AppColors.gray900,
                        ),
                      ),
                      OrderStatusBadge(status: order.status),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt),
                    style: AppTextStyles.caption.copyWith(
                      color: isDark ? AppColors.gray400 : AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s16,
                vertical: AppSpacing.s12,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.gray200,
                ),
              ),
              child: OrderProgressBar(
                currentStatus: _statusToProgressString(order.status),
              ),
            ),
            const SizedBox(height: AppSpacing.s12),
            Container(
              padding: const EdgeInsets.all(AppSpacing.s16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.gray200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Articles',
                    style: AppTextStyles.label.copyWith(
                      color: isDark ? AppColors.gray100 : AppColors.gray900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  ...order.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.s8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Qté ${item.quantity}',
                              style: AppTextStyles.bodySecondary.copyWith(
                                color: isDark
                                    ? AppColors.gray300
                                    : AppColors.gray700,
                              ),
                            ),
                          ),
                          Text(
                            '${(item.unitPrice * item.quantity).toStringAsFixed(0)} FCFA',
                            style: AppTextStyles.label.copyWith(
                              color: isDark
                                  ? AppColors.gray100
                                  : AppColors.gray900,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 24,
                    color: isDark ? AppColors.darkBorder : AppColors.gray200,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: AppTextStyles.body.copyWith(
                          color:
                              isDark ? AppColors.gray100 : AppColors.gray900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${order.totalAmount.toStringAsFixed(0)} FCFA',
                        style: AppTextStyles.price,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (order.status == OrderStatus.created) ...[
              const SizedBox(height: AppSpacing.s24),
              OutlinedButton(
                onPressed: () => _cancelOrder(widget.orderId),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(
                  'Annuler la commande',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
