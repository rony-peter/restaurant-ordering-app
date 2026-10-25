import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/menu_models.dart';

class CartState {
  final List<CartItem> items;
  final String? restaurantId;
  final String? tableId;
  final double taxPercentage;
  final double packagingCharge;
  final double serviceChargePercent;

  CartState({
    this.items = const [],
    this.restaurantId,
    this.tableId,
    this.taxPercentage = 5.0,
    this.packagingCharge = 0.0,
    this.serviceChargePercent = 0.0,
  });

  double get subtotal => items.fold(0, (sum, item) => sum + item.totalPrice);
  
  double get serviceChargeAmount => (subtotal * serviceChargePercent) / 100;

  // Tax base usually includes food subtotal + service charge (depending on your configuration)
  double get taxAmount => ((subtotal + serviceChargeAmount + packagingCharge) * taxPercentage) / 100;
  
  double get totalAmount => subtotal + serviceChargeAmount + packagingCharge + taxAmount;

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  CartState copyWith({
    List<CartItem>? items,
    String? restaurantId,
    String? tableId,
    double? taxPercentage,
    double? packagingCharge,
    double? serviceChargePercent,
  }) {
    return CartState(
      items: items ?? this.items,
      restaurantId: restaurantId ?? this.restaurantId,
      tableId: tableId ?? this.tableId,
      taxPercentage: taxPercentage ?? this.taxPercentage,
      packagingCharge: packagingCharge ?? this.packagingCharge,
      serviceChargePercent: serviceChargePercent ?? this.serviceChargePercent,
    );
  }
}

class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() {
    return CartState();
  }

  void setTableContext(
    String restaurantId, 
    String tableId, 
    double taxPercentage, {
    double packagingCharge = 0.0,
    double serviceChargePercent = 0.0,
  }) {
    state = state.copyWith(
      restaurantId: restaurantId,
      tableId: tableId,
      taxPercentage: taxPercentage,
      packagingCharge: packagingCharge,
      serviceChargePercent: serviceChargePercent,
    );
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