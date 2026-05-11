import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_spacing.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';
import 'package:banabana_b2b/features/auth/providers/auth_provider.dart';
import 'package:banabana_b2b/features/producer/providers/product_providers.dart';
import 'package:banabana_b2b/features/producer/providers/order_providers.dart';
import 'package:banabana_b2b/shared/widgets/product_card.dart';
import 'package:banabana_b2b/shared/widgets/loading_shimmer.dart';

class ProducerHomeScreen extends ConsumerWidget {
  const ProducerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;
    final productsAsync = ref.watch(productsNotifierProvider);
    final ordersAsync = ref.watch(ordersNotifierProvider);

    final firstName = user?.firstName ?? 'Producteur';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.gray50,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bonjour, $firstName 👋',
              style: AppTextStyles.sectionTitle.copyWith(
                color: isDark ? AppColors.white : AppColors.gray900,
              ),
            ),
            Text(
              'Tableau de bord producteur',
              style: AppTextStyles.caption.copyWith(
                color: isDark ? AppColors.gray500 : AppColors.gray400,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.s8),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              child: Text(
                firstName.isNotEmpty ? firstName[0].toUpperCase() : 'P',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(productsNotifierProvider);
          ref.invalidate(ordersNotifierProvider);
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
          children: [
            _QuickStats(
              isDark: isDark,
              ordersAsync: ordersAsync,
              productsAsync: productsAsync,
            ),
            const SizedBox(height: AppSpacing.s24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
              child: Text(
                'Actions rapides',
                style: AppTextStyles.sectionTitle.copyWith(
                  color: isDark ? AppColors.white : AppColors.gray900,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.s12,
                crossAxisSpacing: AppSpacing.s12,
                childAspectRatio: 2.4,
                children: [
                  _QuickAction(
                    icon: Symbols.add_circle,
                    label: 'Ajouter produit',
                    color: AppColors.primary,
                    isDark: isDark,
                    onTap: () => context.push('/producer/products/new'),
                  ),
                  _QuickAction(
                    icon: Symbols.receipt_long,
                    label: 'Commandes',
                    color: const Color(0xFF7C3AED),
                    isDark: isDark,
                    onTap: () => context.go('/producer/orders'),
                  ),
                  _QuickAction(
                    icon: Symbols.inventory_2,
                    label: 'Inventaire',
                    color: const Color(0xFF0EA5E9),
                    isDark: isDark,
                    onTap: () => context.push('/producer/inventory'),
                  ),
                  _QuickAction(
                    icon: Symbols.bar_chart,
                    label: 'Analytiques',
                    color: AppColors.secondary,
                    isDark: isDark,
                    onTap: () => context.push('/producer/analytics'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mes produits',
                    style: AppTextStyles.sectionTitle.copyWith(
                      color: isDark ? AppColors.white : AppColors.gray900,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/producer/products'),
                    child: Text(
                      'Voir tout',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            productsAsync.when(
              loading: () => SizedBox(
                height: 200,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s16,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: AppSpacing.s12),
                  itemBuilder: (_, __) => const SizedBox(
                    width: 150,
                    child: ProductCardShimmer(),
                  ),
                ),
              ),
              error: (_, __) => const SizedBox.shrink(),
              data: (products) {
                if (products.isEmpty) return const SizedBox.shrink();
                final recent =
                    products.length > 6 ? products.sublist(0, 6) : products;
                return SizedBox(
                  height: 210,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s16,
                    ),
                    scrollDirection: Axis.horizontal,
                    itemCount: recent.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppSpacing.s12),
                    itemBuilder: (_, i) => SizedBox(
                      width: 150,
                      child: ProductCard(
                        product: recent[i],
                        onTap: () =>
                            context.push('/producer/products/${recent[i].id}'),
                        onEdit: () => context
                            .push('/producer/products/${recent[i].id}/edit'),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.s32),
          ],
        ),
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  const _QuickStats({
    required this.isDark,
    required this.ordersAsync,
    required this.productsAsync,
  });

  final bool isDark;
  final AsyncValue<List> ordersAsync;
  final AsyncValue<List> productsAsync;

  @override
  Widget build(BuildContext context) {
    final pendingOrders =
        ordersAsync.valueOrNull?.length ?? 0;
    final totalProducts = productsAsync.valueOrNull?.length ?? 0;

    return SizedBox(
      height: 88,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
        scrollDirection: Axis.horizontal,
        children: [
          _StatChip(
            icon: Symbols.shopping_bag,
            label: 'Commandes',
            value: '$pendingOrders',
            color: AppColors.primary,
            isDark: isDark,
          ),
          const SizedBox(width: AppSpacing.s12),
          _StatChip(
            icon: Symbols.inventory_2,
            label: 'Produits',
            value: '$totalProducts',
            color: const Color(0xFF0EA5E9),
            isDark: isDark,
          ),
          const SizedBox(width: AppSpacing.s12),
          _StatChip(
            icon: Symbols.star,
            label: 'Note',
            value: '4.8',
            color: AppColors.secondary,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: isDark ? Border.all(color: AppColors.darkBorder) : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: AppSpacing.s8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: AppTextStyles.sectionTitle.copyWith(
                  fontSize: 18,
                  color: isDark ? AppColors.white : AppColors.gray900,
                ),
              ),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: isDark ? AppColors.gray500 : AppColors.gray400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        splashColor: color.withValues(alpha: 0.1),
        child: Ink(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            border: isDark ? Border.all(color: AppColors.darkBorder) : null,
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                    ),
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s12,
              vertical: AppSpacing.s8,
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusSmall),
                  ),
                  child: Icon(icon, size: 16, color: color),
                ),
                const SizedBox(width: AppSpacing.s8),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.label.copyWith(
                      color: isDark ? AppColors.gray200 : AppColors.gray800,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
