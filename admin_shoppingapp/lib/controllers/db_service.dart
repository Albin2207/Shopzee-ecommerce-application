import 'package:cloud_firestore/cloud_firestore.dart';

class DbService {
// CATEGORIES
// read categories from database
  Stream<QuerySnapshot> readCategories() {
    return FirebaseFirestore.instance
        .collection("shop_categories")
        .orderBy("priority", descending: true)
        .snapshots();
  }

  // create new category
  Future createCategories({required Map<String, dynamic> data}) async {
    await FirebaseFirestore.instance.collection("shop_categories").add(data);
  }

  // update category
  Future updateCategories(
      {required String docId, required Map<String, dynamic> data}) async {
    await FirebaseFirestore.instance
        .collection("shop_categories")
        .doc(docId)
        .update(data);
  }

  // delete category
  Future deleteCategories({required String docId}) async {
    await FirebaseFirestore.instance
        .collection("shop_categories")
        .doc(docId)
        .delete();
  }

    Future<bool> categoryHasProducts(String categoryName) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection("shop_products")
        .where("category", isEqualTo: categoryName)
        .get();
    
    return querySnapshot.docs.isNotEmpty;
  }

  // PRODUCTS
  // read products from database
  Stream<QuerySnapshot> readProducts() {
    return FirebaseFirestore.instance
        .collection("shop_products")
        .orderBy("category", descending: true)
        .snapshots();
  }

  // create a new product
  // Future createProduct({required Map<String, dynamic> data}) async {
  //   await FirebaseFirestore.instance.collection("shop_products").add(data);
  // }

  // update the product
  Future updateProduct(
      {required String docId, required Map<String, dynamic> data}) async {
    await FirebaseFirestore.instance
        .collection("shop_products")
        .doc(docId)
        .update(data);
  }

  // delete the product
  Future deleteProduct({required String docId}) async {
    await FirebaseFirestore.instance
        .collection("shop_products")
        .doc(docId)
        .delete();
  }

  // PROMOS & BANNERS
  // read promos from database
  Stream<QuerySnapshot> readPromos(bool isPromo) {
    print("reading $isPromo");
    return FirebaseFirestore.instance
        .collection(isPromo ? "shop_promos" : "shop_banners")
        .snapshots();
  }

  // create new promo or banner
  Future createPromos(
      {required Map<String, dynamic> data, required bool isPromo}) async {
    await FirebaseFirestore.instance
        .collection(isPromo ? "shop_promos" : "shop_banners")
        .add(data);
  }

  // update promo or banner
  Future updatePromos(
      {required Map<String, dynamic> data,
      required bool isPromo,
      required String id}) async {
    await FirebaseFirestore.instance
        .collection(isPromo ? "shop_promos" : "shop_banners")
        .doc(id)
        .update(data);
  }

  // delete promo or banner
  Future deletePromos({required bool isPromo, required String id}) async {
    await FirebaseFirestore.instance
        .collection(isPromo ? "shop_promos" : "shop_banners")
        .doc(id)
        .delete();
  }

  // DISCOUNT AND COUPON CODE
  // read coupon code from database
  Stream<QuerySnapshot> readCouponCode() {
    return FirebaseFirestore.instance.collection("shop_coupons").snapshots();
  }

  // create new coupon code
  Future createCouponCode({required Map<String, dynamic> data}) async {
    await FirebaseFirestore.instance.collection("shop_coupons").add(data);
  }

  // update coupon code
  Future updateCouponCode(
      {required String docId, required Map<String, dynamic> data}) async {
    await FirebaseFirestore.instance
        .collection("shop_coupons")
        .doc(docId)
        .update(data);
  }

  // delete coupon code
  Future deleteCouponCode({required String docId}) async {
    await FirebaseFirestore.instance
        .collection("shop_coupons")
        .doc(docId)
        .delete();
  }

  // ORDERS
  // read all the orders
  // Stream<QuerySnapshot> readOrders() {
  //   return FirebaseFirestore.instance
  //       .collection("shop_orders")
  //       .orderBy("created_at", descending: true)
  //       .snapshots();
  // }

    // update the status of order
  Future updateOrderStatus(
      {required String docId, required Map<String, dynamic> data}) async {
    await FirebaseFirestore.instance
        .collection("shop_orders")
        .doc(docId)
        .update(data);
  }
// Get total users count
  Future<int> getTotalUsers() async {
    final querySnapshot = await FirebaseFirestore.instance.collection("users").get();
    return querySnapshot.docs.length;
  }

  // Get orders with date filtering
  Stream<QuerySnapshot> readOrders({DateTime? startDate, DateTime? endDate}) {
    Query query = FirebaseFirestore.instance.collection("shop_orders").orderBy("created_at", descending: true);

    if (startDate != null) {
      query = query.where("created_at", isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    if (endDate != null) {
      query = query.where("created_at", isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }
    return query.snapshots();
  }

  // Create product with cost price for profit analytics
  Future createProduct({required Map<String, dynamic> data}) async {
    data['cost_price'] = data['cost_price'] ?? 0; // Ensure cost price is included
    DocumentReference productRef = await FirebaseFirestore.instance.collection("shop_products").add(data);
    
    // Create variants
    List<String> sizes = List<String>.from(data['sizes'] ?? []);
    List<String> colors = List<String>.from(data['colors'] ?? []);
    int baseQuantity = data['quantity'] ?? 0;
    int variantQuantity = baseQuantity ~/ (sizes.length * colors.length);

    for (String size in sizes) {
      for (String color in colors) {
        Map<String, dynamic> variantData = {
          'productId': productRef.id,
          'size': size,
          'color': color,
          'quantity': variantQuantity,
          'variantSKU': '${productRef.id}-${size.toLowerCase()}-${color.toLowerCase()}',
          'price': data['new_price'],
          'cost_price': data['cost_price'], // Store cost price for profit tracking
          'created_at': FieldValue.serverTimestamp(),
        };
        await FirebaseFirestore.instance.collection("shop_product_variants").add(variantData);
      }
    }
  }

  // Update order to store category information
  Future createOrder({required Map<String, dynamic> orderData}) async {
    List<Map<String, dynamic>> products = List<Map<String, dynamic>>.from(orderData['products'] ?? []);

    for (var product in products) {
      DocumentSnapshot productDoc = await FirebaseFirestore.instance.collection("shop_products").doc(product['productId']).get();
      if (productDoc.exists) {
        product['category'] = productDoc.get("category"); // Store category in order
        product['cost_price'] = productDoc.get("cost_price"); // Store cost price
      }
    }
    orderData['products'] = products;
    await FirebaseFirestore.instance.collection("shop_orders").add(orderData);
  }
}

