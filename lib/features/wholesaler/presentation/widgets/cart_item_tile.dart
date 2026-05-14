import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_spacing.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';
import 'package:banabana_b2b/features/wholesaler/providers/cart_providers.dart';

class CartItemTile extends ConsumerWidget {
  const CartItemTile({super.key, required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fmt = NumberFormat('#,###', 'fr_FR');
    final subtotal = item.unitPrice * item.quantity;

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productTitle,
                  style: AppTextStyles.label.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.gray100 : AppColors.gray900,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  item.variantLabel,
                  style: AppTextStyles.caption.copyWith(
                    color: isDark ? AppColors.gray500 : AppColors.gray500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.s6),
                Text(
                  '${fmt.format(item.unitPrice.toInt())} FCFA / unité',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => ref.read(cartProvider.notifier).remove(item.variantId),
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
                      onTap: () => ref
                          .read(cartProvider.notifier)
                          .updateQuantity(item.variantId, item.quantity - 1),
                    ),
                    SizedBox(
                      width: 32,
                      child: Text(
                        '${item.quantity}',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.label.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.white : AppColors.gray900,
                        ),
                      ),
                    ),
                    _StepperBtn(
                      icon: Symbols.add,
                      onTap: () => ref
                          .read(cartProvider.notifier)
                          .updateQuantity(item.variantId, item.quantity + 1),
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
  const _StepperBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 32,
        height: 32,
        child: Icon(
          icon,
          size: 16,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
