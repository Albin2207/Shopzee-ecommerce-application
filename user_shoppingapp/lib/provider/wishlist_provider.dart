import 'package:flutter/material.dart';
import 'package:user_shoppingapp/controllers/database_service.dart';

class WishlistProvider with ChangeNotifier {
  final DbService _dbService = DbService();
  List<String> _wishlistedItems = [];

  List<String> get wishlistedItems => _wishlistedItems;

  Future<void> toggleWishlist(String productId) async {
    if (_wishlistedItems.contains(productId)) {
      await _dbService.removeFromWishlist(productId: productId);
      _wishlistedItems.remove(productId);
    } else {
      await _dbService.addToWishlist(productId: productId);
      _wishlistedItems.add(productId);
    }
    notifyListeners();
  }

  Future<void> loadWishlist() async {
    _wishlistedItems = await _dbService.getWishlistProductIds();
    notifyListeners();
  }

  bool isWishlisted(String productId) {
    return _wishlistedItems.contains(productId);
  }
}
