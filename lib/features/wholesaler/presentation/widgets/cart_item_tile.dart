import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_spacing.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';
import 'package:banabana_b2b/features/wholesaler/providers/cart_providers.dart';

class CartItemTile extends ConsumerStatefulWidget {
  const CartItemTile({super.key, required this.item});

  final CartItem item;

  @override
  ConsumerState<CartItemTile> createState() => _CartItemTileState();
}

class _CartItemTileState extends ConsumerState<CartItemTile> {
  late final TextEditingController _ctrl;
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: '${widget.item.quantity}');
    _focus = FocusNode();
    _focus.addListener(() {
      if (!_focus.hasFocus) _commit();
    });
  }

  @override
  void didUpdateWidget(CartItemTile old) {
    super.didUpdateWidget(old);
    if (old.item.quantity != widget.item.quantity && !_focus.hasFocus) {
      _ctrl.text = '${widget.item.quantity}';
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _commit() {
    final parsed = int.tryParse(_ctrl.text.trim());
    final min = widget.item.minOrderQuantity;
    if (parsed == null || parsed < min) {
      _ctrl.text = '${widget.item.quantity}';
      return;
    }
    ref.read(cartProvider.notifier).updateQuantity(widget.item.variantId, parsed);
  }

  void _decrement() {
    final min = widget.item.minOrderQuantity;
    final next = widget.item.quantity - 1;
    if (next < min) return;
    ref.read(cartProvider.notifier).updateQuantity(widget.item.variantId, next);
    _ctrl.text = '$next';
  }

  void _increment() {
    final next = widget.item.quantity + 1;
    ref.read(cartProvider.notifier).updateQuantity(widget.item.variantId, next);
    _ctrl.text = '$next';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fmt = NumberFormat('#,###', 'fr_FR');
    final subtotal = widget.item.unitPrice * widget.item.quantity;
    final min = widget.item.minOrderQuantity;
    final atMin = widget.item.quantity <= min;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: isDark ? Border.all(color: AppColors.darkBorder) : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Info ────────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item.productTitle,
                  style: AppTextStyles.label.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.gray100 : AppColors.gray900,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  widget.item.variantLabel,
                  style: AppTextStyles.caption.copyWith(color: AppColors.gray500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.s6),
                Text(
                  '${fmt.format(widget.item.unitPrice.toInt())} FCFA / unité',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (min > 1) ...[
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    'Min. $min unité${min > 1 ? 's' : ''}',
                    style: AppTextStyles.caption.copyWith(
                      color: isDark ? AppColors.gray500 : AppColors.gray400,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          // ── Controls ────────────────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => ref.read(cartProvider.notifier).remove(widget.item.variantId),
                child: Icon(
                  Symbols.delete_outline,
                  size: 18,
                  color: isDark ? AppColors.gray600 : AppColors.gray400,
                ),
              ),
              const SizedBox(height: AppSpacing.s10),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface2 : AppColors.gray50,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.gray200,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _StepperBtn(
                      icon: Symbols.remove,
                      enabled: !atMin,
                      onTap: _decrement,
                    ),
                    // Editable quantity field
                    SizedBox(
                      width: 44,
                      height: 32,
                      child: Center(
                        child: TextField(
                          controller: _ctrl,
                          focusNode: _focus,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          onSubmitted: (_) => _commit(),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: AppTextStyles.label.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: isDark ? AppColors.white : AppColors.gray900,
                          ),
                        ),
                      ),
                    ),
                    _StepperBtn(
                      icon: Symbols.add,
                      enabled: true,
                      onTap: _increment,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                '${fmt.format(subtotal.toInt())} F',
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.white : AppColors.gray900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepperBtn extends StatelessWidget {
  const _StepperBtn({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 32,
        height: 32,
        child: Icon(
          icon,
          size: 16,
          color: enabled ? AppColors.primary : AppColors.gray300,
        ),
      ),
    );
  }
}
