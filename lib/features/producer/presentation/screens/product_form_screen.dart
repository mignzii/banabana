import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:banabana_b2b/core/api/api_client.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/features/producer/providers/product_providers.dart';
import 'package:banabana_b2b/features/producer/presentation/widgets/image_picker_sheet.dart';
import 'package:banabana_b2b/shared/models/product.dart';
import 'package:banabana_b2b/shared/widgets/app_snack_bar.dart';
import 'package:banabana_b2b/shared/widgets/error_state_widget.dart';
import 'package:banabana_b2b/shared/widgets/loading_shimmer.dart';

class ProductFormScreen extends ConsumerWidget {
  final String? productId;
  const ProductFormScreen({super.key, this.productId});

  bool get isEditing => productId != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isEditing) {
      return _ProductFormBody(productId: null, initial: null);
    }

    final productAsync = ref.watch(productDetailProvider(productId!));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le produit'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: productAsync.when(
        loading: () =>
            const Padding(padding: EdgeInsets.all(16), child: ShimmerBox(height: 400)),
        error: (e, _) => ErrorStateWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(productDetailProvider(productId!)),
        ),
        data: (product) => _ProductFormBody(productId: productId, initial: product),
      ),
    );
  }
}

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
  late final TextEditingController _titleCtrl;
  late final TextEditingController _categoryCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  bool _loading = false;
  List<String> _pendingImagePaths = [];

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    _titleCtrl = TextEditingController(text: p?.title ?? '');
    _categoryCtrl = TextEditingController(text: p?.category ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _priceCtrl = TextEditingController(
        text: p != null ? p.basePrice.toStringAsFixed(0) : '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _categoryCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final repo = ref.read(productRepositoryProvider);
      if (widget.isEditing) {
        await repo.updateProduct(widget.productId!, {
          'title': _titleCtrl.text.trim(),
          'category': _categoryCtrl.text.trim(),
          'description':
              _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
          'basePrice': double.parse(_priceCtrl.text.trim()),
        });
        if (_pendingImagePaths.isNotEmpty) {
          await repo.uploadImages(widget.productId!, _pendingImagePaths);
        }
        ref.invalidate(productDetailProvider(widget.productId!));
      } else {
        final product = await repo.createProduct(
          title: _titleCtrl.text.trim(),
          category: _categoryCtrl.text.trim(),
          description:
              _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
          basePrice: double.parse(_priceCtrl.text.trim()),
        );
        if (_pendingImagePaths.isNotEmpty) {
          await repo.uploadImages(product.id, _pendingImagePaths);
        }
      }
      ref.invalidate(productsNotifierProvider);
      if (mounted) {
        context.showSnack(
          widget.isEditing ? 'Produit mis à jour' : 'Produit créé',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.isEditing
          ? null
          : AppBar(
              title: const Text('Nouveau produit'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Nom du produit *'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Champ requis' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _categoryCtrl,
              decoration: const InputDecoration(labelText: 'Catégorie *'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Champ requis' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceCtrl,
              decoration:
                  const InputDecoration(labelText: 'Prix de base (FCFA) *'),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Champ requis';
                if (double.tryParse(v.trim()) == null) return 'Nombre invalide';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            if (widget.initial?.images.isNotEmpty == true) ...[
              const Text('Photos actuelles',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray600)),
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.initial!.images.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      resolveImageUrl(widget.initial!.images[i].url),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            OutlinedButton.icon(
              onPressed: () => ImagePickerSheet.show(
                context,
                onImagesPicked: (paths) =>
                    setState(() => _pendingImagePaths = paths),
              ),
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: Text(
                _pendingImagePaths.isEmpty
                    ? (widget.isEditing
                        ? 'Remplacer les photos'
                        : 'Ajouter des photos')
                    : '${_pendingImagePaths.length} photo(s) sélectionnée(s)',
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
              ),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(widget.isEditing ? 'Mettre à jour' : 'Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}
