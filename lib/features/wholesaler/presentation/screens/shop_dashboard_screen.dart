import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/features/wholesaler/providers/wholesaler_order_providers.dart';
import 'package:banabana_b2b/features/wholesaler/presentation/widgets/cart_badge.dart';
import 'package:banabana_b2b/shared/models/order.dart';
import 'package:banabana_b2b/shared/widgets/stat_card.dart';
import 'package:banabana_b2b/shared/widgets/order_status_badge.dart';
import 'package:banabana_b2b/shared/widgets/error_state_widget.dart';
import 'package:banabana_b2b/shared/widgets/loading_shimmer.dart';

class ShopDashboardScreen extends ConsumerWidget {
  const ShopDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(wholesalerOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            snap: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Bienvenue',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'BanaBana Shop',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              CartBadge(
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                  onPressed: () => context.push('/shop/cart'),
                ),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                ordersAsync.when(
                  loading: () => GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: List.generate(4, (_) => const ShimmerBox(height: 90)),
                  ),
                  error: (e, _) => ErrorStateWidget(
                    message: e.toString(),
                    onRetry: () => ref.invalidate(wholesalerOrdersProvider),
                  ),
                  data: (orders) {
                    final fmt = NumberFormat('#,###', 'fr_FR');
                    final totalSpent = orders
                        .where((o) => o.status != OrderStatus.cancelled)
                        .fold<double>(0, (s, o) => s + o.totalAmount);
                    final pending = orders
                        .where((o) =>
                            o.status == OrderStatus.created ||
                            o.status == OrderStatus.preparing)
                        .length;
                    return GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.4,
                      children: [
                        StatCard(
                          label: 'Commandes',
                          value: '${orders.length}',
                          icon: Icons.shopping_bag_outlined,
                        ),
                        StatCard(
                          label: 'Dépenses FCFA',
                          value: fmt.format(totalSpent),
                          icon: Icons.payments_outlined,
                          iconColor: AppColors.secondary,
                        ),
                        StatCard(
                          label: 'En cours',
                          value: '$pending',
                          icon: Icons.pending_actions,
                          iconColor: AppColors.warning,
                        ),
                        StatCard(
                          label: 'Livrées',
                          value: '${orders.where((o) => o.status == OrderStatus.delivered).length}',
                          icon: Icons.check_circle_outline,
                          iconColor: AppColors.success,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => context.push('/shop/catalog'),
                  icon: const Icon(Icons.search),
                  label: const Text('Explorer le catalogue'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Commandes récentes',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () => context.push('/shop/orders'),
                      child: const Text('Voir tout'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ordersAsync.when(
                  loading: () => const ShimmerBox(height: 160),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (orders) {
                    final recent = orders.take(3).toList();
                    if (recent.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'Aucune commande',
                            style: TextStyle(color: AppColors.gray500),
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: recent
                          .map((o) => _RecentOrderTile(order: o))
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentOrderTile extends StatelessWidget {
  final Order order;
  const _RecentOrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/shop/orders/${order.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
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
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${order.id.substring(0, 8).toUpperCase()}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${order.totalAmount.toStringAsFixed(0)} FCFA',
                    style: const TextStyle(fontSize: 12, color: AppColors.gray500),
                  ),
                ],
              ),
            ),
            OrderStatusBadge(status: order.status),
          ],
        ),
      ),
    );
  }
}
