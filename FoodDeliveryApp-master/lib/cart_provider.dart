import 'package:flutter/material.dart';

class CartItem {
  final String name;
  final double price;
  final int quantity;
  final String size;
  final String? imageUrl; // Nullable imageUrl

  CartItem({
    required this.name,
    required this.price,
    required this.quantity,
    required this.size,
    this.imageUrl, // Nullable
  });

  CartItem copyWith({int? quantity}) {
    return CartItem(
      name: name,
      price: price,
      quantity: quantity ?? this.quantity,
      size: size,
      imageUrl: imageUrl,
    );
  }
}


class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  String? _currentRestaurantId; // Track the restaurant ID of the current cart
  double _totalPrice = 0.0;

  List<CartItem> get items => _items;
  double get totalPrice => _totalPrice;
  String? get currentRestaurantId => _currentRestaurantId;

  /// Add item to cart
  void addItem({
    required String name,
    required double price,
    required String size,
    required String imageUrl, // Accept the image URL
    required String restaurantId,
  }) {
    // Check if the cart belongs to the same restaurant
    if (_currentRestaurantId != null && _currentRestaurantId != restaurantId) {
      clearCart(); // Clear the cart if the restaurant changes
    }

    // Set the restaurant ID for the current cart
    _currentRestaurantId = restaurantId;

    // Check if the item already exists in the cart
    final index = _items.indexWhere((item) => item.name == name && item.size == size);
    if (index >= 0) {
      // Update quantity if item exists
      _items[index] = _items[index].copyWith(quantity: _items[index].quantity + 1);
    } else {
      // Add new item to the cart
      _items.add(CartItem(
        name: name,
        price: price,
        quantity: 1,
        size: size,
        imageUrl: imageUrl, // Add image URL to the cart item
      ));
    }

    _calculateTotalPrice();
    notifyListeners();
  }

  /// Clear the cart and reset restaurant ID
  void clearCart() {
    _items = [];
    _totalPrice = 0.0;
    _currentRestaurantId = null;
    notifyListeners();
  }

  /// Remove a specific item from the cart
  void removeItem(String name, String size) {
    _items.removeWhere((item) => item.name == name && item.size == size);
    _calculateTotalPrice();
    notifyListeners();
  }

  /// Update the quantity of a specific item
  void updateItemQuantity(String name, String size, int quantity) {
    final index = _items.indexWhere((item) => item.name == name && item.size == size);
    if (index >= 0) {
      if (quantity > 0) {
        // Update quantity if it's greater than 0
        _items[index] = _items[index].copyWith(quantity: quantity);
      } else {
        // Remove the item if quantity is 0
        removeItem(name, size);
      }
    }
    _calculateTotalPrice();
    notifyListeners();
  }

  /// Calculate total price of the cart
  void _calculateTotalPrice() {
    _totalPrice = _items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  int getItemQuantity(String name, String size) {
    final index = _items.indexWhere((item) => item.name == name && item.size == size);
    if (index >= 0) {
      return _items[index].quantity;
    }
    return 0; // Return 0 if the item is not found
  }
}
