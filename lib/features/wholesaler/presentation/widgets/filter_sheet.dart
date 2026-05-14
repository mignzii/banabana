import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_spacing.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';
import 'package:banabana_b2b/features/producer/providers/category_providers.dart';
import 'package:banabana_b2b/features/wholesaler/providers/catalog_providers.dart';
import 'package:banabana_b2b/shared/widgets/app_button.dart';

class FilterSheet extends ConsumerStatefulWidget {
  const FilterSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const FilterSheet(),
      );

  @override
  ConsumerState<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<FilterSheet> {
  late String? _category;
  late RangeValues _priceRange;
  late bool _inStockOnly;
  late String _sortBy;

  static const _sortOptions = [
    ('relevance', 'Pertinence'),
    ('price_asc', 'Prix croissant'),
    ('price_desc', 'Prix décroissant'),
    ('newest', 'Plus récents'),
  ];

  @override
  void initState() {
    super.initState();
    final params = ref.read(catalogSearchParamsProvider);
    _category = params.category;
    _priceRange = RangeValues(
      params.priceMin?.toDouble() ?? 0,
      params.priceMax?.toDouble() ?? 100000,
    );
    _inStockOnly = params.inStockOnly;
    _sortBy = params.sortBy ?? 'relevance';
  }

  void _apply() {
    ref.read(catalogSearchParamsProvider.notifier).update((s) => s.copyWith(
          category: _category,
          priceMin: _priceRange.start > 0 ? _priceRange.start : null,
          priceMax: _priceRange.end < 100000 ? _priceRange.end : null,
          inStockOnly: _inStockOnly,
          sortBy: _sortBy == 'relevance' ? null : _sortBy,
          page: 1,
        ));
    Navigator.pop(context);
  }

  void _reset() {
    setState(() {
      _category = null;
      _priceRange = const RangeValues(0, 100000);
      _inStockOnly = false;
      _sortBy = 'relevance';
    });
    ref.read(catalogSearchParamsProvider.notifier).update((s) => s.copyWith(
          category: null,
          priceMin: null,
          priceMax: null,
          inStockOnly: false,
          sortBy: null,
          page: 1,
        ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXL),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.s12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder2 : AppColors.gray200,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusPill),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s20,
                AppSpacing.s16,
                AppSpacing.s20,
                AppSpacing.s8,
              ),
              child: Row(
                children: [
                  Text(
                    'Filtres',
                    style: AppTextStyles.sectionTitle.copyWith(
                      color: isDark ? AppColors.white : AppColors.gray900,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _reset,
                    child: Text(
                      'Réinitialiser',
                      style: AppTextStyles.label
                          .copyWith(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.all(AppSpacing.s20),
                children: [
                  // ── Catégorie ──────────────────────────────────────
                  Consumer(
                    builder: (context, ref, _) {
                      final categoriesAsync = ref.watch(allCategoriesProvider);
                      return categoriesAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (cats) {
                          if (cats.isEmpty) return const SizedBox.shrink();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Catégorie',
                                style: AppTextStyles.label.copyWith(
                                  color: isDark
                                      ? AppColors.gray300
                                      : AppColors.gray700,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.s8),
                              Wrap(
                                spacing: AppSpacing.s8,
                                runSpacing: AppSpacing.s8,
                                children: [
                                  // "Toutes" chip
                                  GestureDetector(
                                    onTap: () =>
                                        setState(() => _category = null),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 150),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.s12,
                                          vertical: AppSpacing.s6),
                                      decoration: BoxDecoration(
                                        color: _category == null
                                            ? AppColors.primary
                                            : (isDark
                                                ? AppColors.darkBorder
                                                : AppColors.gray100),
                                        borderRadius: BorderRadius.circular(
                                            AppSpacing.radiusLarge),
                                      ),
                                      child: Text(
                                        'Toutes',
                                        style: AppTextStyles.caption.copyWith(
                                          color: _category == null
                                              ? AppColors.white
                                              : (isDark
                                                  ? AppColors.gray300
                                                  : AppColors.gray600),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  ...cats.map((cat) {
                                    final selected = _category == cat.name;
                                    return GestureDetector(
                                      onTap: () => setState(
                                          () => _category = cat.name),
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 150),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: AppSpacing.s12,
                                            vertical: AppSpacing.s6),
                                        decoration: BoxDecoration(
                                          color: selected
                                              ? AppColors.primary
                                              : (isDark
                                                  ? AppColors.darkBorder
                                                  : AppColors.gray100),
                                          borderRadius: BorderRadius.circular(
                                              AppSpacing.radiusLarge),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (cat.icon != null &&
                                                cat.icon!.isNotEmpty) ...[
                                              Text(cat.icon!,
                                                  style: const TextStyle(
                                                      fontSize: 14)),
                                              const SizedBox(width: 4),
                                            ],
                                            Text(
                                              cat.name,
                                              style: AppTextStyles.caption
                                                  .copyWith(
                                                color: selected
                                                    ? AppColors.white
                                                    : (isDark
                                                        ? AppColors.gray300
                                                        : AppColors.gray600),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.s20),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  Text(
                    'Fourchette de prix (FCFA)',
                    style: AppTextStyles.label.copyWith(
                      color: isDark ? AppColors.gray300 : AppColors.gray700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_priceRange.start.toInt()} F',
                        style: AppTextStyles.bodySecondary
                            .copyWith(color: AppColors.primary),
                      ),
                      Text(
                        '${_priceRange.end.toInt()} F',
                        style: AppTextStyles.bodySecondary
                            .copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: isDark
                          ? AppColors.darkBorder2
                          : AppColors.gray200,
                      thumbColor: AppColors.primary,
                      overlayColor:
                          AppColors.primary.withValues(alpha: 0.1),
                    ),
                    child: RangeSlider(
                      values: _priceRange,
                      min: 0,
                      max: 100000,
                      divisions: 100,
                      onChanged: (v) => setState(() => _priceRange = v),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'En stock uniquement',
                        style: AppTextStyles.label.copyWith(
                          color:
                              isDark ? AppColors.gray300 : AppColors.gray700,
                        ),
                      ),
                      Switch(
                        value: _inStockOnly,
                        onChanged: (v) => setState(() => _inStockOnly = v),
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s20),
                  Text(
                    'Trier par',
                    style: AppTextStyles.label.copyWith(
                      color: isDark ? AppColors.gray300 : AppColors.gray700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  ...List.generate(_sortOptions.length, (i) {
                    final (value, label) = _sortOptions[i];
                    return RadioListTile<String>(
                      value: value,
                      groupValue: _sortBy,
                      onChanged: (v) => setState(() => _sortBy = v!),
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        label,
                        style: AppTextStyles.body.copyWith(
                          color: isDark
                              ? AppColors.gray200
                              : AppColors.gray800,
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: AppSpacing.s32),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.s20,
                AppSpacing.s16,
                AppSpacing.s20,
                MediaQuery.of(context).padding.bottom + AppSpacing.s16,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.white,
                border: Border(
                  top: BorderSide(
                    color:
                        isDark ? AppColors.darkBorder : AppColors.gray200,
                  ),
                ),
              ),
              child: AppButton(
                label: 'Appliquer les filtres',
                onPressed: _apply,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
