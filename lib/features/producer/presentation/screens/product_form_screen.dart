import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:banabana_b2b/core/api/api_client.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_spacing.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';
import 'package:banabana_b2b/features/producer/providers/product_providers.dart';
import 'package:banabana_b2b/features/producer/providers/category_providers.dart';
import 'package:banabana_b2b/features/producer/presentation/widgets/image_picker_sheet.dart';
import 'package:banabana_b2b/shared/models/product.dart';
import 'package:banabana_b2b/shared/widgets/app_snack_bar.dart';
import 'package:banabana_b2b/shared/widgets/loading_shimmer.dart';
import 'package:banabana_b2b/shared/widgets/unsaved_changes_guard.dart';

// ─── Données statiques ────────────────────────────────────────────────────────

// Fallback categories used when API returns nothing
const _kFallbackCategories = [
  'Fruits', 'Légumes', 'Céréales & Grains', 'Tubercules',
  'Légumineuses', 'Épices & Aromates', 'Produits Transformés', 'Autres',
];

const _kWholesaleUnits = ['sac', 'kg', 'carton', 'caisse', 'palette', 'piece', 'litre', 'tonne', 'botte', 'regime'];

const _kWholesaleUnitLabels = {
  'sac': 'Sac',
  'kg': 'Kg',
  'carton': 'Carton',
  'caisse': 'Caisse',
  'palette': 'Palette',
  'piece': 'Pièce',
  'litre': 'Litre',
  'tonne': 'Tonne',
  'botte': 'Botte',
  'regime': 'Régime',
};

// ─── Modèle local pour brouillon de variante ─────────────────────────────────

class _VariantDraft {
  String label;
  String? wholesaleUnit;
  double? weight;
  double price;
  int stock;
  int? minOrderQuantity;

  _VariantDraft({
    required this.label,
    this.wholesaleUnit,
    this.weight,
    required this.price,
    required this.stock,
    this.minOrderQuantity,
  });

  Map<String, dynamic> toJson() => {
        'label': label,
        if (wholesaleUnit != null && wholesaleUnit!.isNotEmpty)
          'wholesaleUnit': wholesaleUnit,
        if (weight != null) 'weight': weight,
        'price': price,
        'stock': stock,
        if (minOrderQuantity != null) 'minOrderQuantity': minOrderQuantity,
      };
}

// ─── Screen wrapper ───────────────────────────────────────────────────────────

class ProductFormScreen extends ConsumerWidget {
  final String? productId;
  const ProductFormScreen({super.key, this.productId});

  bool get isEditing => productId != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!isEditing) return const _ProductFormBody(productId: null, initial: null);

    final productAsync = ref.watch(productDetailProvider(productId!));
    return productAsync.when(
      loading: () => Scaffold(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.gray50,
        appBar: _buildAppBar(context, isDark, 'Modifier le produit'),
        body: const Padding(
          padding: EdgeInsets.all(AppSpacing.s16),
          child: ShimmerBox(height: 500),
        ),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.gray50,
        appBar: _buildAppBar(context, isDark, 'Modifier le produit'),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Symbols.error_outline, size: 48, color: AppColors.error.withValues(alpha: 0.6)),
              const SizedBox(height: AppSpacing.s16),
              Text(e.toString(), textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.s16),
              FilledButton.icon(
                onPressed: () => ref.invalidate(productDetailProvider(productId!)),
                icon: const Icon(Symbols.refresh, size: 16),
                label: const Text('Réessayer'),
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              ),
            ],
          ),
        ),
      ),
      data: (product) => _ProductFormBody(productId: productId, initial: product),
    );
  }

  AppBar _buildAppBar(BuildContext context, bool isDark, String title) {
    final textPrimary = isDark ? AppColors.gray100 : AppColors.gray900;
    final border = isDark ? AppColors.darkBorder : AppColors.gray100;
    return AppBar(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.white,
      elevation: 0,
      leading: IconButton(
        tooltip: 'Retour',
        icon: const Icon(Symbols.arrow_back),
        color: textPrimary,
        onPressed: () => context.pop(),
      ),
      title: Text(title, style: AppTextStyles.sectionTitle.copyWith(color: textPrimary)),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: border),
      ),
    );
  }
}

// ─── Corps du formulaire ──────────────────────────────────────────────────────

