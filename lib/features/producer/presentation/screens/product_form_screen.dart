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

// ─── Données statiques ────────────────────────────────────────────────────────

// Fallback categories used when API returns nothing
const _kFallbackCategories = [
  'Fruits', 'Légumes', 'Céréales & Grains', 'Tubercules',
  'Légumineuses', 'Épices & Aromates', 'Produits Transformés', 'Autres',
];

const _kPackTypes = ['Sac', 'Carton', 'Cageot', 'Régime', 'Boite', 'Filet', 'Unité'];

// ─── Modèle local pour brouillon de variante ─────────────────────────────────

class _VariantDraft {
  String label;
  String? pack;
  double? weight;
  double price;
  int stock;

  _VariantDraft({
    required this.label,
    this.pack,
    this.weight,
    required this.price,
    required this.stock,
  });

  Map<String, dynamic> toJson() => {
        'label': label,
        if (pack != null && pack!.isNotEmpty) 'pack': pack,
        if (weight != null) 'weight': weight,
        'price': price,
        'stock': stock,
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
  List<String> _newImagePaths = [];
  final Set<String> _deletedImageIds = {};

  // Variantes
  final List<_VariantDraft> _newVariants = [];
  final Set<String> _deletedVariantIds = {};

  // Statut (édition uniquement)
  late bool _isActive;

  bool _loading = false;

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
        context.pop();
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
              separatorBuilder: (_, __) => Divider(height: 1, color: border),
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
                    setState(() => _category = entry.name);
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
      if (draft != null) setState(() => _newVariants.add(draft));
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBg : AppColors.gray50;
    final surface = isDark ? AppColors.darkSurface : AppColors.white;
    final border = isDark ? AppColors.darkBorder : AppColors.gray100;
    final textPrimary = isDark ? AppColors.gray100 : AppColors.gray900;
    final textSecondary = isDark ? AppColors.gray500 : AppColors.gray400;

    // Load categories and resolve existing UUID category to name
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

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Symbols.arrow_back, color: textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.isEditing ? 'Modifier le produit' : 'Nouveau produit',
          style: AppTextStyles.sectionTitle.copyWith(color: textPrimary),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: border),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.only(
            bottom: AppSpacing.s96,
          ),
          children: [
            // ── Photos ──────────────────────────────────────────────────────
            _FormSection(
              isDark: isDark,
              surface: surface,
              border: border,
              icon: Symbols.photo_library,
              title: 'Photos du produit',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ajoutez jusqu\'à 5 photos (JPEG, PNG)',
                    style: AppTextStyles.caption.copyWith(color: textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  SizedBox(
                    height: 88,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        // Images existantes (edit)
                        ...existingImages.map((img) => _ImageThumb(
                              child: CachedNetworkImage(
                                imageUrl: resolveImageUrl(img.url),
                                fit: BoxFit.cover,
                              ),
                              onRemove: () => setState(() => _deletedImageIds.add(img.id)),
                            )),
                        // Nouvelles images (local)
                        ..._newImagePaths.asMap().entries.map((e) => _ImageThumb(
                              child: Image.file(File(e.value), fit: BoxFit.cover),
                              onRemove: () => setState(() => _newImagePaths.removeAt(e.key)),
                            )),
                        // Bouton ajouter
                        if (totalImages < 5)
                          GestureDetector(
                            onTap: () => ImagePickerSheet.show(
                              context,
                              onImagesPicked: (paths) => setState(() {
                                final remaining = 5 - totalImages;
                                _newImagePaths.addAll(paths.take(remaining));
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
                                  color: AppColors.primary.withValues(alpha: 0.4),
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Symbols.add_photo_alternate,
                                      color: AppColors.primary, size: 24),
                                  const SizedBox(height: AppSpacing.s4),
                                  Text(
                                    'Ajouter',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Informations ─────────────────────────────────────────────────
            _FormSection(
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
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  // Catégorie — picker
                  GestureDetector(
                    onTap: () => _pickCategory(context, isDark),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s16,
                        vertical: AppSpacing.s14,
                      ),
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
                                Text(
                                  'Catégorie *',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.gray500,
                                    fontSize: 11,
                                  ),
                                ),
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
                  const SizedBox(height: AppSpacing.s12),
                  TextFormField(
                    controller: _descCtrl,
                    style: AppTextStyles.body.copyWith(color: textPrimary),
                    decoration: _inputDeco(
                      'Description',
                      hint: 'Qualité, origine, conditionnement…',
                      isDark: isDark,
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),

            // ── Prix de base ─────────────────────────────────────────────────
            _FormSection(
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
            ),

            // ── Variantes ────────────────────────────────────────────────────
            _FormSection(
              isDark: isDark,
              surface: surface,
              border: border,
              icon: Symbols.package_2,
              title: 'Variantes',
              subtitle: 'Conditionnements proposés (sac 5kg, carton 12kg…)',
              child: Column(
                children: [
                  // Variantes existantes (édition)
                  ...existingVariants.map((v) => _VariantTile(
                        isDark: isDark,
                        border: border,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        label: v.label,
                        pack: v.pack,
                        price: v.price,
                        stock: v.stock,
                        isExisting: true,
                        onDelete: () => setState(() => _deletedVariantIds.add(v.id)),
                      )),
                  // Nouvelles variantes
                  ..._newVariants.asMap().entries.map((e) => _VariantTile(
                        isDark: isDark,
                        border: border,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        label: e.value.label,
                        pack: e.value.pack,
                        price: e.value.price,
                        stock: e.value.stock,
                        isExisting: false,
                        onDelete: () => setState(() => _newVariants.removeAt(e.key)),
                      )),
                  if (existingVariants.isNotEmpty || _newVariants.isNotEmpty)
                    const SizedBox(height: AppSpacing.s8),
                  // Bouton ajouter variante
                  OutlinedButton.icon(
                    onPressed: () => _showAddVariant(context, isDark),
                    icon: const Icon(Symbols.add, size: 16),
                    label: const Text('Ajouter une variante'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.5),
                      ),
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Statut (édition uniquement) ──────────────────────────────────
            if (widget.isEditing)
              _FormSection(
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
                          Text(
                            _isActive ? 'Produit actif' : 'Produit désactivé',
                            style: AppTextStyles.body.copyWith(color: textPrimary),
                          ),
                          Text(
                            _isActive
                                ? 'Visible par les acheteurs'
                                : 'Masqué du catalogue',
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
              ),
          ],
        ),
      ),
      // ── Bouton soumettre ─────────────────────────────────────────────────────
      bottomNavigationBar: Container(
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
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            ),
          ),
          child: _loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.white,
                  ),
                )
              : Text(
                  widget.isEditing ? 'Mettre à jour' : 'Créer le produit',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
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
    required this.pack,
    required this.price,
    required this.stock,
    required this.isExisting,
    required this.onDelete,
  });

  final bool isDark;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final String label;
  final String? pack;
  final double price;
  final int stock;
  final bool isExisting;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.darkSurface2 : AppColors.gray50;
    final packLabel = pack != null && pack!.isNotEmpty ? '$pack · ' : '';

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
                      '$packLabel$label',
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
                  '${price.toStringAsFixed(0)} FCFA · Stock: $stock',
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
  final _labelCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  String? _pack;

  @override
  void dispose() {
    _labelCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
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

            // Type de conditionnement
            Text(
              'Type de conditionnement',
              style: AppTextStyles.caption.copyWith(color: textSecondary),
            ),
            const SizedBox(height: AppSpacing.s8),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _kPackTypes.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.s6),
                itemBuilder: (_, i) {
                  final p = _kPackTypes[i];
                  final sel = _pack == p;
                  return GestureDetector(
                    onTap: () => setState(() => _pack = sel ? null : p),
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
                        p,
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

            // Label
            TextFormField(
              controller: _labelCtrl,
              style: AppTextStyles.body.copyWith(color: textPrimary),
              decoration: _deco('Label * (ex: 5kg, Carton de 12…)', isDark: isDark),
              validator: (v) => v == null || v.trim().isEmpty ? 'Champ requis' : null,
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
            const SizedBox(height: AppSpacing.s20),

            FilledButton(
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;
                Navigator.of(context).pop(
                  _VariantDraft(
                    label: _labelCtrl.text.trim(),
                    pack: _pack,
                    price: double.parse(_priceCtrl.text.trim()),
                    stock: int.parse(_stockCtrl.text.trim()),
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
