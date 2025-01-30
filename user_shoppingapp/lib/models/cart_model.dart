import 'package:cloud_firestore/cloud_firestore.dart';

class CartModel {
  final String productId;
  int quantity;
  String? selectedSize;  // Added
  String? selectedColor; // Added

  CartModel({
    required this.productId,
    required this.quantity,
    this.selectedSize,   // Added
    this.selectedColor,  // Added
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      productId: json["product_id"] ?? "",
      quantity: json["quantity"] ?? 0,
      selectedSize: json["selected_size"],
      selectedColor: json["selected_color"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "product_id": productId,
      "quantity": quantity,
      "selected_size": selectedSize,
      "selected_color": selectedColor,
    };
  }

  static List<CartModel> fromJsonList(List<QueryDocumentSnapshot> list) {
    return list
        .map((e) => CartModel.fromJson(e.data() as Map<String, dynamic>))
        .toList();
  }
}