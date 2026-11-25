import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_config.dart';
import '../data/product_repository.dart';
import '../models/product.dart';
import 'auth_provider.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  if (kUseMockData) return MockProductRepository();
  return ApiProductRepository(ref.watch(apiClientProvider));
});

/// Re-fetches automatically when a different user signs in.
final productsProvider = FutureProvider<List<Product>>((ref) {
  ref.watch(authProvider.select((u) => u?.id));
  return ref.watch(productRepositoryProvider).fetchProducts();
});

final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedCategoryProvider = StateProvider<ProductCategory?>((ref) => null);

final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final category = ref.watch(selectedCategoryProvider);

  return ref.watch(productsProvider).whenData(
        (products) => products.where((p) {
          final matchesCategory = category == null || p.category == category;
          final matchesQuery = query.isEmpty ||
              p.name.toLowerCase().contains(query) ||
              p.brand.toLowerCase().contains(query) ||
              p.category.label.toLowerCase().contains(query);
          return matchesCategory && matchesQuery;
        }).toList(),
      );
});
