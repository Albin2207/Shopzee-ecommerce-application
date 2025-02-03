import 'package:cloud_firestore/cloud_firestore.dart';

class ProductsModel {
  String name;
  String description;
  String image;
  List<String> images; 
  int old_price;
  int new_price;
  String category;
  String id;
  int maxQuantity;
  List<String> sizes;   
  List<String> colors;  

  ProductsModel({
    required this.name,
    required this.description,
    required this.image,
    required this.images,
    required this.old_price,
    required this.new_price,
    required this.category,
    required this.id,
    required this.maxQuantity,
    required this.sizes,
    required this.colors,
  });

  factory ProductsModel.fromJson(Map<String, dynamic> json, String id) {
    // Handle both old and new image formats
    List<String> imageList = [];
    if (json["images"] != null) {
      imageList = List<String>.from(json["images"]);
    } else if (json["image"] != null && json["image"].isNotEmpty) {
      imageList = [json["image"]];
    }

    return ProductsModel(
      name: json["name"] ?? "",
      description: json["desc"] ?? "no description",
      image: json["image"] ?? "",
      images: imageList,
      new_price: json["new_price"] ?? 0,
      old_price: json["old_price"] ?? 0,
      category: json["category"] ?? "",
      maxQuantity: json["quantity"] ?? 0,
      id: id ?? "",
      sizes: List<String>.from(json["sizes"] ?? []),
      colors: List<String>.from(json["colors"] ?? []),
    );
  }

  static List<ProductsModel> fromJsonList(List<QueryDocumentSnapshot> list) {
    return list
        .map((e) => ProductsModel.fromJson(e.data() as Map<String, dynamic>, e.id))
        .toList();
  }
}