import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_spacing.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';
import 'package:banabana_b2b/features/wholesaler/providers/cart_providers.dart';
import 'package:banabana_b2b/features/wholesaler/providers/catalog_providers.dart';
import 'package:banabana_b2b/features/wholesaler/presentation/widgets/catalog_item_card.dart';
import 'package:banabana_b2b/shared/widgets/error_state_widget.dart';
import 'package:banabana_b2b/shared/widgets/hero_banner_carousel.dart';
import 'package:banabana_b2b/shared/widgets/loading_shimmer.dart';

class ShopHomeScreen extends ConsumerWidget {
  const ShopHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cartCount = ref.watch(cartItemCountProvider);
    final categoriesAsync = ref.watch(shopCategoriesProvider);
    final catalogAsync = ref.watch(catalogResultProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.gray50,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.white,
        elevation: 0,
        title: Text(
          'BanaBana',
          style: AppTextStyles.sectionTitle.copyWith(
            color: isDark ? AppColors.white : AppColors.gray900,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.s8),
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    Symbols.shopping_cart,
                    color: isDark ? AppColors.gray100 : AppColors.gray900,
                  ),
                  onPressed: () => context.go('/shop/cart'),
                ),
                if (cartCount > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        cartCount > 9 ? '9+' : '$cartCount',
                        style: AppTextStyles.badge.copyWith(fontSize: 9),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
        onRefresh: () async {
          ref.invalidate(shopCategoriesProvider);
          ref.invalidate(catalogResultProvider);
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
              child: HeroBannerCarousel(
                banners: [
                  BannerData(
                    badgeLabel: 'Nouveautés',
                    title: 'Achetez en gros,\néconomisez plus',
                    subtitle: 'Les meilleures offres producteurs',
                    ctaLabel: 'Explorer →',
                    gradientColors: [AppColors.primary, AppColors.primaryDark],
                    onTap: () => context.go('/shop/catalog'),
                  ),
                  BannerData(
                    badgeLabel: 'Offre spéciale',
                    title: 'Commandes groupées\ndisponibles',
                    subtitle: 'Livraison directe producteur',
                    ctaLabel: 'Voir les offres →',
                    gradientColors: [const Color(0xFF1A6B2E), const Color(0xFF0D3D1A)],
                    onTap: () => context.go('/shop/catalog'),
                  ),
                  BannerData(
                    badgeLabel: 'Tendance',
                    title: 'Produits frais\ndu jour',
                    subtitle: 'Qualité garantie, prix compétitifs',
                    ctaLabel: 'Découvrir →',
                    gradientColors: [const Color(0xFF7B3F00), const Color(0xFF4A2000)],
                    onTap: () => context.go('/shop/catalog'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            categoriesAsync.when(
              loading: () => SizedBox(
                height: 90,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                  scrollDirection: Axis.horizontal,
                  itemCount: 6,
                  separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.s8),
                  itemBuilder: (_, __) => const ShimmerBox(
                    width: 72,
                    height: 72,
                    borderRadius: AppSpacing.radiusLarge,
                  ),
                ),
              ),
              error: (_, __) => const SizedBox.shrink(),
              data: (categories) {
                if (categories.isEmpty) return const SizedBox.shrink();
                final displayed =
                    categories.length > 8 ? categories.sublist(0, 8) : categories;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s16),
                      child: Text(
                        'Catégories',
                        style: AppTextStyles.sectionTitle.copyWith(
                          color: isDark ? AppColors.white : AppColors.gray900,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    SizedBox(
                      height: 80,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s16),
                        scrollDirection: Axis.horizontal,
                        itemCount: displayed.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: AppSpacing.s8),
                        itemBuilder: (_, i) => _CategoryChip(
                          name: displayed[i],
                          isDark: isDark,
                          onTap: () {
                            ref
                                .read(catalogSearchParamsProvider.notifier)
                                .update((s) => s.copyWith(
                                    category: displayed[i], page: 1));
                            context.push('/shop/catalog');
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s24),
                  ],
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Produits vedette',
                    style: AppTextStyles.sectionTitle.copyWith(
                      color: isDark ? AppColors.white : AppColors.gray900,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/shop/catalog'),
                    child: Text(
                      'Voir tout',
                      style: AppTextStyles.label
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            catalogAsync.when(
              loading: () => GridView.builder(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s16),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.s12,
                  mainAxisSpacing: AppSpacing.s12,
                  childAspectRatio: 0.78,
                ),
                itemCount: 4,
                itemBuilder: (_, __) => const ProductCardShimmer(),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(AppSpacing.s16),
                child: ErrorStateWidget(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(catalogResultProvider),
                ),
              ),
              data: (result) {
                final items = result.data.length > 6
                    ? result.data.sublist(0, 6)
                    : result.data;
                if (items.isEmpty) return const SizedBox.shrink();
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s16),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.s12,
                    mainAxisSpacing: AppSpacing.s12,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: items.length,
                  itemBuilder: (_, i) => CatalogItemCard(
                    item: items[i],
                    onTap: () =>
                        context.push('/shop/product/${items[i].id}'),
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

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.name,
    required this.isDark,
    required this.onTap,
  });

  final String name;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        splashColor: AppColors.primary.withValues(alpha: 0.1),
        child: Ink(
          width: 72,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.gray200,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Symbols.category, size: 24, color: AppColors.primary),
              const SizedBox(height: AppSpacing.s4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
                child: Text(
                  name,
                  style: AppTextStyles.caption.copyWith(
                    color: isDark ? AppColors.gray300 : AppColors.gray600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
