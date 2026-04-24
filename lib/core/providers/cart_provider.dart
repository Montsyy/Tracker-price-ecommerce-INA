import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_price_tracker/features/product/data/models/product_model.dart';

class CartProvider extends ChangeNotifier {
  List<Product> _items = [];
  static const String _cartPrefsKey = 'cart_items';

  CartProvider() {
    _loadCartData();
  }

  List<Product> get items => _items;

  int get itemCount => _items.length;

  double get totalPrice => _items.fold(0, (sum, item) => sum + item.price);

  Future<void> _loadCartData() async {
    final prefs = await SharedPreferences.getInstance();
    final cartString = prefs.getString(_cartPrefsKey);
    if (cartString != null) {
      try {
        final List<dynamic> decoded = json.decode(cartString);
        _items = decoded.map((item) => Product.fromJson(item)).toList();
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading cart data: $e');
      }
    }
  }

  Future<void> _saveCartData() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(_items.map((item) => item.toJson()).toList());
    await prefs.setString(_cartPrefsKey, encoded);
  }

  void addToCart(Product product) {
    _items.add(product);
    _saveCartData();
    notifyListeners();
  }

  void removeFromCart(Product product) {
    _items.remove(product);
    _saveCartData();
    notifyListeners();
  }
}
