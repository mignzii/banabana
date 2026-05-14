# Cart & Checkout Flow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete the wholesaler cart→checkout flow by redesigning `CartItemTile` (currently a raw unstyled stub) to use the design system, and wiring up the "go to cart" snackbar action after add-to-cart on the product detail screen.

**Architecture:** The full flow (CartScreen, CheckoutScreen, ProductPublicDetailScreen with variant+quantity selector, `POST /v1/orders` API call) is already implemented. The only genuine gaps are: (1) `CartItemTile` doesn't use AppTextStyles/AppSpacing/AppColors and breaks in dark mode; (2) after adding to cart from the product detail screen, there's no quick shortcut to open the cart. All other flows are functional.

**Tech Stack:** Flutter 3.x, Riverpod (StateNotifierProvider), GoRouter, material_symbols_icons, intl (NumberFormat)

---

## File Map

| File | Action | Responsibility |
|------|--------|----------------|
| `lib/features/wholesaler/presentation/widgets/cart_item_tile.dart` | **Rewrite** | Per-item row in CartScreen: dark-mode, design system, subtotal, delete |
| `lib/features/wholesaler/presentation/screens/product_public_detail_screen.dart` | **Modify** | Snackbar action after add-to-cart to jump to `/shop/cart` |

---

## Task 1: Rewrite CartItemTile with design system, dark mode, subtotal and delete

**Files:**
- Rewrite: `lib/features/wholesaler/presentation/widgets/cart_item_tile.dart`

**Context:** `CartItemTile` receives a `CartItem` (fields: `variantId String`, `productId String`, `productTitle String`, `variantLabel String`, `unitPrice double`, `quantity int`). It is used in `CartScreen`'s `ListView.separated` with dark mode available from `Theme.of(context)`. The notifier is `ref.read(cartProvider.notifier)` — methods `updateQuantity(variantId, qty)` and `remove(variantId)`. Design tokens: `AppColors`, `AppTextStyles`, `AppSpacing`. Format numbers with `NumberFormat('#,###', 'fr_FR')` from `intl`.

- [ ] **Step 1: Rewrite the full file**

Replace `lib/features/wholesaler/presentation/widgets/cart_item_tile.dart` with:

```dart
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
          // Product info
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
          // Right side: delete, stepper, subtotal
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Delete button
              GestureDetector(
                onTap: () => ref.read(cartProvider.notifier).remove(item.variantId),
                child: Icon(
                  Symbols.delete_outline,
                  size: 18,
                  color: isDark ? AppColors.gray600 : AppColors.gray400,
                ),
              ),
              const SizedBox(height: AppSpacing.s10),
              // Quantity stepper
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
              // Subtotal
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
```

- [ ] **Step 2: Verify compile**

Run: `flutter analyze lib/features/wholesaler/presentation/widgets/cart_item_tile.dart`

Expected: no errors (only possible infos about underscores — those are fine).

- [ ] **Step 3: Commit**

```bash
git add lib/features/wholesaler/presentation/widgets/cart_item_tile.dart
git commit -m "feat: redesign CartItemTile — dark mode, design system, subtotal, delete"
```

---

## Task 2: Add "Voir le panier" action to snackbar after add-to-cart on product detail

**Files:**
- Modify: `lib/features/wholesaler/presentation/screens/product_public_detail_screen.dart` (lines ~33–44)

**Context:** `_addToCart` in `_ProductPublicDetailScreenState` currently calls `context.showSnack('Ajouté au panier ✓', type: SnackType.success)`. The `showSnack` extension is defined in `lib/shared/widgets/app_snack_bar.dart` and supports an optional `action` parameter of type `SnackBarAction?`. GoRouter is available via `context.push('/shop/cart')`.

- [ ] **Step 1: Check showSnack signature**

Read `lib/shared/widgets/app_snack_bar.dart` to confirm the `action` parameter name and type. Expected:

```dart
extension AppSnackBar on BuildContext {
  void showSnack(String message, {SnackType type = SnackType.info, SnackBarAction? action}) { ... }
```

If the signature differs from this, adapt the implementation in Step 2 accordingly.

- [ ] **Step 2: Add action to snackbar**

In `lib/features/wholesaler/presentation/screens/product_public_detail_screen.dart`, find the `_addToCart` method and replace the `showSnack` call:

**Before:**
```dart
  void _addToCart(Product product) {
    if (_selectedVariant == null) return;
    ref.read(cartProvider.notifier).add(
          variantId: _selectedVariant!.id,
          productId: product.id,
          productTitle: product.title,
          variantLabel: _selectedVariant!.label,
          unitPrice: _selectedVariant!.price,
          quantity: _quantity,
        );
    context.showSnack('Ajouté au panier ✓', type: SnackType.success);
  }
```

**After:**
```dart
  void _addToCart(Product product) {
    if (_selectedVariant == null) return;
    ref.read(cartProvider.notifier).add(
          variantId: _selectedVariant!.id,
          productId: product.id,
          productTitle: product.title,
          variantLabel: _selectedVariant!.label,
          unitPrice: _selectedVariant!.price,
          quantity: _quantity,
        );
    context.showSnack(
      'Ajouté au panier ✓',
      type: SnackType.success,
      action: SnackBarAction(
        label: 'Voir',
        textColor: AppColors.white,
        onPressed: () => context.push('/shop/cart'),
      ),
    );
  }
```

- [ ] **Step 3: Verify compile**

Run: `flutter analyze lib/features/wholesaler/presentation/screens/product_public_detail_screen.dart`

Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add lib/features/wholesaler/presentation/screens/product_public_detail_screen.dart
git commit -m "feat: add 'Voir le panier' action to add-to-cart snackbar"
```

---

## Task 3: Push all changes

- [ ] **Step 1: Push**

```bash
git push origin main
```

Expected: `main -> main` pushed successfully.
