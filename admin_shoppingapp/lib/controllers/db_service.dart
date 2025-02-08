import 'package:cloud_firestore/cloud_firestore.dart';

class DbService {
  // Categories
  Stream<QuerySnapshot> readCategories() {
    return FirebaseFirestore.instance
        .collection("shop_categories")
        .orderBy("priority", descending: true)
        .snapshots();
  }

  Future createCategories({required Map<String, dynamic> data}) async {
    await FirebaseFirestore.instance.collection("shop_categories").add(data);
  }

  Future updateCategories(
      {required String docId, required Map<String, dynamic> data}) async {
    await FirebaseFirestore.instance
        .collection("shop_categories")
        .doc(docId)
        .update(data);
  }

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

  // Products
  Stream<QuerySnapshot> readProducts() {
    return FirebaseFirestore.instance
        .collection("shop_products")
        .orderBy("category", descending: true)
        .snapshots();
  }

  // Modified createProduct to handle variants
  Future createProduct({required Map<String, dynamic> data}) async {
    // Create base product document
    DocumentReference productRef = await FirebaseFirestore.instance
        .collection("shop_products")
        .add(data);

    // Create variants for each size and color combination
    List<String> sizes = List<String>.from(data['sizes'] ?? []);
    List<String> colors = List<String>.from(data['colors'] ?? []);
    int baseQuantity = data['quantity'] ?? 0;
    int variantQuantity = baseQuantity ~/ (sizes.length * colors.length); // Distribute quantity among variants

    for (String size in sizes) {
      for (String color in colors) {
        Map<String, dynamic> variantData = {
          'productId': productRef.id,
          'size': size,
          'color': color,
          'quantity': variantQuantity,
          'variantSKU': '${productRef.id}-${size.toLowerCase()}-${color.toLowerCase()}',
          'price': data['new_price'], // Inherit price from base product
          'created_at': FieldValue.serverTimestamp(),
        };
        
        await FirebaseFirestore.instance
            .collection("shop_product_variants")
            .add(variantData);
      }
    }
  }

  // Modified updateProduct to handle variants
  Future updateProduct({required String docId, required Map<String, dynamic> data}) async {
    // Update base product
    await FirebaseFirestore.instance
        .collection("shop_products")
        .doc(docId)
        .update(data);

    // Delete existing variants
    await deleteProductVariants(docId);

    // Create new variants
    List<String> sizes = List<String>.from(data['sizes'] ?? []);
    List<String> colors = List<String>.from(data['colors'] ?? []);
    int baseQuantity = data['quantity'] ?? 0;
    int variantQuantity = baseQuantity ~/ (sizes.length * colors.length);

    for (String size in sizes) {
      for (String color in colors) {
        Map<String, dynamic> variantData = {
          'productId': docId,
          'size': size,
          'color': color,
          'quantity': variantQuantity,
          'variantSKU': '$docId-${size.toLowerCase()}-${color.toLowerCase()}',
          'price': data['new_price'],
          'updated_at': FieldValue.serverTimestamp(),
        };
        
        await FirebaseFirestore.instance
            .collection("shop_product_variants")
            .add(variantData);
      }
    }
  }

  // Modified deleteProduct to handle variants
  Future deleteProduct({required String docId}) async {
    // Delete all variants first
    await deleteProductVariants(docId);
    
    // Then delete the base product
    await FirebaseFirestore.instance
        .collection("shop_products")
        .doc(docId)
        .delete();
  }

  // Variant specific methods
  Future deleteProductVariants(String productId) async {
    final QuerySnapshot variants = await FirebaseFirestore.instance
        .collection("shop_product_variants")
        .where("productId", isEqualTo: productId)
        .get();
    
    for (var doc in variants.docs) {
      await doc.reference.delete();
    }
  }

  Stream<QuerySnapshot> readProductVariants(String productId) {
    return FirebaseFirestore.instance
        .collection("shop_product_variants")
        .where("productId", isEqualTo: productId)
        .snapshots();
  }

  Future updateVariantQuantity({
    required String variantId,
    required int newQuantity,
  }) async {
    await FirebaseFirestore.instance
        .collection("shop_product_variants")
        .doc(variantId)
        .update({'quantity': newQuantity});
  }

  // PROMOS & BANNERS
  Stream<QuerySnapshot> readPromos(bool isPromo) {
    print("reading $isPromo");
    return FirebaseFirestore.instance
        .collection(isPromo ? "shop_promos" : "shop_banners")
        .snapshots();
  }

  Future createPromos(
      {required Map<String, dynamic> data, required bool isPromo}) async {
    await FirebaseFirestore.instance
        .collection(isPromo ? "shop_promos" : "shop_banners")
        .add(data);
  }

  Future updatePromos(
      {required Map<String, dynamic> data,
      required bool isPromo,
      required String id}) async {
    await FirebaseFirestore.instance
        .collection(isPromo ? "shop_promos" : "shop_banners")
        .doc(id)
        .update(data);
  }

  Future deletePromos({required bool isPromo, required String id}) async {
    await FirebaseFirestore.instance
        .collection(isPromo ? "shop_promos" : "shop_banners")
        .doc(id)
        .delete();
  }

  // DISCOUNT AND COUPON CODE
  Stream<QuerySnapshot> readCouponCode() {
    return FirebaseFirestore.instance.collection("shop_coupons").snapshots();
  }

  Future createCouponCode({required Map<String, dynamic> data}) async {
    await FirebaseFirestore.instance.collection("shop_coupons").add(data);
  }

  Future updateCouponCode(
      {required String docId, required Map<String, dynamic> data}) async {
    await FirebaseFirestore.instance
        .collection("shop_coupons")
        .doc(docId)
        .update(data);
  }

  Future deleteCouponCode({required String docId}) async {
    await FirebaseFirestore.instance
        .collection("shop_coupons")
        .doc(docId)
        .delete();
  }

  // ORDERS
  Stream<QuerySnapshot> readOrders() {
    return FirebaseFirestore.instance
        .collection("shop_orders")
        .orderBy("created_at", descending: true)
        .snapshots();
  }

  Future updateOrderStatus(
      {required String docId, required Map<String, dynamic> data}) async {
    await FirebaseFirestore.instance
        .collection("shop_orders")
        .doc(docId)
        .update(data);
  }
}