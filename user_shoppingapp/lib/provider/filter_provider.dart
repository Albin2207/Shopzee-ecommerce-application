import 'package:flutter/material.dart';
import 'package:user_shoppingapp/models/product_model.dart';
import 'package:user_shoppingapp/models/category_model.dart';
import 'package:user_shoppingapp/controllers/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum SortOption { newest, priceLowToHigh, priceHighToLow }

class FilterProvider extends ChangeNotifier {
  // Database service
  final DbService _dbService = DbService();
  
  // Categories from Firebase
  List<CategoriesModel> _categories = [];
  bool _isLoadingCategories = true;
  Stream<QuerySnapshot>? _categoriesStream;
  
  // Sorting
  SortOption _currentSort = SortOption.newest;
  
  // Price Range
  RangeValues _priceRange = RangeValues(0, 100000);
  
  // Multiple Selection Filters
  List<String> _selectedCategories = [];
  List<String> _selectedColors = [];
  List<String> _selectedSizes = [];
  
  FilterProvider() {
    _initializeCategoriesStream();
  }

  void _initializeCategoriesStream() {
    _categoriesStream = _dbService.readCategories();
    _categoriesStream?.listen((snapshot) {
      _categories = CategoriesModel.fromJsonList(snapshot.docs);
      _isLoadingCategories = false;
      notifyListeners();
    }, onError: (error) {
      print('Error loading categories: $error');
      _isLoadingCategories = false;
      notifyListeners();
    });
  }
  
  // Getters
  bool get isLoadingCategories => _isLoadingCategories;
  List<CategoriesModel> get categories => _categories;
  SortOption get currentSort => _currentSort;
  RangeValues get priceRange => _priceRange;
  List<String> get selectedCategories => _selectedCategories;
  List<String> get selectedColors => _selectedColors;
  List<String> get selectedSizes => _selectedSizes;
  
  // Check if any filters are active
  bool get hasActiveFilters =>
      _selectedCategories.isNotEmpty ||
      _selectedColors.isNotEmpty ||
      _selectedSizes.isNotEmpty ||
      _priceRange.start > 0 ||
      _priceRange.end < 100000;

  // Setters with notifications
  void setSortOption(SortOption option) {
    _currentSort = option;
    notifyListeners();
  }

  void setPriceRange(RangeValues range) {
    _priceRange = range;
    notifyListeners();
  }

  void toggleCategory(String category) {
    if (_selectedCategories.contains(category)) {
      _selectedCategories.remove(category);
    } else {
      _selectedCategories.add(category);
    }
    notifyListeners();
  }

  void toggleColor(String color) {
    if (_selectedColors.contains(color)) {
      _selectedColors.remove(color);
    } else {
      _selectedColors.add(color);
    }
    notifyListeners();
  }

  void toggleSize(String size) {
    if (_selectedSizes.contains(size)) {
      _selectedSizes.remove(size);
    } else {
      _selectedSizes.add(size);
    }
    notifyListeners();
  }

  void resetFilters() {
    _selectedCategories = [];
    _selectedColors = [];
    _selectedSizes = [];
    _priceRange = RangeValues(0, 100000);
    notifyListeners();
  }

  List<ProductsModel> applySortAndFilters(List<ProductsModel> products) {
    var filteredProducts = List<ProductsModel>.from(products);
    
    // Apply price filter
    filteredProducts = filteredProducts.where((product) {
      return product.new_price >= _priceRange.start && 
             product.new_price <= _priceRange.end;
    }).toList();
    
    // Apply category filter
    if (_selectedCategories.isNotEmpty) {
      filteredProducts = filteredProducts.where((product) {
        return _selectedCategories.contains(product.category.toLowerCase());
      }).toList();
    }
    
    // Apply color filter
    if (_selectedColors.isNotEmpty) {
      filteredProducts = filteredProducts.where((product) {
        return product.colors.any((color) => _selectedColors.contains(color));
      }).toList();
    }
    
    // Apply size filter
    if (_selectedSizes.isNotEmpty) {
      filteredProducts = filteredProducts.where((product) {
        return product.sizes.any((size) => _selectedSizes.contains(size));
      }).toList();
    }
    
    // Apply sorting
    switch (_currentSort) {
      case SortOption.priceLowToHigh:
        filteredProducts.sort((a, b) => a.new_price.compareTo(b.new_price));
        break;
      case SortOption.priceHighToLow:
        filteredProducts.sort((a, b) => b.new_price.compareTo(a.new_price));
        break;
      case SortOption.newest:
        // Since we don't have a timestamp, we'll keep the original order
        break;
    }
    
    return filteredProducts;
  }

  @override
  void dispose() {
    // Clean up any listeners or resources
    super.dispose();
  }
}