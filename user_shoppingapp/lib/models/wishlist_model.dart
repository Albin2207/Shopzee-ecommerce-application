import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistModel {
  final String productId;
  final DateTime addedAt;

  const WishlistModel({
    required this.productId,
    required this.addedAt,
  });

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'added_at': Timestamp.fromDate(addedAt),
  };

  factory WishlistModel.fromJson(Map<String, dynamic> json) {
    return WishlistModel(
      productId: json['product_id'] as String,
      addedAt: (json['added_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is WishlistModel &&
    runtimeType == other.runtimeType &&
    productId == other.productId &&
    addedAt == other.addedAt;

  @override
  int get hashCode => productId.hashCode ^ addedAt.hashCode;
}
