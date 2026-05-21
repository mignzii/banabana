import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_spacing.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';
import 'package:banabana_b2b/features/producer/providers/inventory_providers.dart';
import 'package:banabana_b2b/features/producer/providers/product_providers.dart';
import 'package:banabana_b2b/features/wholesaler/providers/wholesaler_order_providers.dart';
import 'package:banabana_b2b/features/producer/presentation/widgets/inventory_movement_sheet.dart';
import 'package:banabana_b2b/shared/models/inventory.dart';
import 'package:banabana_b2b/shared/models/order.dart';
import 'package:banabana_b2b/shared/widgets/error_state_widget.dart';
import 'package:banabana_b2b/shared/widgets/loading_shimmer.dart';

class WholesalerInventoryScreen extends ConsumerStatefulWidget {
  const WholesalerInventoryScreen({super.key});

  @override
  ConsumerState<WholesalerInventoryScreen> createState() =>
      _WholesalerInventoryScreenState();
}

class _WholesalerInventoryScreenState
    extends ConsumerState<WholesalerInventoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _tabCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  // Build a variantId → name map from order history
  Map<String, String> _buildNameMap(List<Order> orders) {
    final map = <String, String>{};
    for (final o in orders) {
      for (final i in o.items) {
        if (!map.containsKey(i.variantId)) {
          final name = [
            if (i.productName != null && i.productName!.isNotEmpty)
              i.productName!,
            if (i.variantName != null && i.variantName!.isNotEmpty)
              i.variantName!,
          ].join(' — ');
          map[i.variantId] = name.isEmpty
              ? i.variantId.substring(0, 8).toUpperCase()
              : name;
        }
      }
    }
    return map;
  }

  Color _stockColor(int stock, int minStock) {
    if (stock == 0) return AppColors.error;
    if (minStock > 0 && stock <= minStock) return AppColors.warning;
    return AppColors.success;
  }

  String _stockLabel(int stock, int minStock) {
    if (stock == 0) return 'Rupture';
    if (minStock > 0 && stock <= minStock) return 'Stock faible';
    return 'En stock';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBg : AppColors.gray50;
    final surface = isDark ? AppColors.darkSurface : AppColors.white;
    final textPrimary = isDark ? AppColors.gray100 : AppColors.gray900;
    final border = isDark ? AppColors.darkBorder : AppColors.gray200;

    final inventoryAsync = ref.watch(inventoryNotifierProvider);
    final movementsAsync = ref.watch(stockMovementsProvider);
    final ordersAsync = ref.watch(wholesalerOrdersProvider);
    final productsAsync = ref.watch(productsNotifierProvider);

    final inventoryItems = inventoryAsync.valueOrNull ?? [];
    final orders = ordersAsync.valueOrNull ?? [];
    final products = productsAsync.valueOrNull ?? [];
    final nameMap = _buildNameMap(orders);

    final fmt = NumberFormat('#,###', 'fr_FR');

    // Build an index from variantId → inventory entry for cost/location enrichment
    final invMap = {for (final i in inventoryItems) i.variantId: i};

    // Primary source: product variants — stock is the canonical truth
    final resolved = <({String variantId, String name, int stock, int minStock, int maxStock, String? unit, String? location, double? costPrice})>[];
    for (final p in products) {
      for (final v in p.variants) {
        final inv = invMap[v.id];
        resolved.add((
          variantId: v.id,
          name: '${p.title} — ${v.label}',
          stock: v.stock,
          minStock: v.minStock ?? 0,
          maxStock: v.maxStock ?? 0,
          unit: v.wholesaleUnit,
          location: inv?.location,
          costPrice: inv?.costPrice,
        ));
      }
    }

    final filtered = _query.isEmpty
        ? resolved
        : resolved
            .where(
                (r) => r.name.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    final outOfStock = resolved.where((r) => r.stock == 0).toList();
    final lowStock = resolved
        .where((r) =>
            r.stock > 0 &&
            r.minStock > 0 &&
            r.stock <= r.minStock)
        .toList();
    final alertCount = outOfStock.length + lowStock.length;

    final totalValue = inventoryItems.fold<double>(0, (s, i) => s + (i.totalValue ?? 0));

    // Category-level stats from order history
    final Map<String, ({int qty, double amount})> productStats = {};
    for (final o in orders.where((o) => o.status != OrderStatus.cancelled)) {
      for (final i in o.items) {
        final key = i.productName ?? i.productId;
        final prev = productStats[key];
        productStats[key] = (
          qty: (prev?.qty ?? 0) + i.quantity,
          amount: (prev?.amount ?? 0) + i.unitPrice * i.quantity,
        );
      }
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg : surface,
        elevation: 0,
        title: Text(
          'Gestion de Stock',
          style: AppTextStyles.sectionTitle.copyWith(color: textPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(Symbols.analytics,
                color: isDark ? AppColors.gray300 : AppColors.gray700),
            tooltip: 'Analytiques',
            onPressed: () => context.push('/shop/analytics'),
          ),
          IconButton(
            icon: Icon(Symbols.add,
                color: isDark ? AppColors.gray300 : AppColors.gray700),
            tooltip: 'Nouveau produit',
            onPressed: () => context.push('/shop/inventory/new'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: border),
        ),
      ),
      body: productsAsync.when(
        loading: () => _LoadingSkeleton(isDark: isDark),
        error: (e, _) => ErrorStateWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(productsNotifierProvider),
        ),
        data: (_) => Column(
          children: [
            // Stats bar
            Container(
              color: isDark ? AppColors.darkBg : surface,
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s16, AppSpacing.s12, AppSpacing.s16, AppSpacing.s12),
              child: Row(
                children: [
                  _StatChip(
                    icon: Symbols.inventory_2,
                    label: 'Articles',
                    value: '${resolved.length}',
                    color: AppColors.primary,
                    isDark: isDark,
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  _StatChip(
                    icon: Symbols.warning,
                    label: 'Alertes',
                    value: '$alertCount',
                    color: alertCount > 0 ? AppColors.warning : AppColors.success,
                    isDark: isDark,
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  _StatChip(
                    icon: Symbols.wallet,
                    label: 'Valeur (FCFA)',
                    value: totalValue > 0
                        ? '${fmt.format(totalValue / 1000)}K'
                        : '—',
                    color: AppColors.success,
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            // Tabs
            Container(
              color: isDark ? AppColors.darkBg : surface,
              child: TabBar(
                controller: _tabCtrl,
                labelColor: AppColors.primary,
                unselectedLabelColor:
                    isDark ? AppColors.gray400 : AppColors.gray500,
                indicatorColor: AppColors.primary,
                indicatorWeight: 2.5,
                labelStyle: AppTextStyles.label
                    .copyWith(fontWeight: FontWeight.w600, fontSize: 12),
                tabs: [
                  const Tab(text: 'Tous'),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Alertes'),
                        if (alertCount > 0) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$alertCount',
                              style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Tab(text: 'Mouvements'),
                  const Tab(text: 'Stats'),
                ],
              ),
            ),
            Divider(height: 1, color: border),

            // Search (hidden on Stats tab)
            if (_tabCtrl.index != 3)
              Container(
                color: isDark ? AppColors.darkBg : surface,
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s16, AppSpacing.s10, AppSpacing.s16, AppSpacing.s10),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  style: AppTextStyles.body.copyWith(color: textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Rechercher...',
                    hintStyle: AppTextStyles.caption.copyWith(
                        color: isDark ? AppColors.gray500 : AppColors.gray400),
                    prefixIcon: Icon(Symbols.search,
                        size: 20, color: AppColors.gray400),
                    filled: true,
                    fillColor:
                        isDark ? AppColors.darkBorder : AppColors.gray100,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.s10, horizontal: AppSpacing.s12),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusLarge),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

            // Tab views
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  // Tab 0 — Tous
                  _AllTab(
                    items: filtered,
                    isDark: isDark,
                    onMovement: (variantId, label) =>
                        InventoryMovementSheet.show(context,
                            variantId: variantId, variantLabel: label),
                    stockColor: _stockColor,
                    stockLabel: _stockLabel,
                  ),

                  // Tab 1 — Alertes
                  _AlertsTab(
                    outOfStock: outOfStock,
                    lowStock: lowStock,
                    isDark: isDark,
                  ),

                  // Tab 2 — Mouvements
                  _MovementsTab(
                    movementsAsync: movementsAsync,
                    nameMap: nameMap,
                    isDark: isDark,
                    fmt: fmt,
                    onRetry: () => ref.invalidate(stockMovementsProvider),
                  ),

                  // Tab 3 — Stats
                  _StatsTab(
                    totalValue: totalValue,
                    productStats: productStats,
                    isDark: isDark,
                    fmt: fmt,
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

// ── Stat chip ──────────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.s10, horizontal: AppSpacing.s10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          border: isDark ? Border.all(color: AppColors.darkBorder) : null,
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.04),
                      blurRadius: 6)
                ],
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSpacing.s10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(height: AppSpacing.s6),
            Text(
              value,
              style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: isDark ? AppColors.gray100 : AppColors.gray900),
            ),
            Text(
              label,
              style:
                  AppTextStyles.caption.copyWith(color: AppColors.gray500, fontSize: 10),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tab: Tous ──────────────────────────────────────────────────────────────────
class _AllTab extends StatelessWidget {
  final List<({String variantId, String name, int stock, int minStock, int maxStock, String? unit, String? location, double? costPrice})> items;
  final bool isDark;
  final void Function(String variantId, String label) onMovement;
  final Color Function(int stock, int minStock) stockColor;
  final String Function(int stock, int minStock) stockLabel;

  const _AllTab({
    required this.items,
    required this.isDark,
    required this.onMovement,
    required this.stockColor,
    required this.stockLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Symbols.inventory_2,
                size: 56,
                color: isDark ? AppColors.gray600 : AppColors.gray300),
            const SizedBox(height: AppSpacing.s12),
            Text(
              'Aucun article en inventaire',
              style: AppTextStyles.label.copyWith(
                  color: isDark ? AppColors.gray300 : AppColors.gray600,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              'Passez des commandes pour alimenter votre inventaire',
              style: AppTextStyles.caption.copyWith(color: AppColors.gray500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.s16),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final r = items[i];
        final color = stockColor(r.stock, r.minStock);
        final label = stockLabel(r.stock, r.minStock);
        final unit = r.unit ?? 'unités';

        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.s12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            border: isDark ? Border.all(color: AppColors.darkBorder) : null,
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        r.name,
                        style: AppTextStyles.label.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: isDark
                                ? AppColors.gray100
                                : AppColors.gray900),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.s10),
                      ),
                      child: Text(
                        label,
                        style: AppTextStyles.caption.copyWith(
                            color: color, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s10),
                _DetailRow(
                  label: 'Stock actuel',
                  value: '${r.stock} $unit',
                  isDark: isDark,
                ),
                if (r.minStock > 0 || r.maxStock > 0)
                  _DetailRow(
                    label: 'Min / Max',
                    value: '${r.minStock} / ${r.maxStock} $unit',
                    isDark: isDark,
                  ),
                if (r.location != null)
                  _DetailRow(
                    label: 'Emplacement',
                    value: r.location!,
                    isDark: isDark,
                  ),
                if (r.costPrice != null)
                  _DetailRow(
                    label: 'Prix d\'achat',
                    value: '${r.costPrice!.toStringAsFixed(0)} FCFA',
                    isDark: isDark,
                  ),
                Divider(
                    height: AppSpacing.s20,
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.gray100),
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Symbols.add_circle,
                        label: 'Réapprovisionner',
                        color: AppColors.primary,
                        onTap: () => onMovement(r.variantId, r.name),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    Expanded(
                      child: _ActionButton(
                        icon: Symbols.edit,
                        label: 'Ajuster',
                        color: AppColors.secondary,
                        onTap: () => onMovement(r.variantId, r.name),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  const _DetailRow(
      {required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.gray500, fontSize: 12)),
          Text(
            value,
            style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: isDark ? AppColors.gray200 : AppColors.gray800),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.s8, horizontal: AppSpacing.s10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.caption
                  .copyWith(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tab: Alertes ───────────────────────────────────────────────────────────────
class _AlertsTab extends StatelessWidget {
  final List<dynamic> outOfStock;
  final List<dynamic> lowStock;
  final bool isDark;
  const _AlertsTab(
      {required this.outOfStock,
      required this.lowStock,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (outOfStock.isEmpty && lowStock.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Symbols.check_circle,
                size: 56, color: AppColors.success),
            const SizedBox(height: AppSpacing.s12),
            Text(
              'Aucune alerte',
              style: AppTextStyles.label.copyWith(
                  color: isDark ? AppColors.gray300 : AppColors.gray700,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              'Tous vos stocks sont suffisants',
              style:
                  AppTextStyles.caption.copyWith(color: AppColors.gray500),
            ),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.s16),
      children: [
        if (outOfStock.isNotEmpty) ...[
          _AlertSectionHeader(
              title: 'Rupture de stock',
              count: outOfStock.length,
              color: AppColors.error,
              isDark: isDark),
          const SizedBox(height: AppSpacing.s8),
          ...outOfStock.map((r) => _AlertCard(
                icon: Symbols.cancel,
                color: AppColors.error,
                title: r.name as String,
                subtitle: 'Stock: 0 ${(r.unit as String?) ?? 'unités'}',
                isDark: isDark,
              )),
          const SizedBox(height: AppSpacing.s16),
        ],
        if (lowStock.isNotEmpty) ...[
          _AlertSectionHeader(
              title: 'Stock faible',
              count: lowStock.length,
              color: AppColors.warning,
              isDark: isDark),
          const SizedBox(height: AppSpacing.s8),
          ...lowStock.map((r) => _AlertCard(
                icon: Symbols.warning,
                color: AppColors.warning,
                title: r.name as String,
                subtitle:
                    'Stock: ${r.stock} / min ${r.minStock as int} ${(r.unit as String?) ?? 'unités'}',
                isDark: isDark,
              )),
        ],
      ],
    );
  }
}

class _AlertSectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final bool isDark;
  const _AlertSectionHeader(
      {required this.title,
      required this.count,
      required this.color,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: AppTextStyles.sectionTitle.copyWith(
              fontSize: 15,
              color: isDark ? AppColors.gray100 : AppColors.gray900),
        ),
        const SizedBox(width: AppSpacing.s8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppSpacing.s10),
          ),
          child: Text(
            '$count',
            style: AppTextStyles.caption
                .copyWith(color: color, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _AlertCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool isDark;
  const _AlertCard(
      {required this.icon,
      required this.color,
      required this.title,
      required this.subtitle,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s8),
      padding: const EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.label.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.gray100 : AppColors.gray900),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                      color: isDark ? AppColors.gray400 : AppColors.gray600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tab: Mouvements ────────────────────────────────────────────────────────────
class _MovementsTab extends StatelessWidget {
  final AsyncValue<List<StockMovement>> movementsAsync;
  final Map<String, String> nameMap;
  final bool isDark;
  final NumberFormat fmt;
  final VoidCallback onRetry;

  const _MovementsTab({
    required this.movementsAsync,
    required this.nameMap,
    required this.isDark,
    required this.fmt,
    required this.onRetry,
  });

  ({Color color, IconData icon, String label}) _typeInfo(MovementType type) {
    switch (type) {
      case MovementType.stockIn:
        return (
          color: AppColors.success,
          icon: Symbols.arrow_downward,
          label: 'Entrée'
        );
      case MovementType.stockOut:
        return (
          color: AppColors.error,
          icon: Symbols.arrow_upward,
          label: 'Sortie'
        );
      case MovementType.adjustment:
        return (
          color: AppColors.warning,
          icon: Symbols.swap_horiz,
          label: 'Ajustement'
        );
      case MovementType.damage:
        return (
          color: AppColors.error,
          icon: Symbols.broken_image,
          label: 'Perte'
        );
      case MovementType.stockReturn:
        return (
          color: AppColors.info,
          icon: Symbols.undo,
          label: 'Retour'
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return movementsAsync.when(
      loading: () => ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.s16),
        itemCount: 6,
        itemBuilder: (_, i) => const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.s8),
          child: ShimmerBox(height: 68),
        ),
      ),
      error: (e, _) =>
          ErrorStateWidget(message: e.toString(), onRetry: onRetry),
      data: (movements) {
        if (movements.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Symbols.swap_vert,
                    size: 56,
                    color: isDark ? AppColors.gray600 : AppColors.gray300),
                const SizedBox(height: AppSpacing.s12),
                Text(
                  'Aucun mouvement',
                  style: AppTextStyles.label.copyWith(
                      color: isDark ? AppColors.gray300 : AppColors.gray600,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        }
        final sorted = [...movements]
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.s16),
          itemCount: sorted.length,
          itemBuilder: (context, i) {
            final m = sorted[i];
            final info = _typeInfo(m.type);
            final label = nameMap[m.variantId] ??
                m.variantId.substring(0, 8).toUpperCase();
            final sign = m.type == MovementType.stockIn ||
                    m.type == MovementType.stockReturn
                ? '+'
                : m.type == MovementType.adjustment
                    ? '±'
                    : '-';
            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.s8),
              padding: const EdgeInsets.all(AppSpacing.s12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.white,
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusLarge),
                border: isDark
                    ? Border.all(color: AppColors.darkBorder)
                    : null,
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.04),
                            blurRadius: 6)
                      ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: info.color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(info.icon, size: 20, color: info.color),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: AppTextStyles.label.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.gray100
                                  : AppColors.gray900),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (m.reason != null && m.reason!.isNotEmpty)
                          Text(
                            m.reason!,
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.gray500),
                          ),
                        Text(
                          DateFormat('d MMM yyyy · HH:mm', 'fr_FR')
                              .format(m.createdAt),
                          style: AppTextStyles.caption.copyWith(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.gray500
                                  : AppColors.gray400),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$sign${m.quantity}',
                        style: AppTextStyles.label.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: info.color),
                      ),
                      Text(
                        info.label,
                        style: AppTextStyles.caption.copyWith(
                            color: AppColors.gray500, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── Tab: Stats ─────────────────────────────────────────────────────────────────
class _StatsTab extends StatelessWidget {
  final double totalValue;
  final Map<String, ({int qty, double amount})> productStats;
  final bool isDark;
  final NumberFormat fmt;

  const _StatsTab({
    required this.totalValue,
    required this.productStats,
    required this.isDark,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : AppColors.white;
    final textPrimary = isDark ? AppColors.gray100 : AppColors.gray900;
    final border = isDark ? AppColors.darkBorder : AppColors.gray100;

    final topProducts = productStats.entries.toList()
      ..sort((a, b) => b.value.amount.compareTo(a.value.amount));
    final maxAmount =
        topProducts.isEmpty ? 1.0 : topProducts.first.value.amount;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.s16),
      children: [
        // Total value card
        Container(
          padding: const EdgeInsets.all(AppSpacing.s16),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            border:
                isDark ? Border.all(color: AppColors.darkBorder) : null,
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.05),
                        blurRadius: 8)
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Valeur du stock',
                  style: AppTextStyles.sectionTitle
                      .copyWith(fontSize: 15, color: textPrimary)),
              const SizedBox(height: AppSpacing.s8),
              Text(
                totalValue > 0
                    ? '${fmt.format(totalValue)} FCFA'
                    : '— FCFA',
                style: AppTextStyles.price.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s16),

        // Top products from order history
        if (topProducts.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(AppSpacing.s16),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
              border:
                  isDark ? Border.all(color: AppColors.darkBorder) : null,
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.05),
                          blurRadius: 8)
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Produits les plus achetés',
                    style: AppTextStyles.sectionTitle
                        .copyWith(fontSize: 15, color: textPrimary)),
                const SizedBox(height: AppSpacing.s12),
                ...topProducts.take(5).map((e) {
                  final ratio =
                      (e.value.amount / maxAmount).clamp(0.0, 1.0);
                  return Column(
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    e.key,
                                    style: AppTextStyles.label.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: textPrimary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${e.value.qty} unités',
                                    style: AppTextStyles.caption.copyWith(
                                        color: AppColors.gray500),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${fmt.format(e.value.amount)} FCFA',
                              style: AppTextStyles.label.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                      LinearProgressIndicator(
                        value: ratio,
                        backgroundColor: isDark
                            ? AppColors.darkBorder
                            : AppColors.gray100,
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                        minHeight: 4,
                      ),
                      Divider(height: AppSpacing.s16, color: border),
                    ],
                  );
                }),
              ],
            ),
          ),
        const SizedBox(height: 80),
      ],
    );
  }
}

// ── Loading skeleton ───────────────────────────────────────────────────────────
class _LoadingSkeleton extends StatelessWidget {
  final bool isDark;
  const _LoadingSkeleton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.s16),
      itemCount: 4,
      itemBuilder: (_, i) => const Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.s12),
        child: ShimmerBox(height: 130),
      ),
    );
  }
}
