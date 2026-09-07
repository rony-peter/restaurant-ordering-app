import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/menu_models.dart';

class CartState {
  final List<CartItem> items;
  final String? restaurantId;
  final String? tableId;

  CartState({this.items = const [], this.restaurantId, this.tableId});

  double get totalAmount => items.fold(0, (sum, item) => sum + item.totalPrice);

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  CartState copyWith({
    List<CartItem>? items,
    String? restaurantId,
    String? tableId,
  }) {
    return CartState(
      items: items ?? this.items,
      restaurantId: restaurantId ?? this.restaurantId,
      tableId: tableId ?? this.tableId,
    );
  }
}

class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() {
    return CartState();
  }

  void setTableContext(String restaurantId, String tableId) {
    state = state.copyWith(restaurantId: restaurantId, tableId: tableId);
  }

  void addItem(MenuItem menuItem) {
    final existingIndex = state.items.indexWhere(
      (i) => i.menuItem.id == menuItem.id,
    );

    if (existingIndex >= 0) {
      final updatedItems = List<CartItem>.from(state.items);
      updatedItems[existingIndex].quantity += 1;
      state = state.copyWith(items: updatedItems);
    } else {
      state = state.copyWith(
        items: [
          ...state.items,
          CartItem(menuItem: menuItem),
        ],
      );
    }
  }

  void removeItem(String menuItemId) {
    final existingIndex = state.items.indexWhere(
      (i) => i.menuItem.id == menuItemId,
    );

    if (existingIndex >= 0) {
      final updatedItems = List<CartItem>.from(state.items);
      if (updatedItems[existingIndex].quantity > 1) {
        updatedItems[existingIndex].quantity -= 1;
      } else {
        updatedItems.removeAt(existingIndex);
      }
      state = state.copyWith(items: updatedItems);
    }
  }

  void clearCart() {
    state = state.copyWith(items: []);
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(() {
  return CartNotifier();
});
