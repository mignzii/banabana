import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/features/producer/providers/order_providers.dart';
import 'package:banabana_b2b/shared/models/order.dart';
import 'package:banabana_b2b/shared/widgets/app_snack_bar.dart';

class OrderActionsSheet extends ConsumerStatefulWidget {
  final Order order;

  const OrderActionsSheet({super.key, required this.order});

  static void show(BuildContext context, {required Order order}) {
    showModalBottomSheet(
      context: context,
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
        Navigator.pop(context);
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
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, reasonCtrl.text.trim()),
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
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) context.showSnack(e.toString(), type: SnackType.error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canAccept = widget.order.status == OrderStatus.created;
    final canReject = widget.order.status == OrderStatus.created;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.gray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Actions — #${widget.order.id.substring(0, 8).toUpperCase()}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          if (canAccept)
            ElevatedButton.icon(
              onPressed: _loading ? null : _accept,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Accepter la commande'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          if (canReject) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _loading ? null : _reject,
              icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
              label: const Text(
                'Refuser',
                style: TextStyle(color: AppColors.error),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
