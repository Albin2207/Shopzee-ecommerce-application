import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistModel {
  final String productId;
  final DateTime addedAt;

  WishlistModel({
    required this.productId,
    required this.addedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'added_at': addedAt,
    };
  }

  factory WishlistModel.fromJson(Map<String, dynamic> json) {
    return WishlistModel(
      productId: json['product_id'],
      addedAt: (json['added_at'] as Timestamp).toDate(),
    );
  }
}