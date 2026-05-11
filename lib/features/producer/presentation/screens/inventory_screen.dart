import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/features/producer/providers/inventory_providers.dart';
import 'package:banabana_b2b/features/producer/providers/product_providers.dart';
import 'package:banabana_b2b/features/producer/presentation/widgets/inventory_movement_sheet.dart';
import 'package:banabana_b2b/shared/widgets/empty_state_widget.dart';
import 'package:banabana_b2b/shared/widgets/error_state_widget.dart';
import 'package:banabana_b2b/shared/widgets/loading_shimmer.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryAsync = ref.watch(inventoryNotifierProvider);
    final productsAsync = ref.watch(productsNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const Text('Inventaire'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: inventoryAsync.when(
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 5,
          itemBuilder: (_, __) => const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: ShimmerBox(height: 72),
          ),
        ),
        error: (e, _) => ErrorStateWidget(
          message: e.toString(),
          onRetry: () =>
              ref.read(inventoryNotifierProvider.notifier).load(),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyStateWidget(
              title: 'Aucun stock',
              subtitle: 'Aucun stock enregistré pour le moment.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final inv = items[i];
              String variantLabel = inv.variantId.substring(0, 8);
              productsAsync.whenData((products) {
                for (final p in products) {
                  for (final v in p.variants) {
                    if (v.id == inv.variantId) {
                      variantLabel = '${p.title} — ${v.label}';
                    }
                  }
                }
              });
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Icon(
                      Icons.inventory_2_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  title: Text(
                    variantLabel,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: inv.location != null
                      ? Text(
                          inv.location!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.gray500,
                          ),
                        )
                      : null,
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.swap_vert,
                      color: AppColors.primary,
                    ),
                    tooltip: 'Mouvement de stock',
                    onPressed: () => InventoryMovementSheet.show(
                      context,
                      variantId: inv.variantId,
                      variantLabel: variantLabel,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
