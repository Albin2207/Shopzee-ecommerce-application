import 'package:flutter/material.dart';
import 'package:user_shoppingapp/controllers/database_service.dart';
class WishlistProvider with ChangeNotifier {
  final DbService _dbService = DbService();
  List<String> _wishlistedItems = [];
  bool _isLoading = false;  // Initialize with false
  String? _error;

  // Add getter for loading state
  bool get isLoading => _isLoading;
  List<String> get wishlistedItems => _wishlistedItems;
  String? get error => _error;

  WishlistProvider() {
    // Initialize wishlist when provider is created
    _initializeWishlist();
  }

  Future<void> _initializeWishlist() async {
    await loadWishlist();
  }

  Future<void> loadWishlist() async {
    try {
      _isLoading = true;
      notifyListeners();

      _wishlistedItems = await _dbService.getWishlistProductIds();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleWishlist(String productId) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_wishlistedItems.contains(productId)) {
        await _dbService.removeFromWishlist(productId: productId);
        _wishlistedItems.remove(productId);
      } else {
        await _dbService.addToWishlist(productId: productId);
        _wishlistedItems.add(productId);
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
      await loadWishlist(); // Reload on error to ensure consistency
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