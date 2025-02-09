import 'package:cloud_firestore/cloud_firestore.dart';

class CartModel {
  final String productId;
  int quantity;
  String? selectedSize;
  String? selectedColor;

  CartModel({
    required this.productId,
    required this.quantity,
    this.selectedSize,
    this.selectedColor,
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
    final Map<String, dynamic> data = {
      "product_id": productId,
      "quantity": quantity,
    };
    
    if (selectedSize != null) data["selected_size"] = selectedSize;
    if (selectedColor != null) data["selected_color"] = selectedColor;
    
    return data;
  }

  static List<CartModel> fromJsonList(List<QueryDocumentSnapshot> list) {
    return list.map((doc) => CartModel.fromJson(doc.data() as Map<String, dynamic>)).toList();
  }

  CartModel copyWith({
    String? productId,
    int? quantity,
    String? selectedSize,
    String? selectedColor,
  }) {
    return CartModel(
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedColor: selectedColor ?? this.selectedColor,
    );
  }
}