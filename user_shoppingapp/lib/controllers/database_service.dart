import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:user_shoppingapp/models/address_model.dart';
import 'package:user_shoppingapp/models/cart_model.dart';

class DbService {
  User? user = FirebaseAuth.instance.currentUser;

  // USER DATA
  Future saveUserData({required String name, required String email}) async {
    try {
      Map<String, dynamic> data = {
        "name": name,
        "email": email,
      };
      await FirebaseFirestore.instance
          .collection("shop_users")
          .doc(user!.uid)
          .set(data);
    } catch (e) {
      print("error on saving user data: $e");
    }
  }

  Future updateUserData({required Map<String, dynamic> extraData}) async {
    try {
      await FirebaseFirestore.instance
          .collection("shop_users")
          .doc(user!.uid)
          .update({
        "name": extraData["name"],
        "email": extraData["email"],
        "phone": extraData["phone"],
        "alternatePhone": extraData["alternatePhone"],
        "pincode": extraData["pincode"],
        "state": extraData["state"],
        "city": extraData["city"],
        "houseNo": extraData["houseNo"],
        "roadName": extraData["roadName"],
        
      });

      // Optionally fetch fresh data after update
      final updatedDoc = await FirebaseFirestore.instance
          .collection("shop_users")
          .doc(user!.uid)
          .get();
      return updatedDoc.data();
    } catch (e) {
      print("Error updating user data: $e");
      rethrow;
    }
  }

  Stream<DocumentSnapshot> readUserData() {
    return FirebaseFirestore.instance
        .collection("shop_users")
        .doc(user!.uid)
        .snapshots();
  }

  //Address list
  // Addresses Collection Reference
  CollectionReference<Map<String, dynamic>> get _addressesCollection =>
      FirebaseFirestore.instance
          .collection("shop_users")
          .doc(user!.uid)
          .collection("addresses");

