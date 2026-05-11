import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/features/auth/providers/auth_provider.dart';
import 'package:banabana_b2b/features/producer/providers/analytics_providers.dart';
import 'package:banabana_b2b/features/producer/providers/order_providers.dart';
import 'package:banabana_b2b/features/producer/providers/product_providers.dart';
import 'package:banabana_b2b/shared/models/order.dart';
import 'package:banabana_b2b/shared/widgets/order_status_badge.dart';
import 'package:banabana_b2b/shared/widgets/error_state_widget.dart';
import 'package:banabana_b2b/shared/widgets/loading_shimmer.dart';

class ProducerDashboardScreen extends ConsumerWidget {
  const ProducerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsSummaryProvider);
    final ordersAsync = ref.watch(ordersNotifierProvider);
    final productsAsync = ref.watch(productsNotifierProvider);
    final user = ref.watch(authProvider).user;
    final fmt = NumberFormat('#,###', 'fr_FR');

    final displayName = user?.firstName != null && user!.firstName!.isNotEmpty
        ? user.firstName!
        : user?.phone ?? 'Producteur';

    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 140,
            floating: true,
            snap: true,
            pinned: false,
            backgroundColor: AppColors.success,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.success, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('Bienvenue, $displayName !',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 4),
                          const Text('Espace Producteur',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              )),
                          const Text('Gérez vos produits et commandes reçues',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(Symbols.eco,
                        size: 60, color: Colors.white24),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Symbols.notifications,
                    color: Colors.white),
                tooltip: 'Messages',
                onPressed: () => context.push('/producer/messages'),
              ),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Stats ────────────────────────────────────────
                analyticsAsync.when(
                  loading: () => GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children:
                        List.generate(4, (_) => const ShimmerBox(height: 80)),
                  ),
                  error: (e, _) => ErrorStateWidget(
                    message: e.toString(),
                    onRetry: () => ref.invalidate(analyticsSummaryProvider),
                  ),
                  data: (summary) {
                    final productCount = productsAsync.valueOrNull?.length ?? 0;
                    return GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _StatCard(
                          label: 'Produits',
                          value: '$productCount',
                          icon: Symbols.inventory_2,
                          color: AppColors.primary,
                        ),
                        _StatCard(
                          label: 'Commandes reçues',
                          value: '${summary.totalOrders}',
                          icon: Symbols.shopping_cart,
                          color: AppColors.secondary,
                        ),
                        _StatCard(
                          label: 'Revenus FCFA',
                          value: fmt.format(summary.totalRevenue),
                          icon: Symbols.wallet,
                          color: AppColors.success,
                        ),
                        _StatCard(
                          label: 'En attente',
                          value: '${summary.pendingOrders}',
                          icon: Symbols.pending_actions,
                          color: AppColors.warning,
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),

                // ── Quick Actions ─────────────────────────────────
                const Text('Actions rapides',
                    style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.95,
                  children: [
                    _QuickAction(
                      label: 'Ajouter produit',
                      icon: Symbols.add_circle,
                      color: AppColors.primary,
                      onTap: () => context.push('/producer/products/new'),
                    ),
                    _QuickAction(
                      label: 'Mes produits',
                      icon: Symbols.inventory_2,
                      color: AppColors.secondary,
                      onTap: () => context.push('/producer/products'),
                    ),
                    _QuickAction(
                      label: 'Commandes',
                      icon: Symbols.receipt_long,
                      color: AppColors.success,
                      onTap: () => context.push('/producer/orders'),
                    ),
                    _QuickAction(
                      label: 'Statistiques',
                      icon: Symbols.bar_chart,
                      color: const Color(0xFF9B59B6),
                      onTap: () => context.push('/producer/analytics'),
                    ),
                    _QuickAction(
                      label: 'Gestion stock',
                      icon: Symbols.layers,
                      color: AppColors.error,
                      onTap: () => context.push('/producer/inventory'),
                    ),
                    _QuickAction(
                      label: 'Messagerie',
                      icon: Symbols.chat,
                      color: AppColors.info,
                      onTap: () => context.push('/producer/messages'),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── Commandes récentes ────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Commandes récentes',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () => context.push('/producer/orders'),
                      child: const Text('Voir tout'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ordersAsync.when(
                  loading: () => const ShimmerBox(height: 200),
                  error: (e, _) => ErrorStateWidget(
                    message: e.toString(),
                    onRetry: () => ref.invalidate(ordersNotifierProvider),
                  ),
                  data: (orders) {
                    final recent = orders.take(5).toList();
                    if (recent.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        alignment: Alignment.center,
                        child: const Column(
                          children: [
                            Icon(Symbols.shopping_cart,
                                size: 48, color: AppColors.gray400),
                            SizedBox(height: 12),
                            Text('Aucune commande reçue',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.gray700)),
                            SizedBox(height: 4),
                            Text(
                              'Les commandes des grossistes apparaîtront ici',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.gray500),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }
                    return Column(
                      children: recent.map((o) => _OrderTile(order: o)).toList(),
                    );
                  },
                ),

                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat card ──────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label, value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.gray500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick action card ──────────────────────────────────────────────────────────
class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

// ── Order tile ─────────────────────────────────────────────────────────────────
class _OrderTile extends StatelessWidget {
  final Order order;
  const _OrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###', 'fr_FR');
    return GestureDetector(
      onTap: () => context.push('/producer/orders/${order.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 1)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Symbols.receipt_long,
                  size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${order.id.substring(0, 8).toUpperCase()}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${fmt.format(order.totalAmount)} FCFA • ${order.items.length} article${order.items.length > 1 ? 's' : ''}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.gray500),
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
