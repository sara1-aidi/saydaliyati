import '../core/api_client.dart';
import '../models/product.dart';
import 'mock_products.dart';

abstract class ProductRepository {
  Future<List<Product>> fetchProducts({String? search});
  Future<Product> createProduct(Product product);
  Future<Product> updateProduct(Product product);
  Future<void> deleteProduct(String id);
}

/// Talks to the FastAPI server.
class ApiProductRepository implements ProductRepository {
  ApiProductRepository(this._api);
  final ApiClient _api;

  @override
  Future<List<Product>> fetchProducts({String? search}) async {
    final data = await _api.get(
      '/products',
      query: {if (search != null && search.trim().isNotEmpty) 'search': search.trim()},
    ) as List;
    return data.map((j) => Product.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<Product> createProduct(Product product) async {
    final data = await _api.post('/products', body: product.toJson());
    return Product.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<Product> updateProduct(Product product) async {
    final data = await _api.put('/products/${product.id}', body: product.toJson());
    return Product.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _api.delete('/products/$id');
  }
}

/// In-memory fake used when `kUseMockData = true` (no server needed).
class MockProductRepository implements ProductRepository {
  final List<Product> _items = [...mockProducts];

  Future<void> _latency() => Future<void>.delayed(const Duration(milliseconds: 400));

  @override
  Future<List<Product>> fetchProducts({String? search}) async {
    await _latency();
    return List.unmodifiable(_items);
  }

  @override
  Future<Product> createProduct(Product product) async {
    await _latency();
    final created = product.withId('m${DateTime.now().millisecondsSinceEpoch}');
    _items.add(created);
    return created;
  }

  @override
  Future<Product> updateProduct(Product product) async {
    await _latency();
    final i = _items.indexWhere((p) => p.id == product.id);
    if (i != -1) _items[i] = product;
    return product;
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _latency();
    _items.removeWhere((p) => p.id == id);
  }
}
