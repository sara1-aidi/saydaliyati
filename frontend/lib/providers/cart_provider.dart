import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

const int kDeliveryFee = 400;
const int kFreeDeliveryThreshold = 5000;

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => const [];

  void add(Product product, {int quantity = 1}) {
    if (!product.inStock || quantity < 1) return;
    final existing = state.where((i) => i.product.id == product.id);
    if (existing.isEmpty) {
      state = [
        ...state,
        CartItem(product: product, quantity: min(quantity, product.quantity)),
      ];
    } else {
      final next = min(existing.first.quantity + quantity, product.quantity);
      _setQuantity(product.id, next);
    }
  }

  void increment(String productId) {
    final item = state.firstWhere((i) => i.product.id == productId);
    if (item.quantity < item.product.quantity) {
      _setQuantity(productId, item.quantity + 1);
    }
  }

  void decrement(String productId) {
    final item = state.firstWhere((i) => i.product.id == productId);
    if (item.quantity > 1) _setQuantity(productId, item.quantity - 1);
  }

  void remove(String productId) {
    state = state.where((i) => i.product.id != productId).toList();
  }

  void clear() => state = const [];

  void _setQuantity(String productId, int quantity) {
    state = [
      for (final i in state)
        if (i.product.id == productId) i.copyWith(quantity: quantity) else i,
    ];
  }
}

final cartProvider =
    NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);

final cartCountProvider = Provider<int>(
  (ref) => ref.watch(cartProvider).fold<int>(0, (s, i) => s + i.quantity),
);

final cartSubtotalProvider = Provider<int>(
  (ref) => ref.watch(cartProvider).fold<int>(0, (s, i) => s + i.lineTotal),
);

final deliveryFeeProvider = Provider<int>((ref) {
  final subtotal = ref.watch(cartSubtotalProvider);
  return (subtotal == 0 || subtotal >= kFreeDeliveryThreshold) ? 0 : kDeliveryFee;
});

final cartTotalProvider = Provider<int>(
  (ref) => ref.watch(cartSubtotalProvider) + ref.watch(deliveryFeeProvider),
);
