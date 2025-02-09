import 'package:flutter/material.dart';
import 'package:user_shoppingapp/controllers/database_service.dart';

class WishlistProvider with ChangeNotifier {
  final DbService _dbService = DbService();
  List<String> _wishlistedItems = [];
  bool _isLoading = false;
  String? _error;

  List<String> get wishlistedItems => _wishlistedItems;
   bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> toggleWishlist(String productId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_wishlistedItems.contains(productId)) {
        await _dbService.removeFromWishlist(productId: productId);
        _wishlistedItems.remove(productId);
      } else {
        await _dbService.addToWishlist(productId: productId);
        _wishlistedItems.add(productId);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadWishlist() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      _wishlistedItems = await _dbService.getWishlistProductIds();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isWishlisted(String productId) => _wishlistedItems.contains(productId);
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}