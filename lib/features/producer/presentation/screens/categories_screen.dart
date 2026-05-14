import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_spacing.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';
import 'package:banabana_b2b/features/producer/providers/category_providers.dart';
import 'package:banabana_b2b/shared/models/category.dart';
import 'package:banabana_b2b/shared/widgets/app_snack_bar.dart';
import 'package:banabana_b2b/shared/widgets/empty_state_widget.dart';
import 'package:banabana_b2b/shared/widgets/error_state_widget.dart';
import 'package:banabana_b2b/shared/widgets/loading_shimmer.dart';

const _kIcons = ['🍎', '🥬', '🌾', '🥛', '🥩', '🐟', '🍞', '🧀', '🥚', '🫒', '🌶️', '🥕', '🍊', '🍇', '🥔', '📦', '🌽', '🥑', '🍅', '🧅'];

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final catsAsync = ref.watch(categoriesNotifierProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.gray50,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.white,
        elevation: 0,
        title: Text(
          'Mes catégories',
          style: AppTextStyles.sectionTitle.copyWith(
            color: isDark ? AppColors.white : AppColors.gray900,
          ),
        ),
        iconTheme: IconThemeData(
          color: isDark ? AppColors.white : AppColors.gray900,
        ),
        actions: [
          IconButton(
            icon: const Icon(Symbols.add_circle, size: 24),
            color: AppColors.primary,
            onPressed: () => _showCategorySheet(context, ref, isDark),
          ),
        ],
      ),
      body: catsAsync.when(
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.s16),
          itemCount: 5,
          itemBuilder: (_, __) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s8),
            child: ShimmerBox(height: 72),
          ),
        ),
        error: (e, _) => ErrorStateWidget(
          message: e.toString(),
          onRetry: () => ref.read(categoriesNotifierProvider.notifier).reload(),
        ),
        data: (cats) {
          if (cats.isEmpty) {
            return EmptyStateWidget(
              icon: Symbols.category,
              title: 'Aucune catégorie',
              subtitle: 'Créez vos catégories pour organiser vos produits.',
              ctaLabel: 'Créer une catégorie',
              onCta: () => _showCategorySheet(context, ref, isDark),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.s16),
            itemCount: cats.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s8),
            itemBuilder: (_, i) => _CategoryCard(
              category: cats[i],
              isDark: isDark,
              onEdit: () => _showCategorySheet(context, ref, isDark, editing: cats[i]),
              onDelete: () => _confirmDelete(context, ref, cats[i]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategorySheet(context, ref, isDark),
        backgroundColor: AppColors.primary,
        child: const Icon(Symbols.add, color: AppColors.white),
      ),
    );
  }

  Future<void> _showCategorySheet(
    BuildContext context,
    WidgetRef ref,
    bool isDark, {
    Category? editing,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _CategorySheet(
        isDark: isDark,
        editing: editing,
        onSave: (name, slug, icon, order) async {
          final notifier = ref.read(categoriesNotifierProvider.notifier);
          if (editing != null) {
            await notifier.edit(editing.id, name: name, slug: slug, icon: icon, order: order);
          } else {
            await notifier.create(name: name, slug: slug, icon: icon, order: order);
          }
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Category cat,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer la catégorie ?'),
        content: Text('« ${cat.name} » sera supprimée définitivement.'),
        actions: [
          TextButton(onPressed: () => ctx.pop(false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => ctx.pop(true),
            child: Text('Supprimer', style: AppTextStyles.label.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(categoriesNotifierProvider.notifier).delete(cat.id);
      if (context.mounted) context.showSnack('Catégorie supprimée', type: SnackType.info);
    } catch (e) {
      if (context.mounted) context.showSnack(e.toString(), type: SnackType.error);
    }
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
  });

  final Category category;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s12,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: isDark ? Border.all(color: AppColors.darkBorder) : null,
        boxShadow: isDark
            ? null
            : [BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            ),
            child: Center(
              child: Text(
                category.icon ?? '📦',
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: AppTextStyles.label.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.gray100 : AppColors.gray900,
                  ),
                ),
                if (category.slug != null && category.slug!.isNotEmpty)
                  Text(
                    '/${category.slug}',
                    style: AppTextStyles.caption.copyWith(
                      color: isDark ? AppColors.gray500 : AppColors.gray400,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Symbols.edit, size: 18,
                color: isDark ? AppColors.gray400 : AppColors.gray500),
            onPressed: onEdit,
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            icon: Icon(Symbols.delete, size: 18, color: AppColors.error.withValues(alpha: 0.7)),
            onPressed: onDelete,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _CategorySheet extends ConsumerStatefulWidget {
  const _CategorySheet({
    required this.isDark,
    required this.onSave,
    this.editing,
  });

  final bool isDark;
  final Category? editing;
  final Future<void> Function(String name, String slug, String icon, int order) onSave;

  @override
  ConsumerState<_CategorySheet> createState() => _CategorySheetState();
}

class _CategorySheetState extends ConsumerState<_CategorySheet> {
  final _nameCtrl = TextEditingController();
  final _slugCtrl = TextEditingController();
  final _orderCtrl = TextEditingController();
  String _selectedIcon = '📦';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.editing != null) {
      _nameCtrl.text = widget.editing!.name;
      _slugCtrl.text = widget.editing!.slug ?? '';
      _orderCtrl.text = (widget.editing!.order ?? 0).toString();
      _selectedIcon = widget.editing!.icon ?? '📦';
    } else {
      _orderCtrl.text = '0';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _slugCtrl.dispose();
    _orderCtrl.dispose();
    super.dispose();
  }

  String _toSlug(String name) => name
      .toLowerCase()
      .replaceAll(RegExp(r'[àáâãäå]'), 'a')
      .replaceAll(RegExp(r'[èéêë]'), 'e')
      .replaceAll(RegExp(r'[ìíîï]'), 'i')
      .replaceAll(RegExp(r'[òóôõö]'), 'o')
      .replaceAll(RegExp(r'[ùúûü]'), 'u')
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final slug = _slugCtrl.text.trim();
    if (name.isEmpty || slug.isEmpty) {
      context.showSnack('Nom et slug requis', type: SnackType.error);
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.onSave(
        name,
        slug,
        _selectedIcon,
        int.tryParse(_orderCtrl.text) ?? 0,
      );
      if (mounted) {
        context.showSnack(
          widget.editing != null ? 'Catégorie mise à jour' : 'Catégorie créée',
          type: SnackType.success,
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        context.showSnack(e.toString(), type: SnackType.error);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final surface = widget.isDark ? AppColors.darkSurface : AppColors.white;
    final border = widget.isDark ? AppColors.darkBorder : AppColors.gray200;
    final textPrimary = widget.isDark ? AppColors.gray100 : AppColors.gray900;
    final textSecondary = widget.isDark ? AppColors.gray400 : AppColors.gray500;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.s12),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        ),
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            Text(
              widget.editing != null ? 'Modifier la catégorie' : 'Nouvelle catégorie',
              style: AppTextStyles.sectionTitle.copyWith(color: textPrimary),
            ),
            const SizedBox(height: AppSpacing.s20),

            Text('Icône', style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600, color: textSecondary,
            )),
            const SizedBox(height: AppSpacing.s8),
            SizedBox(
              height: 52,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _kIcons.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.s8),
                itemBuilder: (_, i) {
                  final icon = _kIcons[i];
                  final selected = _selectedIcon == icon;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = icon),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : (widget.isDark ? AppColors.darkSurface2 : AppColors.gray100),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                        border: selected
                            ? Border.all(color: AppColors.primary, width: 2)
                            : Border.all(color: Colors.transparent),
                      ),
                      child: Center(child: Text(icon, style: const TextStyle(fontSize: 22))),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.s16),

            Text('Nom *', style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600, color: textSecondary,
            )),
            const SizedBox(height: AppSpacing.s6),
            TextFormField(
              controller: _nameCtrl,
              style: AppTextStyles.body.copyWith(color: textPrimary),
              onChanged: (v) {
                if (widget.editing == null) {
                  _slugCtrl.text = _toSlug(v);
                }
              },
              decoration: _inputDec('Ex: Fruits & Légumes', widget.isDark, border),
            ),
            const SizedBox(height: AppSpacing.s12),

            Text('Slug *', style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600, color: textSecondary,
            )),
            const SizedBox(height: AppSpacing.s6),
            TextFormField(
              controller: _slugCtrl,
              style: AppTextStyles.body.copyWith(color: textPrimary),
              decoration: _inputDec('fruits-legumes', widget.isDark, border),
            ),
            const SizedBox(height: AppSpacing.s24),

            FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(AppSpacing.touchTarget),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                    )
                  : Text(
                      widget.editing != null ? 'Mettre à jour' : 'Créer',
                      style: AppTextStyles.button,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDec(String hint, bool isDark, Color border) => InputDecoration(
    hintText: hint,
    hintStyle: AppTextStyles.bodySecondary.copyWith(
      color: isDark ? AppColors.gray600 : AppColors.gray400,
    ),
    filled: true,
    fillColor: isDark ? AppColors.darkSurface2 : AppColors.gray50,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.s14,
      vertical: AppSpacing.s12,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      borderSide: BorderSide(color: border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      borderSide: BorderSide(color: border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
  );
}
