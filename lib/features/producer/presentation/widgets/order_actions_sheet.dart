import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_spacing.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';
import 'package:banabana_b2b/features/producer/providers/order_providers.dart';
import 'package:banabana_b2b/shared/models/order.dart';
import 'package:banabana_b2b/shared/widgets/app_snack_bar.dart';

class OrderActionsSheet extends ConsumerStatefulWidget {
  final Order order;

  const OrderActionsSheet({super.key, required this.order});

  static void show(BuildContext context, {required Order order}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => OrderActionsSheet(order: order),
    );
  }

  @override
  ConsumerState<OrderActionsSheet> createState() =>
      _OrderActionsSheetState();
}

class _OrderActionsSheetState extends ConsumerState<OrderActionsSheet> {
  bool _loading = false;

  Future<void> _accept() async {
    setState(() => _loading = true);
    try {
      await ref
          .read(ordersNotifierProvider.notifier)
          .accept(widget.order.id);
      if (mounted) {
        context.showSnack('Commande acceptée', type: SnackType.success);
        context.pop();
      }
    } catch (e) {
      if (mounted) context.showSnack(e.toString(), type: SnackType.error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _reject() async {
    final reasonCtrl = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Motif du refus'),
        content: TextField(
          controller: reasonCtrl,
          decoration: const InputDecoration(hintText: 'Raison...'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => ctx.pop(reasonCtrl.text.trim()),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
    if (reason == null || reason.isEmpty) return;
    setState(() => _loading = true);
    try {
      await ref
          .read(ordersNotifierProvider.notifier)
          .reject(widget.order.id, reason);
      if (mounted) {
        context.showSnack('Commande refusée', type: SnackType.info);
        context.pop();
      }
    } catch (e) {
      if (mounted) context.showSnack(e.toString(), type: SnackType.error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canAccept = widget.order.status == OrderStatus.created;
    final canReject = widget.order.status == OrderStatus.created;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
      ),
      padding: const EdgeInsets.all(AppSpacing.s24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBorder2 : AppColors.gray200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          Text(
            'Actions — #${widget.order.id.substring(0, 8).toUpperCase()}',
            style: AppTextStyles.sectionTitle.copyWith(
              color: isDark ? AppColors.white : AppColors.gray900,
            ),
          ),
          const SizedBox(height: AppSpacing.s20),
          if (canAccept)
            FilledButton.icon(
              onPressed: _loading ? null : _accept,
              icon: Icon(Symbols.check_circle, size: 18),
              label: const Text('Accepter la commande'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.success,
                minimumSize: const Size.fromHeight(AppSpacing.touchTarget),
              ),
            ),
          if (canReject) ...[
            const SizedBox(height: AppSpacing.s12),
            OutlinedButton.icon(
              onPressed: _loading ? null : _reject,
              icon: Icon(Symbols.cancel, size: 18, color: AppColors.error),
              label: Text(
                'Refuser',
                style: AppTextStyles.label.copyWith(color: AppColors.error),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                minimumSize: const Size.fromHeight(AppSpacing.touchTarget),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.s8),
        ],
      ),
    );
  }
}
