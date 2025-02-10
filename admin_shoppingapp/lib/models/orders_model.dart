import 'package:cloud_firestore/cloud_firestore.dart';

class OrdersModel{
  String id,email,name,phone,status,user_id,address;
  int discount,total,created_at;
  List<OrderProductModel> products;

  
  OrdersModel({
    required this.id,
    required this.created_at,
    required this.email,
    required this.name,
    required this.phone,
    required this.address,
    required this.status,
    required this.user_id,
    required this.discount,
    required this.total,
    required this.products
  });

  // convert json to object model
  factory OrdersModel.fromJson(Map<String, dynamic> json, String id) {
  return OrdersModel(
    id: id ?? "",
    created_at: json["created_at"] ?? 0,
    email: json["email"] ?? "",
    name: json["name"] ?? "",
    phone: json["phone"] ?? "",
    status: json["status"] ?? "",
    address: json["address"] ?? "",
    user_id: json["user_id"] ?? "",
    discount: json["discount"] ?? 0,
    total: json["total"] ?? 0,
    products: json["products"] != null
        ? List<OrderProductModel>.from(
            (json["products"] as List).map((e) => OrderProductModel.fromJson(e)))
        : [], // If products is null, return an empty list
  );
}


// Convert List<QueryDocumentSnapshot> to List<OrdersModel>
  static List<OrdersModel> fromJsonList(List<QueryDocumentSnapshot> list) {
    return list.map((e) => OrdersModel.fromJson(e.data() as Map<String, dynamic> , e.id)).toList();
  }

}
class OrderProductModel {
  String id, name;
  List<String> images;
  int quantity, single_price, total_price;

  OrderProductModel({
    required this.id,
    required this.name,
    required this.images,
    required this.quantity,
    required this.single_price,
    required this.total_price,
  });

  factory OrderProductModel.fromJson(Map<String, dynamic> json) {
    List<String> imageList = [];

    if (json["images"] != null && (json["images"] as List).isNotEmpty) {
      imageList = List<String>.from(json["images"]);
    } else if (json["image"] != null && json["image"].isNotEmpty) {
      imageList = [json["image"]];
    }

    return OrderProductModel(
      id: json["id"] ?? "",
      name: json["name"] ?? "",
      images: imageList,
      quantity: json["quantity"] ?? 0,
      single_price: json["single_price"] ?? 0,
      total_price: json["total_price"] ?? 0,
    );
  }
}
