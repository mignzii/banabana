import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/features/wholesaler/providers/catalog_providers.dart';

class FilterSheet extends ConsumerStatefulWidget {
  const FilterSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const FilterSheet(),
    );
  }

  @override
  ConsumerState<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<FilterSheet> {
  String? _selectedCategory;
  final _minCtrl = TextEditingController();
  final _maxCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final params = ref.read(catalogSearchParamsProvider);
    _selectedCategory = params.category;
    if (params.priceMin != null) _minCtrl.text = '${params.priceMin!.toInt()}';
    if (params.priceMax != null) _maxCtrl.text = '${params.priceMax!.toInt()}';
  }

  @override
  void dispose() {
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  void _apply() {
    ref.read(catalogSearchParamsProvider.notifier).update(
          (state) => state.copyWith(
            category: _selectedCategory,
            priceMin: _minCtrl.text.isNotEmpty
                ? double.tryParse(_minCtrl.text)
                : null,
            priceMax: _maxCtrl.text.isNotEmpty
                ? double.tryParse(_maxCtrl.text)
                : null,
            page: 1,
          ),
        );
    Navigator.pop(context);
  }

  void _reset() {
    ref.read(catalogSearchParamsProvider.notifier).update(
          (state) => state.copyWith(
            category: null,
            priceMin: null,
            priceMax: null,
            page: 1,
          ),
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(catalogCategoriesProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Filtres',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text('Catégorie', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          categoriesAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const Text('Erreur chargement catégories'),
            data: (cats) => Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                FilterChip(
                  label: const Text('Toutes'),
                  selected: _selectedCategory == null,
                  onSelected: (_) =>
                      setState(() => _selectedCategory = null),
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                ),
                ...cats.map(
                  (c) => FilterChip(
                    label: Text(c),
                    selected: _selectedCategory == c,
                    onSelected: (_) =>
                        setState(() => _selectedCategory = c),
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Prix (FCFA)', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Min',
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _maxCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Max',
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _reset,
                  child: const Text('Réinitialiser'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _apply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Appliquer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
