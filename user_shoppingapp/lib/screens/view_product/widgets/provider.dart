import 'package:flutter/material.dart';

class ViewProductProvider extends ChangeNotifier {
  int _currentImageIndex = 0;
  String? _selectedSize;
  String? _selectedColor;

  int get currentImageIndex => _currentImageIndex;
  String? get selectedSize => _selectedSize;
  String? get selectedColor => _selectedColor;

  void setImageIndex(int index) {
    _currentImageIndex = index;
    notifyListeners();
  }

  void selectSize(String? size) {
    _selectedSize = size;
    notifyListeners();
  }

  void selectColor(String? color) {
    _selectedColor = color;
    notifyListeners();
  }
}
