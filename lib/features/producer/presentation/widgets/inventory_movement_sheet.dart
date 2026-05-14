import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_spacing.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';
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
      backgroundColor: Colors.transparent,
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

  static const _types = [
    (value: MovementType.stockIn, label: 'Entrée en stock', icon: Symbols.arrow_downward),
    (value: MovementType.stockOut, label: 'Sortie de stock', icon: Symbols.arrow_upward),
    (value: MovementType.adjustment, label: 'Ajustement inventaire', icon: Symbols.swap_horiz),
    (value: MovementType.damage, label: 'Perte / Dommage', icon: Symbols.broken_image),
    (value: MovementType.stockReturn, label: 'Retour produit', icon: Symbols.undo),
  ];

  Color _typeColor(MovementType t) {
    switch (t) {
      case MovementType.stockIn:
        return AppColors.success;
      case MovementType.stockOut:
        return AppColors.error;
      case MovementType.adjustment:
        return AppColors.warning;
      case MovementType.damage:
        return AppColors.error;
      case MovementType.stockReturn:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.white;
    final textPrimary = isDark ? AppColors.gray100 : AppColors.gray900;
    final border = isDark ? AppColors.darkBorder : AppColors.gray200;
    final selectedColor = _typeColor(_type);

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s20,
        AppSpacing.s16,
        AppSpacing.s20,
        MediaQuery.of(context).viewInsets.bottom + AppSpacing.s24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.gray600 : AppColors.gray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s16),

          // Title
          Text(
            'Mouvement de stock',
            style: AppTextStyles.sectionTitle
                .copyWith(color: textPrimary, fontSize: 17),
          ),
          const SizedBox(height: 2),
          Text(
            widget.variantLabel,
            style: AppTextStyles.caption.copyWith(color: AppColors.gray500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.s16),

          // Type chips
          Text(
            'Type de mouvement',
            style: AppTextStyles.label.copyWith(
                color: textPrimary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.s8),
          Wrap(
            spacing: AppSpacing.s8,
            runSpacing: AppSpacing.s8,
            children: _types.map((t) {
              final selected = _type == t.value;
              final color = _typeColor(t.value);
              return GestureDetector(
                onTap: () => setState(() => _type = t.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s10, vertical: AppSpacing.s6),
                  decoration: BoxDecoration(
                    color: selected
                        ? color.withValues(alpha: 0.12)
                        : (isDark ? AppColors.darkBorder : AppColors.gray100),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusLarge),
                    border: Border.all(
                      color: selected
                          ? color
                          : (isDark
                              ? AppColors.darkBorder
                              : AppColors.gray200),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(t.icon,
                          size: 14,
                          color: selected
                              ? color
                              : (isDark
                                  ? AppColors.gray400
                                  : AppColors.gray500)),
                      const SizedBox(width: 4),
                      Text(
                        t.label,
                        style: AppTextStyles.caption.copyWith(
                          color: selected
                              ? color
                              : (isDark
                                  ? AppColors.gray400
                                  : AppColors.gray600),
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.s16),

          // Quantity
          Text(
            'Quantité *',
            style: AppTextStyles.label.copyWith(
                color: textPrimary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.s6),
          TextField(
            controller: _qtyCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: AppTextStyles.body.copyWith(color: textPrimary),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: AppTextStyles.caption.copyWith(
                  color: isDark ? AppColors.gray500 : AppColors.gray400),
              filled: true,
              fillColor: isDark ? AppColors.darkBorder : AppColors.gray50,
              enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusLarge),
                borderSide: BorderSide(color: border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusLarge),
                borderSide:
                    BorderSide(color: selectedColor, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.s12, horizontal: AppSpacing.s14),
            ),
          ),
          const SizedBox(height: AppSpacing.s12),

          // Reason
          Text(
            'Raison (optionnel)',
            style: AppTextStyles.label.copyWith(
                color: textPrimary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.s6),
          TextField(
            controller: _reasonCtrl,
            style: AppTextStyles.body.copyWith(color: textPrimary),
            decoration: InputDecoration(
              hintText: 'Ex: Inventaire, Livraison fournisseur...',
              hintStyle: AppTextStyles.caption.copyWith(
                  color: isDark ? AppColors.gray500 : AppColors.gray400),
              filled: true,
              fillColor: isDark ? AppColors.darkBorder : AppColors.gray50,
              enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusLarge),
                borderSide: BorderSide(color: border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusLarge),
                borderSide:
                    BorderSide(color: selectedColor, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.s12, horizontal: AppSpacing.s14),
            ),
          ),
          const SizedBox(height: AppSpacing.s20),

          // Submit button
          FilledButton.icon(
            onPressed: _loading ? null : _submit,
            icon: _loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.white),
                  )
                : Icon(
                    _type == MovementType.stockIn
                        ? Symbols.add_circle
                        : _type == MovementType.stockOut
                            ? Symbols.remove_circle
                            : Symbols.swap_horiz,
                    size: 18,
                  ),
            label: Text(_loading ? 'Enregistrement...' : 'Enregistrer'),
            style: FilledButton.styleFrom(
              backgroundColor: selectedColor,
              foregroundColor: AppColors.white,
              minimumSize: const Size.fromHeight(AppSpacing.touchTarget),
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusLarge)),
            ),
          ),
        ],
      ),
    );
  }
}
