import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_spacing.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';
import 'package:banabana_b2b/features/wholesaler/providers/catalog_providers.dart';
import 'package:banabana_b2b/features/wholesaler/presentation/widgets/catalog_item_card.dart';
import 'package:banabana_b2b/shared/widgets/loading_shimmer.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, this.initialQuery});
  final String? initialQuery;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _ctrl.text = widget.initialQuery!;
      _query = widget.initialQuery!;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _query = v.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resultAsync = ref.watch(catalogSearchProvider(_query));

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.gray50,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back),
          color: isDark ? AppColors.gray100 : AppColors.gray900,
          onPressed: () => context.pop(),
        ),
        title: Container(
          height: 40,
          margin: const EdgeInsets.only(right: AppSpacing.s16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface2 : AppColors.gray100,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          ),
          child: TextField(
            controller: _ctrl,
            autofocus: true,
            style: AppTextStyles.body.copyWith(
              color: isDark ? AppColors.gray100 : AppColors.gray900,
              height: 1.0,
            ),
            decoration: InputDecoration(
              hintText: 'Rechercher un produit...',
              hintStyle: AppTextStyles.bodySecondary.copyWith(
                color: isDark ? AppColors.gray600 : AppColors.gray400,
              ),
              prefixIcon: Icon(
                Symbols.search,
                color: AppColors.primary,
                size: 20,
              ),
              suffixIcon: _ctrl.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Symbols.close,
                        size: 18,
                        color: isDark ? AppColors.gray400 : AppColors.gray500,
                      ),
                      onPressed: () {
                        _ctrl.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: AppSpacing.s10),
              isDense: true,
            ),
            onChanged: _onChanged,
            textInputAction: TextInputAction.search,
          ),
        ),
      ),
      body: _query.isEmpty
          ? _EmptyPrompt(isDark: isDark)
          : resultAsync.when(
              loading: () => GridView.builder(
                padding: const EdgeInsets.all(AppSpacing.s16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.s12,
                  mainAxisSpacing: AppSpacing.s12,
                  childAspectRatio: 0.78,
                ),
                itemCount: 6,
                itemBuilder: (_, __) => const ProductCardShimmer(),
              ),
              error: (e, _) => Center(
                child: Text(
                  e.toString(),
                  style: AppTextStyles.body.copyWith(
                    color: isDark ? AppColors.gray400 : AppColors.gray500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              data: (result) {
                if (result.data.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Symbols.search_off,
                          size: 64,
                          color:
                              isDark ? AppColors.gray600 : AppColors.gray300,
                        ),
                        const SizedBox(height: AppSpacing.s16),
                        Text(
                          'Aucun résultat pour « $_query »',
                          style: AppTextStyles.label.copyWith(
                            color:
                                isDark ? AppColors.gray400 : AppColors.gray500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.s8),
                        Text(
                          'Essayez avec d\'autres mots-clés.',
                          style: AppTextStyles.caption.copyWith(
                            color:
                                isDark ? AppColors.gray600 : AppColors.gray400,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.s16,
                        AppSpacing.s12,
                        AppSpacing.s16,
                        AppSpacing.s4,
                      ),
                      child: Text(
                        '${result.pagination.total} résultat${result.pagination.total > 1 ? 's' : ''} pour « $_query »',
                        style: AppTextStyles.caption.copyWith(
                          color:
                              isDark ? AppColors.gray400 : AppColors.gray500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(AppSpacing.s16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: AppSpacing.s12,
                          mainAxisSpacing: AppSpacing.s12,
                          childAspectRatio: 0.78,
                        ),
                        itemCount: result.data.length,
                        itemBuilder: (_, i) => CatalogItemCard(
                          item: result.data[i],
                          onTap: () => context
                              .push('/shop/product/${result.data[i].id}'),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class _EmptyPrompt extends StatelessWidget {
  const _EmptyPrompt({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Symbols.search,
            size: 72,
            color: isDark ? AppColors.gray700 : AppColors.gray200,
          ),
          const SizedBox(height: AppSpacing.s16),
          Text(
            'Rechercher des produits',
            style: AppTextStyles.sectionTitle.copyWith(
              color: isDark ? AppColors.gray400 : AppColors.gray500,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            'Entrez un nom de produit ou un producteur.',
            style: AppTextStyles.caption.copyWith(
              color: isDark ? AppColors.gray600 : AppColors.gray400,
            ),
          ),
        ],
      ),
    );
  }
}
