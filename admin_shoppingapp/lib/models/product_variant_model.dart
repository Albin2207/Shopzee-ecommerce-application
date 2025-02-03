
class ProductVariant {
  String id;
  String productId;
  String size;
  String color;
  int quantity;
  String variantSKU;  // Unique identifier for this specific variant

  ProductVariant({
    required this.id,
    required this.productId,
    required this.size,
    required this.color,
    required this.quantity,
    required this.variantSKU,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json, String id) {
    return ProductVariant(
      id: id,
      productId: json['productId'] ?? '',
      size: json['size'] ?? '',
      color: json['color'] ?? '',
      quantity: json['quantity'] ?? 0,
      variantSKU: json['variantSKU'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'size': size,
      'color': color,
      'quantity': quantity,
      'variantSKU': variantSKU,
    };
  }
}