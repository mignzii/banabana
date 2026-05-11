import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:banabana_b2b/core/api/api_client.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/shared/models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  const ProductCard({super.key, required this.product, this.onTap, this.onEdit});

  @override
  Widget build(BuildContext context) {
    final image = product.images.isNotEmpty
        ? resolveImageUrl(product.images.first.url)
        : null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: image != null
                    ? CachedNetworkImage(imageUrl: image, fit: BoxFit.cover)
                    : Container(
                        color: AppColors.gray100,
                        child: const Icon(Icons.image, color: AppColors.gray400, size: 40),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.title,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (onEdit != null)
                        GestureDetector(
                          onTap: onEdit,
                          child: const Icon(Icons.edit_outlined, size: 18, color: AppColors.gray400),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.basePrice.toStringAsFixed(0)} FCFA',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: product.isActive ? AppColors.success : AppColors.gray400,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.isActive ? 'Actif' : 'Inactif',
                        style: TextStyle(
                          fontSize: 11,
                          color: product.isActive ? AppColors.success : AppColors.gray400,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${product.variants.length} variante${product.variants.length > 1 ? 's' : ''}',
                        style: const TextStyle(fontSize: 11, color: AppColors.gray500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
