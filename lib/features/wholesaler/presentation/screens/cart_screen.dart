import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_spacing.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';
import 'package:banabana_b2b/features/wholesaler/providers/cart_providers.dart';
import 'package:banabana_b2b/features/wholesaler/providers/wholesaler_order_providers.dart';
import 'package:banabana_b2b/features/wholesaler/presentation/widgets/cart_item_tile.dart';
import 'package:banabana_b2b/shared/widgets/app_button.dart';
import 'package:banabana_b2b/shared/widgets/empty_state_widget.dart';
import 'package:intl/intl.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cartItems = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);
    final fmt = NumberFormat('#,###', 'fr_FR');

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.gray50,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.white,
        title: Text(
          'Mon panier',
          style: AppTextStyles.sectionTitle.copyWith(
            color: isDark ? AppColors.white : AppColors.gray900,
          ),
        ),
        elevation: 0,
        actions: [
          if (cartItems.isNotEmpty)
            TextButton(
              onPressed: () => _confirmClear(context, ref),
              child: Text(
                'Vider',
                style: AppTextStyles.label.copyWith(color: AppColors.error),
              ),
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? EmptyStateWidget(
              icon: Symbols.shopping_cart,
              title: 'Votre panier est vide',
              subtitle: 'Ajoutez des produits depuis le catalogue.',
              ctaLabel: 'Explorer le catalogue',
              onCta: () => context.go('/shop/catalog'),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s16,
                      vertical: AppSpacing.s12,
                    ),
                    itemCount: cartItems.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.s8),
                    itemBuilder: (_, i) => CartItemTile(item: cartItems[i]),
                  ),
                ),
                _CheckoutBar(
                  total: total,
                  fmt: fmt,
                  isDark: isDark,
                ),
              ],
            ),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Vider le panier ?'),
        content: const Text('Tous les articles seront supprimés.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Vider',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirm == true) ref.read(cartProvider.notifier).clear();
  }
}

class _CheckoutBar extends ConsumerStatefulWidget {
  const _CheckoutBar({
    required this.total,
    required this.fmt,
    required this.isDark,
  });

  final double total;
  final NumberFormat fmt;
  final bool isDark;

  @override
  ConsumerState<_CheckoutBar> createState() => _CheckoutBarState();
}

class _CheckoutBarState extends ConsumerState<_CheckoutBar> {
  bool _loading = false;

  Future<void> _placeOrder() async {
    final cartItems = ref.read(cartProvider);
    if (cartItems.isEmpty) return;
    setState(() => _loading = true);
    try {
      final items = cartItems
          .map((i) => {'variantId': i.variantId, 'quantity': i.quantity})
          .toList();
      final order = await ref
          .read(wholesalerOrdersProvider.notifier)
          .placeOrder(items);
      ref.read(cartProvider.notifier).clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Commande passée !'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pushReplacement('/shop/orders/${order.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s16,
        AppSpacing.s16,
        MediaQuery.of(context).padding.bottom + AppSpacing.s16,
      ),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.gray900 : AppColors.white,
        border: Border(
          top: BorderSide(
            color:
                widget.isDark ? AppColors.darkBorder : AppColors.gray200,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black
                .withValues(alpha: widget.isDark ? 0.4 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: AppTextStyles.label.copyWith(
                  color: widget.isDark
                      ? AppColors.gray300
                      : AppColors.gray600,
                ),
              ),
              Text(
                '${widget.fmt.format(widget.total)} FCFA',
                style: AppTextStyles.sectionTitle.copyWith(
                  color: widget.isDark
                      ? AppColors.white
                      : AppColors.gray900,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          AppButton(
            label: 'Commander — ${widget.fmt.format(widget.total)} F',
            onPressed: _loading ? null : _placeOrder,
            isLoading: _loading,
          ),
        ],
      ),
    );
  }
}
