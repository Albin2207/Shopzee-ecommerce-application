import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_shoppingapp/models/product_model.dart';

// search_provider.dart
class SearchProvider with ChangeNotifier {
  List<ProductsModel> _searchResults = [];
  List<String> _suggestions = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<ProductsModel> get searchResults => _searchResults;
  List<String> get suggestions => _suggestions;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      _suggestions = [];
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _searchQuery = query;
      notifyListeners();

      // Convert query to lowercase for case-insensitive search
      String searchLower = query.toLowerCase();

      // Get all products first to generate suggestions
      QuerySnapshot allProducts = await FirebaseFirestore.instance
          .collection("shop_products")
          .get();

      List<ProductsModel> allProductsList = ProductsModel.fromJsonList(allProducts.docs);

      // Filter products for name search
      _searchResults = allProductsList
          .where((product) => 
              product.name.toLowerCase().contains(searchLower) ||
              product.category.toLowerCase().contains(searchLower))
          .toList();

      // Generate suggestions from all product names
      _suggestions = allProductsList
          .map((product) => product.name)
          .where((name) => 
              name.toLowerCase().contains(searchLower) &&
              name.toLowerCase() != searchLower)
          .toSet() // Remove duplicates
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print("Error searching products: $e");
      _isLoading = false;
      _searchResults = [];
      _suggestions = [];
      notifyListeners();
    }
  }

  // Add this method to get suggestions without doing a full search
  Future<void> getSuggestions(String query) async {
    if (query.isEmpty) {
      _suggestions = [];
      notifyListeners();
      return;
    }

    try {
      String searchLower = query.toLowerCase();
      
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("shop_products")
          .where("name", isGreaterThanOrEqualTo: searchLower)
          .where("name", isLessThanOrEqualTo: '$searchLower\uf8ff')
          .limit(5)
          .get();

      _suggestions = snapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['name'] as String)
          .toSet()
          .toList();

      notifyListeners();
    } catch (e) {
      print("Error getting suggestions: $e");
      _suggestions = [];
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchResults = [];
    _suggestions = [];
    _searchQuery = '';
    notifyListeners();
  }
}