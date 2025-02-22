
import 'package:flutter/material.dart';

class WishlistSelectionProvider with ChangeNotifier {
  bool _isSelectionMode = false;
  Set<String> _selectedProducts = {};

  bool get isSelectionMode => _isSelectionMode;
  Set<String> get selectedProducts => _selectedProducts;

  void toggleSelectionMode() {
    _isSelectionMode = !_isSelectionMode;
    _selectedProducts.clear();
    notifyListeners();
  }

  void toggleProductSelection(String productId) {
    if (_selectedProducts.contains(productId)) {
      _selectedProducts.remove(productId);
    } else {
      _selectedProducts.add(productId);
    }
    notifyListeners();
  }

  void toggleSelectAll(List<String> productIds) {
    if (_selectedProducts.length == productIds.length) {
      _selectedProducts.clear();
    } else {
      _selectedProducts = productIds.toSet();
    }
    notifyListeners();
  }

  void clearSelection() {
    _isSelectionMode = false;
    _selectedProducts.clear();
    notifyListeners();
  }
}