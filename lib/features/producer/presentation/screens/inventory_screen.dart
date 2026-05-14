import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';
import 'package:banabana_b2b/core/theme/app_spacing.dart';
import 'package:banabana_b2b/features/producer/providers/inventory_providers.dart';
import 'package:banabana_b2b/features/producer/providers/product_providers.dart';
import 'package:banabana_b2b/features/producer/providers/category_providers.dart';
import 'package:banabana_b2b/shared/models/category.dart';
import 'package:banabana_b2b/features/producer/presentation/widgets/inventory_movement_sheet.dart';
import 'package:banabana_b2b/shared/models/inventory.dart';
import 'package:banabana_b2b/shared/models/product.dart';
import 'package:banabana_b2b/shared/widgets/error_state_widget.dart';
import 'package:banabana_b2b/shared/widgets/loading_shimmer.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen>
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

  // Resolves variantId → product + variant label
  ({String label, String category, int stock, int minStock, int maxStock, String? unit})
      _resolveVariant(String variantId, List<Product> products, List<Category> categories) {
    for (final p in products) {
      for (final v in p.variants) {
        if (v.id == variantId) {
          return (
            label: '${p.title} — ${v.label}',
            category: resolveCategory(p.category, categories),
            stock: v.stock,
            minStock: v.minStock ?? 0,
            maxStock: v.maxStock ?? 0,
            unit: v.wholesaleUnit,
          );
        }
      }
    }
    return (
      label: variantId.substring(0, 8).toUpperCase(),
      category: '',
      stock: 0,
      minStock: 0,
      maxStock: 0,
      unit: null,
    );
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
    final productsAsync = ref.watch(productsNotifierProvider);
    final movementsAsync = ref.watch(stockMovementsProvider);
    final alertsAsync = ref.watch(inventoryAlertsProvider);

    final products = productsAsync.valueOrNull ?? [];
    final items = inventoryAsync.valueOrNull ?? [];
    final alerts = alertsAsync.valueOrNull ?? [];
    final categories = ref.watch(allCategoriesProvider).valueOrNull ?? [];

    // Stats
    final totalValue = items.fold<double>(0, (s, i) => s + (i.totalValue ?? 0));
    final alertCount = alerts.length;

    // Filtered + resolved inventory items
    final resolved = items.map((inv) {
      final v = _resolveVariant(inv.variantId, products, categories);
      return (inv: inv, meta: v);
    }).toList();
    final filtered = _query.isEmpty
        ? resolved
        : resolved
            .where((r) =>
                r.meta.label.toLowerCase().contains(_query.toLowerCase()) ||
                r.meta.category.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    // Alert groups
    final outOfStock = resolved.where((r) => r.meta.stock == 0).toList();
    final lowStock = resolved
        .where((r) => r.meta.stock > 0 && r.meta.minStock > 0 && r.meta.stock <= r.meta.minStock)
        .toList();

    // Category stats
    final Map<String, ({int count, double value})> catStats = {};
    for (final r in resolved) {
      final cat = r.meta.category.isEmpty ? 'Autre' : r.meta.category;
      final prev = catStats[cat];
      catStats[cat] = (
        count: (prev?.count ?? 0) + r.meta.stock,
        value: (prev?.value ?? 0) + (r.inv.totalValue ?? 0),
      );
    }

    final fmt = NumberFormat('#,###', 'fr_FR');

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg : surface,
        elevation: 0,
        title: Text(
          'Gestion de Stock',
          style: AppTextStyles.sectionTitle.copyWith(color: textPrimary),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: border),
        ),
      ),
      body: inventoryAsync.when(
        loading: () => _LoadingSkeleton(isDark: isDark),
        error: (e, _) => ErrorStateWidget(
          message: e.toString(),
          onRetry: () => ref.read(inventoryNotifierProvider.notifier).load(),
        ),
        data: (_) => Column(
          children: [
            // ── Stats bar ────────────────────────────────────────
            Container(
              color: isDark ? AppColors.darkBg : surface,
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s16, AppSpacing.s12, AppSpacing.s16, AppSpacing.s12),
              child: Row(
                children: [
                  _StatChip(
                    icon: Symbols.inventory_2,
                    label: 'Articles',
                    value: '${items.length}',
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
                    value: '${fmt.format(totalValue / 1000)}K',
                    color: AppColors.success,
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            // ── Tabs ─────────────────────────────────────────────
            Container(
              color: isDark ? AppColors.darkBg : surface,
              child: TabBar(
                controller: _tabCtrl,
                labelColor: AppColors.primary,
                unselectedLabelColor: isDark ? AppColors.gray400 : AppColors.gray500,
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
                        if ((outOfStock.length + lowStock.length) > 0) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${outOfStock.length + lowStock.length}',
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

            // ── Search (hidden on Stats tab) ──────────────────────
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
                    hintStyle: AppTextStyles.caption
                        .copyWith(color: isDark ? AppColors.gray500 : AppColors.gray400),
                    prefixIcon: Icon(Symbols.search,
                        size: 20,
                        color: isDark ? AppColors.gray400 : AppColors.gray400),
                    filled: true,
                    fillColor: isDark ? AppColors.darkBorder : AppColors.gray100,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.s10, horizontal: AppSpacing.s12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

            // ── Tab views ────────────────────────────────────────
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
                    products: products,
                    isDark: isDark,
                    fmt: fmt,
                    onRetry: () => ref.invalidate(stockMovementsProvider),
                  ),

                  // Tab 3 — Stats
                  _StatsTab(
                    totalValue: totalValue,
                    catStats: catStats,
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

// ── Stat chip ─────────────────────────────────────────────────────────────────
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
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.gray500, fontSize: 10),
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

// ── Tab: Tous ─────────────────────────────────────────────────────────────────
class _AllTab extends StatelessWidget {
  final List<({Inventory inv, ({String label, String category, int stock, int minStock, int maxStock, String? unit}) meta})>
      items;
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
                size: 56, color: isDark ? AppColors.gray600 : AppColors.gray300),
            const SizedBox(height: AppSpacing.s12),
            Text(
              'Aucun article en inventaire',
              style: AppTextStyles.label.copyWith(
                  color: isDark ? AppColors.gray300 : AppColors.gray600,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              'Créez des produits avec des variantes pour gérer votre stock',
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
        final color = stockColor(r.meta.stock, r.meta.minStock);
        final label = stockLabel(r.meta.stock, r.meta.minStock);
        final ratio = (r.meta.maxStock > 0)
            ? (r.meta.stock / r.meta.maxStock).clamp(0.0, 1.0)
            : 0.0;
        final unit = r.meta.unit ?? 'unités';

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
                // Header: name + badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.meta.label,
                            style: AppTextStyles.label.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: isDark
                                    ? AppColors.gray100
                                    : AppColors.gray900),
                          ),
                          if (r.meta.category.isNotEmpty)
                            Text(
                              r.meta.category,
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.gray500),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppSpacing.s10),
                      ),
                      child: Text(
                        label,
                        style: AppTextStyles.caption.copyWith(
                            color: color, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),

                // Stock progress bar
                const SizedBox(height: AppSpacing.s10),
                LinearProgressIndicator(
                  value: ratio,
                  backgroundColor: isDark
                      ? AppColors.darkBorder
                      : AppColors.gray100,
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                  minHeight: 5,
                ),
                const SizedBox(height: AppSpacing.s8),

                // Details
                _DetailRow(
                  label: 'Stock actuel',
                  value: '${r.meta.stock} $unit',
                  isDark: isDark,
                ),
                if (r.meta.minStock > 0 || r.meta.maxStock > 0)
                  _DetailRow(
                    label: 'Min / Max',
                    value: '${r.meta.minStock} / ${r.meta.maxStock} $unit',
                    isDark: isDark,
                  ),
                if (r.inv.location != null)
                  _DetailRow(
                    label: 'Emplacement',
                    value: r.inv.location!,
                    isDark: isDark,
                  ),
                if (r.inv.warehouse != null)
                  _DetailRow(
                    label: 'Entrepôt',
                    value: r.inv.warehouse!,
                    isDark: isDark,
                  ),

                // Actions
                Divider(
                    height: AppSpacing.s20,
                    color: isDark ? AppColors.darkBorder : AppColors.gray100),
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Symbols.add_circle,
                        label: 'Réapprovisionner',
                        color: AppColors.primary,
                        onTap: () =>
                            InventoryMovementSheet.show(context,
                                variantId: r.inv.variantId,
                                variantLabel: r.meta.label),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    Expanded(
                      child: _ActionButton(
                        icon: Symbols.edit,
                        label: 'Ajuster',
                        color: AppColors.secondary,
                        onTap: () =>
                            InventoryMovementSheet.show(context,
                                variantId: r.inv.variantId,
                                variantLabel: r.meta.label),
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

// ── Tab: Alertes ──────────────────────────────────────────────────────────────
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
            Icon(Symbols.check_circle,
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
              style: AppTextStyles.caption.copyWith(color: AppColors.gray500),
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
                title: r.meta.label,
                subtitle: 'Stock: 0 ${r.meta.unit ?? 'unités'}',
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
                title: r.meta.label,
                subtitle:
                    'Stock: ${r.meta.stock} / min ${r.meta.minStock} ${r.meta.unit ?? 'unités'}',
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
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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

// ── Tab: Mouvements ───────────────────────────────────────────────────────────
class _MovementsTab extends StatelessWidget {
  final AsyncValue<List<StockMovement>> movementsAsync;
  final List<Product> products;
  final bool isDark;
  final NumberFormat fmt;
  final VoidCallback onRetry;

  const _MovementsTab({
    required this.movementsAsync,
    required this.products,
    required this.isDark,
    required this.fmt,
    required this.onRetry,
  });

  String _resolveLabel(String variantId) {
    for (final p in products) {
      for (final v in p.variants) {
        if (v.id == variantId) return '${p.title} — ${v.label}';
      }
    }
    return variantId.substring(0, 8).toUpperCase();
  }

  ({Color color, IconData icon, String label}) _typeInfo(MovementType type) {
    switch (type) {
      case MovementType.stockIn:
        return (color: AppColors.success, icon: Symbols.arrow_downward, label: 'Entrée');
      case MovementType.stockOut:
        return (color: AppColors.error, icon: Symbols.arrow_upward, label: 'Sortie');
      case MovementType.adjustment:
        return (color: AppColors.warning, icon: Symbols.swap_horiz, label: 'Ajustement');
      case MovementType.damage:
        return (color: AppColors.error, icon: Symbols.broken_image, label: 'Perte');
      case MovementType.stockReturn:
        return (color: AppColors.info, icon: Symbols.undo, label: 'Retour');
    }
  }

  @override
  Widget build(BuildContext context) {
    return movementsAsync.when(
      loading: () => ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.s16),
        itemCount: 6,
        itemBuilder: (_, __) => const Padding(
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
            final label = _resolveLabel(m.variantId);
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
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.gray500, fontSize: 10),
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
  final Map<String, ({int count, double value})> catStats;
  final bool isDark;
  final NumberFormat fmt;

  const _StatsTab({
    required this.totalValue,
    required this.catStats,
    required this.isDark,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : AppColors.white;
    final textPrimary = isDark ? AppColors.gray100 : AppColors.gray900;
    final border = isDark ? AppColors.darkBorder : AppColors.gray100;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.s16),
      children: [
        // Total value
        Container(
          padding: const EdgeInsets.all(AppSpacing.s16),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            border: isDark ? Border.all(color: AppColors.darkBorder) : null,
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
              Text('Valeur totale du stock',
                  style: AppTextStyles.sectionTitle.copyWith(
                      fontSize: 15, color: textPrimary)),
              const SizedBox(height: AppSpacing.s8),
              Text(
                '${fmt.format(totalValue)} FCFA',
                style: AppTextStyles.price.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s16),

        // By category
        if (catStats.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(AppSpacing.s16),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
              border: isDark ? Border.all(color: AppColors.darkBorder) : null,
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
                Text('Répartition par catégorie',
                    style: AppTextStyles.sectionTitle.copyWith(
                        fontSize: 15, color: textPrimary)),
                const SizedBox(height: AppSpacing.s12),
                ...catStats.entries.map((e) => Column(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  e.key,
                                  style: AppTextStyles.label.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: textPrimary),
                                ),
                              ),
                              Text(
                                '${e.value.count} unités • ${fmt.format(e.value.value)} FCFA',
                                style: AppTextStyles.caption.copyWith(
                                    color: AppColors.gray500),
                              ),
                            ],
                          ),
                        ),
                        Divider(height: 1, color: border),
                      ],
                    )),
              ],
            ),
          ),
        const SizedBox(height: 80),
      ],
    );
  }
}

// ── Loading skeleton ──────────────────────────────────────────────────────────
class _LoadingSkeleton extends StatelessWidget {
  final bool isDark;
  const _LoadingSkeleton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.s16),
      itemCount: 4,
      itemBuilder: (_, __) => const Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.s12),
        child: ShimmerBox(height: 130),
      ),
    );
  }
}
