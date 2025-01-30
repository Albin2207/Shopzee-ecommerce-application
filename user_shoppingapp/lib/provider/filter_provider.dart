import 'package:flutter/material.dart';
import 'package:user_shoppingapp/models/product_model.dart';

enum SortOption { newest, priceLowToHigh, priceHighToLow }

class FilterProvider extends ChangeNotifier {
  SortOption _currentSort = SortOption.newest;
  List<String> _selectedBrands = [];
  List<String> _selectedColors = [];
  RangeValues _priceRange = RangeValues(0, 100000);
  
  // Getters
  SortOption get currentSort => _currentSort;
  List<String> get selectedBrands => _selectedBrands;
  List<String> get selectedColors => _selectedColors;
  RangeValues get priceRange => _priceRange;

  void setSortOption(SortOption option) {
    _currentSort = option;
    notifyListeners();
  }

  void resetFilters() {
    _selectedBrands = [];
    _selectedColors = [];
    _priceRange = RangeValues(0, 100000);
    notifyListeners();
  }

  List<ProductsModel> applySortAndFilters(List<ProductsModel> products) {
    var filteredProducts = List<ProductsModel>.from(products);
    
    // Apply sorting
    switch (_currentSort) {
      case SortOption.priceLowToHigh:
        filteredProducts.sort((a, b) => a.new_price.compareTo(b.new_price));
        break;
      case SortOption.priceHighToLow:
        filteredProducts.sort((a, b) => b.new_price.compareTo(a.new_price));
        break;
      case SortOption.newest:
        // Need to add a timestamp field in your ProductsModel
        break;
    }
    
    return filteredProducts;
  }
}