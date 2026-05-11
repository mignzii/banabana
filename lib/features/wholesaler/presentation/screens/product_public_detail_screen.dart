import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:banabana_b2b/core/api/api_client.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/features/producer/providers/product_providers.dart';
import 'package:banabana_b2b/features/wholesaler/providers/cart_providers.dart';
import 'package:banabana_b2b/shared/models/product.dart';
import 'package:banabana_b2b/shared/widgets/error_state_widget.dart';
import 'package:banabana_b2b/shared/widgets/loading_shimmer.dart';

class ProductPublicDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  const ProductPublicDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductPublicDetailScreen> createState() =>
      _ProductPublicDetailScreenState();
}

class _ProductPublicDetailScreenState
    extends ConsumerState<ProductPublicDetailScreen> {
  ProductVariant? _selectedVariant;
  int _quantity = 1;

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Ajouté au panier'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Voir',
          textColor: Colors.white,
          onPressed: () => context.push('/shop/cart'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail produit'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: productAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: ShimmerBox(height: 500),
        ),
        error: (e, _) => ErrorStateWidget(
          message: e.toString(),
          onRetry: () =>
              ref.invalidate(productDetailProvider(widget.productId)),
        ),
        data: (product) {
          _selectedVariant ??=
              product.variants.isNotEmpty ? product.variants.first : null;
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (product.images.isNotEmpty)
                      SizedBox(
                        height: 220,
                        child: PageView.builder(
                          itemCount: product.images.length,
                          itemBuilder: (_, i) => ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: resolveImageUrl(product.images[i].url),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        height: 160,
                        decoration: BoxDecoration(
                          color: AppColors.gray100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: 56,
                            color: AppColors.gray300,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      product.title,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.category,
                      style: const TextStyle(
                          color: AppColors.gray500, fontSize: 13),
                    ),
                    if (product.description != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        product.description!,
                        style: const TextStyle(
                            color: AppColors.gray600, fontSize: 13),
                      ),
                    ],
                    const SizedBox(height: 20),
                    const Text(
                      'Choisir une variante',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: product.variants.map((v) {
                        final selected = _selectedVariant?.id == v.id;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedVariant = v),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.gray300,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  v.label,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: selected
                                        ? Colors.white
                                        : AppColors.gray800,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  '${v.price.toStringAsFixed(0)} FCFA',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: selected
                                        ? Colors.white70
                                        : AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text('Quantité',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            if (_quantity > 1) setState(() => _quantity--);
                          },
                          icon: const Icon(Icons.remove_circle_outline,
                              color: AppColors.primary),
                        ),
                        Text(
                          '$_quantity',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () => setState(() => _quantity++),
                          icon: const Icon(Icons.add_circle_outline,
                              color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (_selectedVariant != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Total',
                              style: TextStyle(
                                  fontSize: 11, color: AppColors.gray500)),
                          Text(
                            '${(_selectedVariant!.price * _quantity).toStringAsFixed(0)} FCFA',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: _selectedVariant != null
                          ? () => _addToCart(product)
                          : null,
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Ajouter au panier'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
