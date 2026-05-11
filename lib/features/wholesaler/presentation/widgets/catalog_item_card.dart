import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:banabana_b2b/core/api/api_client.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/shared/models/catalog_item.dart';

class CatalogItemCard extends StatelessWidget {
  final CatalogItem item;
  final VoidCallback? onTap;

  const CatalogItemCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
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
                aspectRatio: 4 / 3,
                child: item.mainImage != null
                    ? CachedNetworkImage(
                        imageUrl: resolveImageUrl(item.mainImage!),
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: AppColors.gray100,
                        child: const Icon(
                          Icons.image_outlined,
                          color: AppColors.gray400,
                          size: 36,
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'À partir de ${item.minPrice.toStringAsFixed(0)} FCFA',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.store_outlined, size: 11, color: AppColors.gray400),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          item.producer.businessName,
                          style: const TextStyle(fontSize: 10, color: AppColors.gray500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: item.totalStock > 0 ? AppColors.success : AppColors.error,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.totalStock > 0 ? 'En stock' : 'Rupture',
                        style: TextStyle(
                          fontSize: 10,
                          color: item.totalStock > 0 ? AppColors.success : AppColors.error,
                        ),
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