  // Read all addresses
  Stream<List<AddressModel>> readAddresses() {
    return _addressesCollection.snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => AddressModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  // Add new address
  Future<void> addAddress(Map<String, dynamic> addressData) async {
    try {
      // Create a new map with all the address data
      final Map<String, dynamic> finalAddressData = Map.from(addressData);
      
      // If this is the first address, make it default
      final addresses = await _addressesCollection.get();
      finalAddressData['isDefault'] = addresses.docs.isEmpty;
      
      // Add server timestamp
      finalAddressData['createdAt'] = FieldValue.serverTimestamp();

      await _addressesCollection.add(finalAddressData);
    } catch (e) {
      print("Error adding address: $e");
      rethrow;
    }
  }

  Future<void> updateAddress(String id, Map<String, dynamic> addressData) async {
    try {
      // Create a new map with all the address data
      final Map<String, dynamic> finalAddressData = Map.from(addressData);
      
      // Make sure isDefault is a boolean
      if (finalAddressData.containsKey('isDefault')) {
        finalAddressData['isDefault'] = finalAddressData['isDefault'] as bool;
      }

      await _addressesCollection.doc(id).update(finalAddressData);
    } catch (e) {
      print("Error updating address: $e");
      rethrow;
    }
  }
  


  // Delete address
  Future<void> deleteAddress(String id) async {
    try {
      final address = await _addressesCollection.doc(id).get();
      
      // If deleting default address, make another address default
      if (address.data()?['isDefault'] == true) {
        final otherAddresses = await _addressesCollection
            .where(FieldPath.documentId, isNotEqualTo: id)
            .limit(1)
            .get();
        
        if (otherAddresses.docs.isNotEmpty) {
          await _addressesCollection
              .doc(otherAddresses.docs.first.id)
              .update({'isDefault': true});
        }
      }
      
      await _addressesCollection.doc(id).delete();
    } catch (e) {
      print("Error deleting address: $e");
      rethrow;
    }
  }

  // Set default address
  Future<void> setDefaultAddress(String id) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      
      // Remove default status from all addresses
      final addresses = await _addressesCollection.get();
      for (var doc in addresses.docs) {
        batch.update(doc.reference, {'isDefault': false});
      }
      
      // Set new default address
      batch.update(_addressesCollection.doc(id), {'isDefault': true});
      
      await batch.commit();
    } catch (e) {
      print("Error setting default address: $e");
      rethrow;
    }
  }

  // Get default address
  Future<AddressModel?> getDefaultAddress() async {
    try {
      final snapshot = await _addressesCollection
          .where('isDefault', isEqualTo: true)
          .limit(1)
          .get();
      
      if (snapshot.docs.isEmpty) return null;
      
      return AddressModel.fromJson(
        snapshot.docs.first.data(),
        snapshot.docs.first.id,
      );
    } catch (e) {
      print("Error getting default address: $e");
      rethrow;
    }
  }

  // PROMOS AND BANNERS
  Stream<QuerySnapshot> readPromos() {
    return FirebaseFirestore.instance.collection("shop_promos").snapshots();
  }

  Stream<QuerySnapshot> readBanners() {
    return FirebaseFirestore.instance.collection("shop_banners").snapshots();
  }

  // DISCOUNTS
  Stream<QuerySnapshot> readDiscounts() {
    return FirebaseFirestore.instance
        .collection("shop_coupons")
        .orderBy("discount", descending: true)
        .snapshots();
  }

  Future<QuerySnapshot> verifyDiscount({required String code}) {
    print("searching for code : $code");
    return FirebaseFirestore.instance
        .collection("shop_coupons")
        .where("code", isEqualTo: code)
        .get();
  }

  // CATEGORIES
  Stream<QuerySnapshot> readCategories() {
    return FirebaseFirestore.instance
        .collection("shop_categories")
        .orderBy("priority", descending: true)
        .snapshots();
  }

  // PRODUCTS
  Stream<QuerySnapshot> readProducts(String category) {
    return FirebaseFirestore.instance
        .collection("shop_products")
        .where("category", isEqualTo: category.toLowerCase())
        .snapshots();
  }

  Stream<QuerySnapshot> searchProducts(List<String> docIds) {
    return FirebaseFirestore.instance
        .collection("shop_products")
        .where(FieldPath.documentId, whereIn: docIds)
        .snapshots();
  }

  Future reduceQuantity(
      {required String productId, required int quantity}) async {
    await FirebaseFirestore.instance
        .collection("shop_products")
        .doc(productId)
        .update({"quantity": FieldValue.increment(-quantity)});
  }

   // CART
  // display the user cart

  Stream<QuerySnapshot> readUserCart() {
    return FirebaseFirestore.instance
        .collection("shop_users")
        .doc(user!.uid)
        .collection("cart")
        .snapshots();
  }

  // adding product to the cart
 Future addToCart({required CartModel cartData}) async {
  try {
    String cartItemId = "${cartData.productId}_${cartData.selectedSize ?? ''}_${cartData.selectedColor ?? ''}";

    var docRef = FirebaseFirestore.instance
        .collection("shop_users")
        .doc(user!.uid)
        .collection("cart")
        .doc(cartItemId);

    var doc = await docRef.get();
    if (doc.exists) {
      await docRef.update({
        "quantity": FieldValue.increment(1),
      });
    } else {
      await docRef.set({
        "product_id": cartData.productId,
        "quantity": cartData.quantity,
        "selected_size": cartData.selectedSize,
        "selected_color": cartData.selectedColor,
      });
    }
  } on FirebaseException catch (e) {
    print("firebase exception : ${e.code}");
  }
}



  // delete specific product from cart
