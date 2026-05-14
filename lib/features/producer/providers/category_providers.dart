import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:banabana_b2b/core/api/api_client.dart';
import 'package:banabana_b2b/features/producer/data/category_repository.dart';
import 'package:banabana_b2b/shared/models/category.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(ref.watch(apiClientProvider));
});

/// All global categories (for display + resolve)
final allCategoriesProvider = FutureProvider<List<Category>>((ref) {
  return ref.watch(categoryRepositoryProvider).getAll();
});

/// Producer's own categories (for product form)
final myCategoriesProvider = FutureProvider<List<Category>>((ref) {
  return ref.watch(categoryRepositoryProvider).getMyCategories();
});

/// Resolves a category string (may be UUID or name) to a display name.
/// Falls back to the raw value if not found.
String resolveCategory(String raw, List<Category> categories) {
  if (raw.isEmpty) return '';
  // Try match by ID first (UUID from old app)
  final byId = categories.where((c) => c.id == raw).firstOrNull;
  if (byId != null) return byId.name;
  // Already a name — return as-is
  return raw;
}

/// Resolves a category string to a Category object (for icon access).
Category? resolveCategoryObj(String raw, List<Category> categories) {
  if (raw.isEmpty) return null;
  final byId = categories.where((c) => c.id == raw).firstOrNull;
  if (byId != null) return byId;
  final byName = categories.where((c) => c.name == raw).firstOrNull;
  return byName;
}

class CategoriesNotifier extends AsyncNotifier<List<Category>> {
  @override
  Future<List<Category>> build() =>
      ref.read(categoryRepositoryProvider).getMyCategories();

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(categoryRepositoryProvider).getMyCategories(),
    );
  }

  Future<void> create({
    required String name,
    required String slug,
    String? icon,
    int order = 0,
  }) async {
    final cat = await ref.read(categoryRepositoryProvider).create(
      name: name, slug: slug, icon: icon, order: order,
    );
    state = state.whenData((list) => [...list, cat]);
  }

  Future<void> edit(
    String id, {
    required String name,
    required String slug,
    String? icon,
    int? order,
  }) async {
    final cat = await ref.read(categoryRepositoryProvider).update(
      id, name: name, slug: slug, icon: icon, order: order,
    );
    state = state.whenData(
      (list) => list.map((c) => c.id == id ? cat : c).toList(),
    );
  }

  Future<void> delete(String id) async {
    await ref.read(categoryRepositoryProvider).delete(id);
    state = state.whenData((list) => list.where((c) => c.id != id).toList());
  }
}

final categoriesNotifierProvider =
    AsyncNotifierProvider<CategoriesNotifier, List<Category>>(
  CategoriesNotifier.new,
);
