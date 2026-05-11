import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/features/producer/providers/inventory_providers.dart';
import 'package:banabana_b2b/shared/models/inventory.dart';
import 'package:banabana_b2b/shared/widgets/app_snack_bar.dart';

class InventoryMovementSheet extends ConsumerStatefulWidget {
  final String variantId;
  final String variantLabel;

  const InventoryMovementSheet({
    super.key,
    required this.variantId,
    required this.variantLabel,
  });

  static void show(
    BuildContext context, {
    required String variantId,
    required String variantLabel,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => InventoryMovementSheet(
        variantId: variantId,
        variantLabel: variantLabel,
      ),
    );
  }

  @override
  ConsumerState<InventoryMovementSheet> createState() =>
      _InventoryMovementSheetState();
}

class _InventoryMovementSheetState
    extends ConsumerState<InventoryMovementSheet> {
  MovementType _type = MovementType.stockIn;
  final _qtyCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final qty = int.tryParse(_qtyCtrl.text.trim());
    if (qty == null || qty <= 0) {
      context.showSnack('Quantité invalide', type: SnackType.error);
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(inventoryNotifierProvider.notifier).recordMovement(
            variantId: widget.variantId,
            type: _type,
            quantity: qty,
            reason: _reasonCtrl.text.trim().isEmpty
                ? null
                : _reasonCtrl.text.trim(),
          );
      if (mounted) {
        context.showSnack('Mouvement enregistré', type: SnackType.success);
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
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Mouvement de stock — ${widget.variantLabel}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          InputDecorator(
            decoration: const InputDecoration(labelText: 'Type de mouvement'),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<MovementType>(
                value: _type,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(
                    value: MovementType.stockIn,
                    child: Text('Entrée'),
                  ),
                  DropdownMenuItem(
                    value: MovementType.stockOut,
                    child: Text('Sortie'),
                  ),
                  DropdownMenuItem(
                    value: MovementType.adjustment,
                    child: Text('Ajustement'),
                  ),
                  DropdownMenuItem(
                    value: MovementType.damage,
                    child: Text('Perte/Dommage'),
                  ),
                  DropdownMenuItem(
                    value: MovementType.stockReturn,
                    child: Text('Retour'),
                  ),
                ],
                onChanged: (v) => setState(() => _type = v!),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _qtyCtrl,
            decoration: const InputDecoration(labelText: 'Quantité *'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reasonCtrl,
            decoration:
                const InputDecoration(labelText: 'Raison (optionnel)'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
            ),
            child: _loading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}
