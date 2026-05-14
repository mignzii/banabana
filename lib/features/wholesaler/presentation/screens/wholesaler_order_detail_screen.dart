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
import 'package:banabana_b2b/shared/widgets/app_snack_bar.dart';
import 'package:banabana_b2b/shared/widgets/error_state_widget.dart';
import 'package:banabana_b2b/shared/widgets/loading_shimmer.dart';
import 'package:banabana_b2b/shared/widgets/order_progress_bar.dart';
import 'package:banabana_b2b/shared/widgets/order_status_badge.dart';

String _statusToProgressString(OrderStatus status) => switch (status) {
      OrderStatus.created => 'pending',
      OrderStatus.preparing => 'accepted',
      OrderStatus.shipped => 'shipped',
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
  Future<void> _cancelOrder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Annuler la commande ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: const Text('Retour'),
          ),
          TextButton(
            onPressed: () => ctx.pop(true),
            child: Text(
              'Annuler',
              style: AppTextStyles.label.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref
          .read(wholesalerOrdersProvider.notifier)
          .cancel(widget.orderId);
      if (!mounted) return;
      ref.invalidate(wholesalerOrderDetailProvider(widget.orderId));
      context.showSnack('Commande annulée', type: SnackType.info);
    } catch (e) {
      if (!mounted) return;
      context.showSnack('Erreur: ${e.toString()}', type: SnackType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final orderAsync =
        ref.watch(wholesalerOrderDetailProvider(widget.orderId));

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
          padding: EdgeInsets.all(AppSpacing.s16),
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
            _buildHeaderCard(order, isDark),
            const SizedBox(height: AppSpacing.s12),
            if (order.status != OrderStatus.cancelled)
              _buildProgressCard(order, isDark),
            if (order.status != OrderStatus.cancelled)
              const SizedBox(height: AppSpacing.s12),
            _buildItemsCard(order, isDark),
            const SizedBox(height: AppSpacing.s12),
            _buildSummaryCard(order, isDark),
            if (order.notes != null && order.notes!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.s12),
              _buildNotesCard(order, isDark),
            ],
            if (order.status == OrderStatus.created) ...[
              const SizedBox(height: AppSpacing.s24),
              OutlinedButton.icon(
                onPressed: _cancelOrder,
                icon: Icon(Symbols.cancel, size: 18, color: AppColors.error),
                label: Text(
                  'Annuler la commande',
                  style: AppTextStyles.label.copyWith(color: AppColors.error),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  minimumSize: const Size.fromHeight(AppSpacing.touchTarget),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.s32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(Order order, bool isDark) {
    final fmt = DateFormat('d MMMM yyyy HH:mm', 'fr_FR');
    return _Card(
      isDark: isDark,
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
                  color: isDark ? AppColors.white : AppColors.gray900,
                ),
              ),
              OrderStatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            'Passée le ${fmt.format(order.createdAt)}',
            style: AppTextStyles.caption.copyWith(
              color: isDark ? AppColors.gray400 : AppColors.gray500,
            ),
          ),
          if (order.deliveryAddress != null &&
              order.deliveryAddress!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s12),
            Row(
              children: [
                Icon(
                  Symbols.location_on,
                  size: 16,
                  color: isDark ? AppColors.gray400 : AppColors.gray500,
                ),
                const SizedBox(width: AppSpacing.s8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Adresse de livraison',
                        style: AppTextStyles.caption.copyWith(
                          color: isDark
                              ? AppColors.gray400
                              : AppColors.gray500,
                        ),
                      ),
                      Text(
                        order.deliveryAddress!,
                        style: AppTextStyles.label.copyWith(
                          color: isDark
                              ? AppColors.gray100
                              : AppColors.gray900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressCard(Order order, bool isDark) {
    return _Card(
      isDark: isDark,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s12,
      ),
      child: OrderProgressBar(
        currentStatus: _statusToProgressString(order.status),
      ),
    );
  }

  Widget _buildItemsCard(Order order, bool isDark) {
    final fmt = NumberFormat('#,###', 'fr_FR');
    return _Card(
      isDark: isDark,
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
                'Articles commandés',
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.white : AppColors.gray900,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          ...order.items.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.s8),
              padding: const EdgeInsets.all(AppSpacing.s12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface2 : AppColors.gray50,
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusMedium),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.productName ??
                              (item.variantName ??
                                  'Produit ${item.productId.substring(0, 6)}'),
                          style: AppTextStyles.label.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.gray100
                                : AppColors.gray900,
                          ),
                        ),
                      ),
                      Text(
                        '${fmt.format((item.unitPrice * item.quantity).toInt())} FCFA',
                        style: AppTextStyles.price.copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    'Qté : ${item.quantity} ${item.unit ?? 'unité(s)'} · ${fmt.format(item.unitPrice.toInt())} FCFA/u',
                    style: AppTextStyles.caption.copyWith(
                      color: isDark
                          ? AppColors.gray400
                          : AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(
            height: AppSpacing.s24,
            color: isDark ? AppColors.darkBorder : AppColors.gray200,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: AppTextStyles.label.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.white : AppColors.gray900,
                ),
              ),
              Text(
                '${fmt.format(order.totalAmount.toInt())} FCFA',
                style: AppTextStyles.price.copyWith(fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(Order order, bool isDark) {
    final fmt = NumberFormat('#,###', 'fr_FR');
    return _Card(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RÉCAPITULATIF',
            style: AppTextStyles.caption.copyWith(
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.gray400 : AppColors.gray500,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          Container(
            padding: const EdgeInsets.all(AppSpacing.s12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface2 : AppColors.gray50,
              borderRadius:
                  BorderRadius.circular(AppSpacing.radiusMedium),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sous-total',
                      style: AppTextStyles.label.copyWith(
                        color: isDark
                            ? AppColors.gray400
                            : AppColors.gray500,
                      ),
                    ),
                    Text(
                      '${fmt.format(order.totalAmount.toInt())} FCFA',
                      style: AppTextStyles.label.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.gray100
                            : AppColors.gray900,
                      ),
                    ),
                  ],
                ),
                Divider(
                  height: AppSpacing.s24,
                  color: isDark
                      ? AppColors.darkBorder
                      : AppColors.gray200,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: AppTextStyles.label.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.white
                            : AppColors.gray900,
                      ),
                    ),
                    Text(
                      '${fmt.format(order.totalAmount.toInt())} FCFA',
                      style: AppTextStyles.price.copyWith(fontSize: 15),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard(Order order, bool isDark) {
    return _Card(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NOTES',
            style: AppTextStyles.caption.copyWith(
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.gray400 : AppColors.gray500,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            order.notes!,
            style: AppTextStyles.body.copyWith(
              color: isDark ? AppColors.gray300 : AppColors.gray700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.child,
    required this.isDark,
    this.padding,
  });

  final Widget child;
  final bool isDark;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.s16),
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
      child: child,
    );
  }
}
