import 'package:uni_tech/models/Product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartItem {
  CartItem({required this.product, this.quantity = 1});

  final Product product;
  final int quantity;

  double get subtotal => product.price * quantity;

  CartItem copyWith({Product? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super(const []);

  void addItem(Product product) {
    final existingIndex = state.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex != -1) {
      final updated = state[existingIndex].copyWith(
        quantity: state[existingIndex].quantity + 1,
      );
      state = [
        ...state.sublist(0, existingIndex),
        updated,
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      state = [...state, CartItem(product: product)];
    }
  }

  void removeItem(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  void updateQuantity(String productId, int delta) {
    final index = state.indexWhere((item) => item.product.id == productId);
    if (index == -1) return;

    final newQuantity = state[index].quantity + delta;
    if (newQuantity < 1) {
      removeItem(productId);
      return;
    }

    final updated = state[index].copyWith(quantity: newQuantity);
    state = [...state.sublist(0, index), updated, ...state.sublist(index + 1)];
  }

  int get totalItems {
    return state.fold(0, (sum, item) => sum + item.quantity);
  }

  double get totalAmount {
    return state.fold(0, (sum, item) => sum + item.subtotal);
  }

  void clear() {
    state = const [];
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>(
  (ref) => CartNotifier(),
);