class _ProductFormBody extends ConsumerStatefulWidget {
  final String? productId;
  final Product? initial;
  const _ProductFormBody({required this.productId, required this.initial});

  bool get isEditing => productId != null;

  @override
  ConsumerState<_ProductFormBody> createState() => _ProductFormBodyState();
}

class _ProductFormBodyState extends ConsumerState<_ProductFormBody> {
  final _formKey = GlobalKey<FormState>();

  // Champs texte
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  String? _category;

  // Images
  final List<String> _newImagePaths = [];
  final Set<String> _deletedImageIds = {};

  // Variantes
  final List<_VariantDraft> _newVariants = [];
  final Set<String> _deletedVariantIds = {};

  // Statut (édition uniquement)
  late bool _isActive;

  bool _loading = false;
  int _step = 0;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    _titleCtrl = TextEditingController(text: p?.title ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _priceCtrl = TextEditingController(
      text: p != null ? p.basePrice.toStringAsFixed(0) : '',
    );
    _category = p?.category;
    _isActive = p?.isActive ?? true;
    // Suivi des modifications aussi en édition : sans ça le mode « Modifier »
    // laissait perdre la saisie sans le moindre avertissement.
    _titleCtrl.addListener(() { if (mounted) setState(() => _isDirty = true); });
    _descCtrl.addListener(() { if (mounted) setState(() => _isDirty = true); });
    _priceCtrl.addListener(() { if (mounted) setState(() => _isDirty = true); });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  List<ProductImage> get _activeExistingImages =>
      (widget.initial?.images ?? [])
          .where((img) => !_deletedImageIds.contains(img.id))
          .toList();

  List<ProductVariant> get _activeExistingVariants =>
      (widget.initial?.variants ?? [])
          .where((v) => !_deletedVariantIds.contains(v.id))
          .toList();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_category == null) {
      context.showSnack('Veuillez choisir une catégorie', type: SnackType.error);
      return;
    }
    setState(() => _loading = true);
    try {
      final repo = ref.read(productRepositoryProvider);
      String targetId;

      if (widget.isEditing) {
        targetId = widget.productId!;
        await repo.updateProduct(targetId, {
          'title': _titleCtrl.text.trim(),
          'category': _category,
          'description': _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
          'basePrice': double.parse(_priceCtrl.text.trim()),
        });
        // Supprimer images retirées
        for (final id in _deletedImageIds) {
          await repo.deleteImage(targetId, id);
        }
        // Supprimer variantes retirées
        for (final id in _deletedVariantIds) {
          await repo.deleteVariant(id);
        }
        // Activer / désactiver
        if (_isActive != (widget.initial?.isActive ?? true)) {
          if (_isActive) {
            await repo.activate(targetId);
          } else {
            await repo.deactivate(targetId);
          }
        }
      } else {
        final product = await repo.createProduct(
          title: _titleCtrl.text.trim(),
          category: _category!,
          description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
          basePrice: double.parse(_priceCtrl.text.trim()),
        );
        targetId = product.id;
      }

      // Upload nouvelles images
      if (_newImagePaths.isNotEmpty) {
        await repo.uploadImages(targetId, _newImagePaths);
      }
      // Créer nouvelles variantes
      for (final v in _newVariants) {
        await repo.createVariant(targetId, v.toJson());
      }

      ref.invalidate(productsNotifierProvider);
      if (widget.isEditing) ref.invalidate(productDetailProvider(widget.productId!));

      if (mounted) {
        context.showSnack(
          widget.isEditing ? 'Produit mis à jour' : 'Produit créé avec succès',
          type: SnackType.success,
        );
        if (widget.isEditing) {
          context.pop();
        } else {
          context.pushReplacement('/producer/products/$targetId');
        }
      }
    } catch (e) {
      if (mounted) context.showSnack(e.toString(), type: SnackType.error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _pickCategory(BuildContext context, bool isDark) {
    final surface = isDark ? AppColors.darkSurface : AppColors.white;
    final border = isDark ? AppColors.darkBorder : AppColors.gray100;
    final textPrimary = isDark ? AppColors.gray100 : AppColors.gray900;

    // Get categories from provider (already loaded in build)
    final cats = ref.read(myCategoriesProvider).valueOrNull ?? [];
    final names = cats.isNotEmpty
        ? cats.map((c) => (name: c.name, icon: c.icon)).toList()
        : _kFallbackCategories.map<({String name, String? icon})>((n) => (name: n, icon: null)).toList();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXL)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.s12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.s16, AppSpacing.s16, AppSpacing.s8),
              child: Text(
                'Choisir une catégorie',
                style: AppTextStyles.sectionTitle.copyWith(color: textPrimary),
              ),
            ),
            Divider(height: 1, color: border),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: names.length,
              separatorBuilder: (_, _) => Divider(height: 1, color: border),
              itemBuilder: (_, i) {
                final entry = names[i];
                final isSelected = _category == entry.name;
                return ListTile(
                  leading: entry.icon != null && entry.icon!.isNotEmpty
                      ? Text(entry.icon!, style: const TextStyle(fontSize: 20))
                      : null,
                  title: Text(
                    entry.name,
                    style: AppTextStyles.body.copyWith(
                      color: isSelected ? AppColors.primary : textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Symbols.check, color: AppColors.primary, size: 18)
                      : null,
                  onTap: () {
                    setState(() { _category = entry.name; _isDirty = true; });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
            const SizedBox(height: AppSpacing.s8),
          ],
        ),
      ),
    );
  }

  void _showAddVariant(BuildContext context, bool isDark) {
    showModalBottomSheet<_VariantDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddVariantSheet(isDark: isDark),
    ).then((draft) {
      if (draft != null) setState(() { _newVariants.add(draft); _isDirty = true; });
    });
  }

  InputDecoration _inputDeco(String label, {String? hint, bool isDark = false}) {
    final fill = isDark ? AppColors.darkSurface : AppColors.gray50;
    final border = isDark ? AppColors.darkBorder : AppColors.gray200;
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: AppTextStyles.caption.copyWith(
        color: isDark ? AppColors.gray500 : AppColors.gray500,
      ),
      filled: true,
      fillColor: fill,
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s14,
      ),
    );
  }

  // ─── Wizard validation ───────────────────────────────────────────────────────

  bool _validateStep0() {
    if (_titleCtrl.text.trim().isEmpty) {
      context.showSnack('Le nom du produit est requis', type: SnackType.error);
      return false;
    }
    if (_category == null) {
      context.showSnack('Veuillez choisir une catégorie', type: SnackType.error);
      return false;
    }
    return true;
  }

  bool _validateStep1() {
    final t = _priceCtrl.text.trim();
    if (t.isEmpty || double.tryParse(t) == null) {
      context.showSnack('Veuillez saisir un prix valide', type: SnackType.error);
      return false;
    }
    return true;
  }

  void _nextStep() {
    if (_step == 0 && !_validateStep0()) return;
    if (_step == 1 && !_validateStep1()) return;
    if (_step == 2) { _submit(); return; }
    setState(() => _step++);
  }

  void _onBackPressed() {
    if (_step > 0) {
      setState(() => _step--);
      return;
    }
    _leaveIfConfirmed(title: 'Abandonner la création ?');
  }

  /// Sortie via un bouton retour custom : `context.pop()` court-circuite
  /// [PopScope], la confirmation doit donc être déclenchée explicitement.
  Future<void> _leaveIfConfirmed({String? title}) async {
    if (!_isDirty) {
      context.pop();
      return;
    }
    final leave = await UnsavedChangesGuard.confirmLeave(
      context,
      title: title ?? 'Abandonner les modifications ?',
    );
    if (leave && mounted) context.pop();
  }

  // ─── Progress bar ─────────────────────────────────────────────────────────────

  Widget _buildProgressBar(bool isDark, Color textPrimary, Color textSecondary) {
    const labels = ['Infos', 'Prix', 'Finaliser'];
    final active = AppColors.primary;
    final inactive = isDark ? AppColors.darkBorder : AppColors.gray200;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.s24, AppSpacing.s12, AppSpacing.s24, AppSpacing.s8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < 3; i++) ...[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: i < _step
                        ? active
                        : (i == _step
                            ? active.withValues(alpha: 0.12)
                            : (isDark ? AppColors.darkSurface : AppColors.white)),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: i <= _step ? active : inactive,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: i < _step
                        ? const Icon(Symbols.check, size: 14, color: AppColors.white)
                        : Text(
                            '${i + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  i == _step ? FontWeight.w700 : FontWeight.w400,
                              color: i == _step
                                  ? active
                                  : (isDark ? AppColors.gray500 : AppColors.gray400),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  labels[i],
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 10,
                    color: i <= _step
                        ? (isDark ? AppColors.gray200 : AppColors.gray700)
                        : textSecondary,
                    fontWeight: i == _step ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
            if (i < 2)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 13),
                  child: Container(
                    height: 2,
                    color: i < _step ? active : inactive,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  // ─── Section builders (shared between flat form and wizard) ──────────────────

  Widget _photosSection(bool isDark, Color surface, Color border, Color textSecondary,
      List<ProductImage> existingImages, int totalImages) {
    return _FormSection(
      isDark: isDark,
      surface: surface,
      border: border,
      icon: Symbols.photo_library,
      title: 'Photos du produit',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ajoutez jusqu\'à 5 photos (JPEG, PNG)',
              style: AppTextStyles.caption.copyWith(color: textSecondary)),
          const SizedBox(height: AppSpacing.s12),
          SizedBox(
            height: 88,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ...existingImages.map((img) => _ImageThumb(
                      child: CachedNetworkImage(
                          imageUrl: resolveImageUrl(img.url), fit: BoxFit.cover),
                      onRemove: () =>
                          setState(() { _deletedImageIds.add(img.id); _isDirty = true; }),
                    )),
                ..._newImagePaths.asMap().entries.map((e) => _ImageThumb(
                      child: Image.file(File(e.value), fit: BoxFit.cover),
                      onRemove: () =>
                          setState(() { _newImagePaths.removeAt(e.key); _isDirty = true; }),
                    )),
                if (totalImages < 5)
                  GestureDetector(
                    onTap: () => ImagePickerSheet.show(
                      context,
                      onImagesPicked: (paths) => setState(() {
                        final remaining = 5 - totalImages;
                        _newImagePaths.addAll(paths.take(remaining));
                        _isDirty = true;
                      }),
                    ),
                    child: Container(
                      width: 88,
                      height: 88,
                      margin: const EdgeInsets.only(right: AppSpacing.s8),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface2 : AppColors.gray100,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Symbols.add_photo_alternate,
                              color: AppColors.primary, size: 24),
                          const SizedBox(height: AppSpacing.s4),
                          Text('Ajouter',
                              style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoSection(bool isDark, Color surface, Color border, Color textPrimary,
      Color textSecondary) {
    return _FormSection(
      isDark: isDark,
      surface: surface,
      border: border,
      icon: Symbols.info,
      title: 'Informations',
      child: Column(
        children: [
          TextFormField(
            controller: _titleCtrl,
            style: AppTextStyles.body.copyWith(color: textPrimary),
            decoration: _inputDeco('Nom du produit *', isDark: isDark),
            validator: (v) => v == null || v.trim().isEmpty ? 'Champ requis' : null,
          ),
          const SizedBox(height: AppSpacing.s12),
          Semantics(
            label: _category ?? 'Choisir une catégorie',
            button: true,
            container: true,
            excludeSemantics: true,
            child: GestureDetector(
              onTap: () => _pickCategory(context, isDark),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s16, vertical: AppSpacing.s14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.gray50,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  border: Border.all(
                    color: _category == null
                        ? AppColors.error.withValues(alpha: 0.5)
                        : (isDark ? AppColors.darkBorder : AppColors.gray200),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Catégorie *',
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.gray500, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text(
                            _category ?? 'Choisir une catégorie',
                            style: AppTextStyles.body.copyWith(
                              color: _category == null ? textSecondary : textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Symbols.expand_more, color: textSecondary, size: 20),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          TextFormField(
            controller: _descCtrl,
            style: AppTextStyles.body.copyWith(color: textPrimary),
            decoration: _inputDeco('Description',
                hint: 'Qualité, origine, conditionnement…', isDark: isDark),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _priceSection(bool isDark, Color surface, Color border, Color textPrimary,
      Color textSecondary) {
    return _FormSection(
      isDark: isDark,
      surface: surface,
      border: border,
      icon: Symbols.payments,
      title: 'Prix de référence',
      subtitle: 'Prix indicatif — les variantes peuvent avoir leurs propres prix.',
      child: TextFormField(
        controller: _priceCtrl,
        style: AppTextStyles.body.copyWith(color: textPrimary),
        decoration: _inputDeco('Prix de base (FCFA) *', isDark: isDark).copyWith(
          suffixText: 'FCFA',
          suffixStyle: AppTextStyles.caption.copyWith(color: textSecondary),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: false),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Champ requis';
          if (double.tryParse(v.trim()) == null) return 'Nombre invalide';
          return null;
        },
      ),
    );
  }

  Widget _variantsSection(bool isDark, Color surface, Color border, Color textPrimary,
      Color textSecondary, List<ProductVariant> existingVariants) {
    return _FormSection(
      isDark: isDark,
      surface: surface,
      border: border,
      icon: Symbols.package_2,
      title: 'Variantes',
      subtitle: 'Conditionnements proposés (sac 5kg, carton 12kg…)',
      child: Column(
        children: [
          ...existingVariants.map((v) => _VariantTile(
                isDark: isDark,
                border: border,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                label: v.label,
                wholesaleUnit: v.wholesaleUnit,
                price: v.price,
                stock: v.stock,
                minOrderQuantity: v.minOrderQuantity,
                isExisting: true,
                onDelete: () => setState(() => _deletedVariantIds.add(v.id)),
              )),
          ..._newVariants.asMap().entries.map((e) => _VariantTile(
                isDark: isDark,
                border: border,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                label: e.value.label,
                wholesaleUnit: e.value.wholesaleUnit,
                price: e.value.price,
                stock: e.value.stock,
                minOrderQuantity: e.value.minOrderQuantity,
                isExisting: false,
                onDelete: () => setState(() => _newVariants.removeAt(e.key)),
              )),
          if (existingVariants.isNotEmpty || _newVariants.isNotEmpty)
            const SizedBox(height: AppSpacing.s8),
          OutlinedButton.icon(
            onPressed: () => _showAddVariant(context, isDark),
            icon: const Icon(Symbols.add, size: 16),
            label: const Text('Ajouter une variante'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusSection(bool isDark, Color surface, Color border, Color textPrimary,
      Color textSecondary) {
    return _FormSection(
      isDark: isDark,
      surface: surface,
      border: border,
      icon: Symbols.toggle_on,
      title: 'Statut',
      child: Row(
        children: [
          Icon(
            _isActive ? Symbols.visibility : Symbols.visibility_off,
            size: 20,
            color: _isActive ? AppColors.success : textSecondary,
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_isActive ? 'Produit actif' : 'Produit désactivé',
                    style: AppTextStyles.body.copyWith(color: textPrimary)),
                Text(
                  _isActive ? 'Visible par les acheteurs' : 'Masqué du catalogue',
                  style: AppTextStyles.caption.copyWith(color: textSecondary),
                ),
              ],
            ),
          ),
          Switch(
            value: _isActive,
            onChanged: (v) => setState(() => _isActive = v),
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }

  Widget _summarySection(bool isDark, Color surface, Color border, Color textPrimary,
      Color textSecondary, int totalImages, List<ProductVariant> existingVariants) {
    final totalVariants = existingVariants.length + _newVariants.length;
    final price = double.tryParse(_priceCtrl.text.trim());
    return _FormSection(
      isDark: isDark,
      surface: surface,
      border: border,
      icon: Symbols.checklist,
      title: 'Récapitulatif',
      subtitle: 'Vérifiez les informations avant de créer le produit.',
      child: Column(
        children: [
          _SummaryRow(
            icon: Symbols.shopping_bag,
            label: 'Produit',
            value: _titleCtrl.text.trim(),
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            isDark: isDark,
          ),
          _SummaryRow(
            icon: Symbols.category,
            label: 'Catégorie',
            value: _category ?? '—',
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            isDark: isDark,
          ),
          if (_descCtrl.text.trim().isNotEmpty)
            _SummaryRow(
              icon: Symbols.notes,
              label: 'Description',
              value: _descCtrl.text.trim(),
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              isDark: isDark,
            ),
          _SummaryRow(
            icon: Symbols.payments,
            label: 'Prix de base',
            value: price != null ? '${price.toStringAsFixed(0)} FCFA' : '—',
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            isDark: isDark,
          ),
          _SummaryRow(
            icon: Symbols.image,
            label: 'Photos',
            value: totalImages == 0
                ? 'Aucune'
                : '$totalImages photo${totalImages > 1 ? 's' : ''}',
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            isDark: isDark,
          ),
          _SummaryRow(
            icon: Symbols.package_2,
            label: 'Variantes',
            value: totalVariants == 0
                ? 'Aucune'
                : '$totalVariants variante${totalVariants > 1 ? 's' : ''}',
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            isDark: isDark,
            isLast: true,
          ),
        ],
      ),
    );
  }

  // ─── Bottom bars ──────────────────────────────────────────────────────────────

  Widget _buildSubmitBar(bool isDark, Color border) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        border: Border(top: BorderSide(color: border)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s12,
        AppSpacing.s16,
        MediaQuery.of(context).padding.bottom + AppSpacing.s12,
      ),
      child: FilledButton(
        onPressed: _loading ? null : _submit,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium)),
        ),
        child: _loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
              )
            : Text(
                widget.isEditing ? 'Mettre à jour' : 'Créer le produit',
                style: AppTextStyles.label
                    .copyWith(color: AppColors.white, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Widget _buildWizardFooter(bool isDark, Color border, Color textPrimary) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        border: Border(top: BorderSide(color: border)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s12,
        AppSpacing.s16,
        MediaQuery.of(context).padding.bottom + AppSpacing.s12,
      ),
      child: Row(
        children: [
          if (_step > 0) ...[
            Expanded(
              flex: 1,
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _step--),
                icon: const Icon(Symbols.arrow_back, size: 16),
                label: const Text('Retour'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: textPrimary,
                  side: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.gray300),
                  minimumSize: const Size(0, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium)),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
          ],
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: _loading ? null : _nextStep,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                minimumSize: const Size(0, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMedium)),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.white),
                    )
                  : Text(
                      _step == 2 ? 'Créer le produit' : 'Continuer',
                      style: AppTextStyles.label.copyWith(
                          color: AppColors.white, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBg : AppColors.gray50;
    final surface = isDark ? AppColors.darkSurface : AppColors.white;
    final border = isDark ? AppColors.darkBorder : AppColors.gray100;
    final textPrimary = isDark ? AppColors.gray100 : AppColors.gray900;
    final textSecondary = isDark ? AppColors.gray500 : AppColors.gray400;

    final catsAsync = ref.watch(myCategoriesProvider);
    catsAsync.whenData((cats) {
      if (_category != null && cats.isNotEmpty) {
        final resolved = resolveCategory(_category!, cats);
        if (resolved != _category && mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _category = resolved);
          });
        }
      }
    });

    final existingImages = _activeExistingImages;
    final existingVariants = _activeExistingVariants;
    final totalImages = existingImages.length + _newImagePaths.length;

    // ── Editing: flat form ───────────────────────────────────────────────────────
    if (widget.isEditing) {
      return UnsavedChangesGuard(
        isDirty: _isDirty,
        child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.darkBg : AppColors.white,
          elevation: 0,
          leading: IconButton(
            tooltip: 'Retour',
            icon: Icon(Symbols.arrow_back, color: textPrimary),
            onPressed: _leaveIfConfirmed,
          ),
          title: Text('Modifier le produit',
              style: AppTextStyles.sectionTitle.copyWith(color: textPrimary)),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(height: 1, color: border),
          ),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.s96),
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              _photosSection(isDark, surface, border, textSecondary, existingImages, totalImages),
              _infoSection(isDark, surface, border, textPrimary, textSecondary),
              _priceSection(isDark, surface, border, textPrimary, textSecondary),
              _variantsSection(isDark, surface, border, textPrimary, textSecondary, existingVariants),
              _statusSection(isDark, surface, border, textPrimary, textSecondary),
            ],
          ),
        ),
        ),
        bottomNavigationBar: _buildSubmitBar(isDark, border),
      ),
      );
    }

    // ── Création: wizard 3 étapes ────────────────────────────────────────────────
    const stepTitles = ['Photos & Infos', 'Prix & Variantes', 'Finaliser'];
    return UnsavedChangesGuard(
      isDirty: _isDirty,
      title: 'Abandonner la création ?',
      child: Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.white,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Retour',
          icon: Icon(Symbols.arrow_back, color: textPrimary),
          onPressed: _onBackPressed,
        ),
        title: Text(stepTitles[_step],
            style: AppTextStyles.sectionTitle.copyWith(color: textPrimary)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Column(
            children: [
              _buildProgressBar(isDark, textPrimary, textSecondary),
              Divider(height: 1, color: border),
            ],
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: KeyedSubtree(
                  key: ValueKey(_step),
                  child: switch (_step) {
                    0 => ListView(
                        padding: const EdgeInsets.only(bottom: AppSpacing.s16),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        children: [
                          _photosSection(isDark, surface, border, textSecondary,
                              existingImages, totalImages),
                          _infoSection(isDark, surface, border, textPrimary,
                              textSecondary),
                        ],
                      ),
                    1 => ListView(
                        padding: const EdgeInsets.only(bottom: AppSpacing.s16),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        children: [
                          _priceSection(isDark, surface, border, textPrimary,
                              textSecondary),
                          _variantsSection(isDark, surface, border, textPrimary,
                              textSecondary, existingVariants),
                        ],
                      ),
                    _ => ListView(
                        padding: const EdgeInsets.only(bottom: AppSpacing.s16),
                        children: [
                          _summarySection(isDark, surface, border, textPrimary,
                              textSecondary, totalImages, existingVariants),
                        ],
                      ),
                  },
                ),
              ),
            ),
            _buildWizardFooter(isDark, border, textPrimary),
          ],
        ),
      ),
      ),
    ),
    );
  }
}

// ─── Section formulaire ───────────────────────────────────────────────────────

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.isDark,
    required this.surface,
    required this.border,
    required this.icon,
    required this.title,
    required this.child,
    this.subtitle,
  });

  final bool isDark;
  final Color surface;
  final Color border;
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? AppColors.gray100 : AppColors.gray900;
    final textSecondary = isDark ? AppColors.gray500 : AppColors.gray400;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s16,
        AppSpacing.s16,
        0,
      ),
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: AppSpacing.s8),
              Text(
                title,
                style: AppTextStyles.label.copyWith(
                  color: textPrimary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.s4),
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Text(
                subtitle!,
                style: AppTextStyles.caption.copyWith(color: textSecondary),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.s16),
          child,
        ],
      ),
    );
  }
}

