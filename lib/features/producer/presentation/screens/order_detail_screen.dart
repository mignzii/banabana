import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_spacing.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';
import 'package:banabana_b2b/features/producer/providers/order_providers.dart';
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

class OrderDetailScreen extends ConsumerStatefulWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  bool _actionLoading = false;

  Future<void> _accept(Order order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Accepter la commande ?'),
        content: Text(
          'Confirmer la commande de ${order.wholesalerName ?? 'ce grossiste'} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => ctx.pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            child: const Text('Accepter'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _actionLoading = true);
    try {
      await ref
          .read(ordersNotifierProvider.notifier)
          .accept(widget.orderId);
      ref.invalidate(orderDetailProvider(widget.orderId));
      if (mounted) {
        context.showSnack('Commande acceptée', type: SnackType.success);
      }
    } catch (e) {
      if (mounted) context.showSnack(e.toString(), type: SnackType.error);
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  Future<void> _reject(Order order) async {
    final reasonCtrl = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rejeter la commande'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Indiquez la raison du rejet :'),
            const SizedBox(height: AppSpacing.s12),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(hintText: 'Raison...'),
              autofocus: true,
              minLines: 2,
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => ctx.pop(reasonCtrl.text.trim()),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Rejeter'),
          ),
        ],
      ),
    );
    if (reason == null || reason.isEmpty) return;
    setState(() => _actionLoading = true);
    try {
      await ref
          .read(ordersNotifierProvider.notifier)
          .reject(widget.orderId, reason);
      ref.invalidate(orderDetailProvider(widget.orderId));
      if (mounted) {
        context.showSnack('Commande rejetée', type: SnackType.info);
        context.pop();
      }
    } catch (e) {
      if (mounted) context.showSnack(e.toString(), type: SnackType.error);
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  Future<void> _ship(Order order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Expédier la commande ?'),
        content: const Text(
            'Confirmer l\'expédition de cette commande ?'),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => ctx.pop(true),
            child: const Text('Expédier'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _actionLoading = true);
    try {
      await ref
          .read(ordersNotifierProvider.notifier)
          .ship(widget.orderId, {});
      ref.invalidate(orderDetailProvider(widget.orderId));
      if (mounted) {
        context.showSnack('Commande expédiée', type: SnackType.success);
      }
    } catch (e) {
      if (mounted) context.showSnack(e.toString(), type: SnackType.error);
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final orderAsync = ref.watch(orderDetailProvider(widget.orderId));

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
          onRetry: () =>
              ref.invalidate(orderDetailProvider(widget.orderId)),
        ),
        data: (order) => ListView(
          padding: const EdgeInsets.all(AppSpacing.s16),
          children: [
            _buildInfoCard(context, order, isDark),
            const SizedBox(height: AppSpacing.s12),
            if (order.status != OrderStatus.cancelled)
              _buildProgressCard(context, order, isDark),
            if (order.status != OrderStatus.cancelled)
              const SizedBox(height: AppSpacing.s12),
            _buildItemsCard(context, order, isDark),
            const SizedBox(height: AppSpacing.s12),
            _buildSummaryCard(context, order, isDark),
            if (order.notes != null && order.notes!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.s12),
              _buildNotesCard(context, order, isDark),
            ],
            const SizedBox(height: AppSpacing.s32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, Order order, bool isDark) {
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
            'Reçue le ${fmt.format(order.createdAt)}',
            style: AppTextStyles.caption.copyWith(
              color: isDark ? AppColors.gray400 : AppColors.gray500,
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusMedium),
                ),
                child: Icon(
                  Symbols.storefront,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Grossiste',
                      style: AppTextStyles.caption.copyWith(
                        color: isDark
                            ? AppColors.gray400
                            : AppColors.gray500,
                      ),
                    ),
                    Text(
                      order.wholesalerName ?? 'Non spécifié',
                      style: AppTextStyles.label.copyWith(
                        fontWeight: FontWeight.w600,
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
          if (order.deliveryAddress != null &&
              order.deliveryAddress!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s12),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.gray100,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMedium),
                  ),
                  child: Icon(
                    Symbols.location_on,
                    size: 20,
                    color: isDark
                        ? AppColors.gray400
                        : AppColors.gray500,
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
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
          if (order.status == OrderStatus.created) ...[
            const SizedBox(height: AppSpacing.s16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        _actionLoading ? null : () => _reject(order),
                    icon: Icon(
                      Symbols.close,
                      size: 18,
                      color: AppColors.error,
                    ),
                    label: Text(
                      'Rejeter',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: AppColors.error.withValues(alpha: 0.5),
                      ),
                      minimumSize:
                          const Size.fromHeight(AppSpacing.touchTarget),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.s8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed:
                        _actionLoading ? null : () => _accept(order),
                    icon: _actionLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : Icon(Symbols.check_circle, size: 18),
                    label: const Text('Accepter'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.success,
                      minimumSize:
                          const Size.fromHeight(AppSpacing.touchTarget),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (order.status == OrderStatus.preparing) ...[
            const SizedBox(height: AppSpacing.s16),
            FilledButton.icon(
              onPressed: _actionLoading ? null : () => _ship(order),
              icon: _actionLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : Icon(Symbols.send, size: 18),
              label: const Text('Expédier la commande'),
              style: FilledButton.styleFrom(
                minimumSize:
                    const Size.fromHeight(AppSpacing.touchTarget),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressCard(
      BuildContext context, Order order, bool isDark) {
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

  Widget _buildItemsCard(BuildContext context, Order order, bool isDark) {
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
              margin:
                  const EdgeInsets.only(bottom: AppSpacing.s8),
              padding: const EdgeInsets.all(AppSpacing.s12),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurface2
                    : AppColors.gray50,
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusMedium),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
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
                        style: AppTextStyles.price
                            .copyWith(fontSize: 13),
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

  Widget _buildSummaryCard(BuildContext context, Order order, bool isDark) {
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
                _SummaryRow(
                  label: 'Sous-total',
                  value: '${fmt.format(order.totalAmount.toInt())} FCFA',
                  isDark: isDark,
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

  Widget _buildNotesCard(BuildContext context, Order order, bool isDark) {
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

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.isDark,
  });

  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: isDark ? AppColors.gray400 : AppColors.gray500,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.label.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.gray100 : AppColors.gray900,
          ),
        ),
      ],
    );
  }
}