Future deleteItemFromCart({
  required String productId,
  String? size,
  String? color,
}) async {
  var query = FirebaseFirestore.instance
      .collection("shop_users")
      .doc(user!.uid)
      .collection("cart")
      .where("product_id", isEqualTo: productId);

  if (size != null) {
    query = query.where("selected_size", isEqualTo: size);
  }

  if (color != null) {
    query = query.where("selected_color", isEqualTo: color);
  }

  var snapshot = await query.get();
  for (var doc in snapshot.docs) {
    await doc.reference.delete();
  }
}



  // empty users cart
  Future emptyCart() async {
    await FirebaseFirestore.instance
        .collection("shop_users")
        .doc(user!.uid)
        .collection("cart")
        .get()
        .then((value) {
      for (DocumentSnapshot ds in value.docs) {
        ds.reference.delete();
      }
    });
  }

  // decrease count of item
  Future decreaseCount({required String productId, String? size, String? color}) async {
  String cartItemId = "${productId}_${size ?? ''}_${color ?? ''}";

  var docRef = FirebaseFirestore.instance
      .collection("shop_users")
      .doc(user!.uid)
      .collection("cart")
      .doc(cartItemId);

  var doc = await docRef.get();
  if (doc.exists && doc["quantity"] > 1) {
    await docRef.update({"quantity": FieldValue.increment(-1)});
  } else {
    await docRef.delete();
  }
}

Future updateCartQuantity(String productId, int quantity, {String? size, String? color}) async {
  var query = FirebaseFirestore.instance
      .collection("shop_users")
      .doc(user!.uid)
      .collection("cart")
      .where("product_id", isEqualTo: productId);

  if (size != null) {
    query = query.where("selected_size", isEqualTo: size);
  }

  if (color != null) {
    query = query.where("selected_color", isEqualTo: color);
  }

  var snapshot = await query.get();
  for (var doc in snapshot.docs) {
    await doc.reference.update({"quantity": quantity});
  }
}


  Future<void> updateVariants(String productId, {String? size, String? color}) async {
  final docRef = FirebaseFirestore.instance
      .collection("shop_users")
      .doc(user!.uid)
      .collection("cart")
      .doc(productId);
  final updates = <String, dynamic>{};
  if (size != null) updates['selected_size'] = size;
  if (color != null) updates['selected_color'] = color;
  await docRef.update(updates);
}
  
  // ORDERS
  Future createOrder({required Map<String, dynamic> data}) async {
    await FirebaseFirestore.instance.collection("shop_orders").add(data);
  }

  Future updateOrderStatus(
      {required String docId, required Map<String, dynamic> data}) async {
    await FirebaseFirestore.instance
        .collection("shop_orders")
        .doc(docId)
        .update(data);
  }

  Stream<QuerySnapshot> readOrders() {
    return FirebaseFirestore.instance
        .collection("shop_orders")
        .where("user_id", isEqualTo: user!.uid)
        .orderBy("created_at", descending: true)
        .snapshots();
  }

  // WISHLIST FUNCTIONS 
  Future<void> addToWishlist({required String productId}) async {
    if (user == null) return; // Prevent errors if user is not logged in
    try {
      await FirebaseFirestore.instance
          .collection("shop_users")
          .doc(user!.uid)
          .collection("wishlist")
          .doc(productId)
          .set({
        'product_id': productId,
        'added_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error adding to wishlist: $e");
      rethrow;
    }
  }

  Future<void> removeFromWishlist({required String productId}) async {
    if (user == null) return;
    try {
      await FirebaseFirestore.instance
          .collection("shop_users")
          .doc(user!.uid)
          .collection("wishlist")
          .doc(productId)
          .delete();
    } catch (e) {
      print("Error removing from wishlist: $e");
      rethrow;
    }
  }

  Stream<QuerySnapshot> readWishlist() {
    if (user == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection("shop_users")
        .doc(user!.uid)
        .collection("wishlist")
        .orderBy("added_at", descending: true)
        .snapshots();
  }

  Future<List<String>> getWishlistProductIds() async {
    if (user == null) return [];
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("shop_users")
          .doc(user!.uid)
          .collection("wishlist")
          .get();
      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print("Error getting wishlist IDs: $e");
      return [];
    }
  }
}