// ─── Vignette image ───────────────────────────────────────────────────────────

class _ImageThumb extends StatelessWidget {
  const _ImageThumb({required this.child, required this.onRemove});

  final Widget child;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      margin: const EdgeInsets.only(right: AppSpacing.s8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            child: SizedBox(width: 88, height: 88, child: child),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Symbols.close, size: 12, color: AppColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tuile variante ───────────────────────────────────────────────────────────

class _VariantTile extends StatelessWidget {
  const _VariantTile({
    required this.isDark,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.label,
    required this.wholesaleUnit,
    required this.price,
    required this.stock,
    this.minOrderQuantity,
    required this.isExisting,
    required this.onDelete,
  });

  final bool isDark;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final String label;
  final String? wholesaleUnit;
  final double price;
  final int stock;
  final int? minOrderQuantity;
  final bool isExisting;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.darkSurface2 : AppColors.gray50;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s8),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s10,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            ),
            child: const Icon(Symbols.package_2, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.label.copyWith(
                        color: textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (!isExisting) ...[
                      const SizedBox(width: AppSpacing.s6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                        ),
                        child: Text(
                          'Nouveau',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${price.toStringAsFixed(0)} FCFA · Stock: $stock${minOrderQuantity != null ? ' · Min. $minOrderQuantity' : ''}',
                  style: AppTextStyles.caption.copyWith(color: textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Symbols.delete_outline, size: 18, color: AppColors.error.withValues(alpha: 0.8)),
            onPressed: onDelete,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

// ─── Sheet ajout variante ─────────────────────────────────────────────────────

class _AddVariantSheet extends StatefulWidget {
  const _AddVariantSheet({required this.isDark});
  final bool isDark;

  @override
  State<_AddVariantSheet> createState() => _AddVariantSheetState();
}

class _AddVariantSheetState extends State<_AddVariantSheet> {
  final _formKey = GlobalKey<FormState>();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _minQtyCtrl = TextEditingController();
  String? _wholesaleUnit;

  @override
  void dispose() {
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _minQtyCtrl.dispose();
    super.dispose();
  }

  InputDecoration _deco(String label, {bool isDark = false}) {
    final fill = isDark ? AppColors.darkSurface : AppColors.gray50;
    final border = isDark ? AppColors.darkBorder : AppColors.gray200;
    return InputDecoration(
      labelText: label,
      labelStyle: AppTextStyles.caption.copyWith(color: AppColors.gray500),
      filled: true,
      fillColor: fill,
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
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s12,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final surface = isDark ? AppColors.darkSurface : AppColors.white;
    final textPrimary = isDark ? AppColors.gray100 : AppColors.gray900;
    final textSecondary = isDark ? AppColors.gray500 : AppColors.gray400;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXL),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s16,
        AppSpacing.s16,
        MediaQuery.of(context).viewInsets.bottom + AppSpacing.s16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            Text(
              'Ajouter une variante',
              style: AppTextStyles.sectionTitle.copyWith(color: textPrimary),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              'Définissez un conditionnement avec son prix et stock.',
              style: AppTextStyles.caption.copyWith(color: textSecondary),
            ),
            const SizedBox(height: AppSpacing.s16),

            // Unité de vente en gros
            Text(
              'Unité de vente *',
              style: AppTextStyles.caption.copyWith(color: textSecondary),
            ),
            const SizedBox(height: AppSpacing.s8),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _kWholesaleUnits.length,
                separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.s6),
                itemBuilder: (_, i) {
                  final u = _kWholesaleUnits[i];
                  final sel = _wholesaleUnit == u;
                  return GestureDetector(
                    onTap: () => setState(() => _wholesaleUnit = sel ? null : u),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
                      decoration: BoxDecoration(
                        color: sel
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : (isDark ? AppColors.darkSurface2 : AppColors.gray100),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                        border: Border.all(
                          color: sel ? AppColors.primary : Colors.transparent,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _kWholesaleUnitLabels[u] ?? u,
                        style: AppTextStyles.label.copyWith(
                          color: sel ? AppColors.primary : textSecondary,
                          fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.s12),

            // Prix + Stock côte à côte
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceCtrl,
                    style: AppTextStyles.body.copyWith(color: textPrimary),
                    decoration: _deco('Prix (FCFA) *', isDark: isDark),
                    keyboardType: const TextInputType.numberWithOptions(decimal: false),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Requis';
                      if (double.tryParse(v.trim()) == null) return 'Invalide';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: TextFormField(
                    controller: _stockCtrl,
                    style: AppTextStyles.body.copyWith(color: textPrimary),
                    decoration: _deco('Stock *', isDark: isDark),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Requis';
                      if (int.tryParse(v.trim()) == null) return 'Invalide';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s12),

            // Commande minimale
            TextFormField(
              controller: _minQtyCtrl,
              style: AppTextStyles.body.copyWith(color: textPrimary),
              decoration: _deco('Qté minimale de commande', isDark: isDark),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: AppSpacing.s20),

            FilledButton(
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;
                if (_wholesaleUnit == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Choisissez une unité de vente')),
                  );
                  return;
                }
                Navigator.of(context).pop(
                  _VariantDraft(
                    label: _kWholesaleUnitLabels[_wholesaleUnit] ?? _wholesaleUnit!,
                    wholesaleUnit: _wholesaleUnit,
                    price: double.parse(_priceCtrl.text.trim()),
                    stock: int.parse(_stockCtrl.text.trim()),
                    minOrderQuantity: int.tryParse(_minQtyCtrl.text.trim()),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                ),
              ),
              child: Text(
                'Ajouter cette variante',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Summary row ──────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.textPrimary,
    required this.textSecondary,
    required this.isDark,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color textPrimary;
  final Color textSecondary;
  final bool isDark;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final dividerColor = isDark ? AppColors.darkBorder : AppColors.gray100;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s10),
          child: Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary.withValues(alpha: 0.7)),
              const SizedBox(width: AppSpacing.s12),
              SizedBox(
                width: 90,
                child: Text(label,
                    style: AppTextStyles.caption.copyWith(color: textSecondary)),
              ),
              Expanded(
                child: Text(
                  value,
                  style: AppTextStyles.label.copyWith(color: textPrimary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, color: dividerColor),
      ],
    );
  }
}
