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
      // update
      await FirebaseFirestore.instance
          .collection("shop_users")
          .doc(user!.uid)
          .collection("cart")
          .doc(cartData.productId)
          .update({
        "product_id": cartData.productId,
        "quantity": FieldValue.increment(1)
      });
    } on FirebaseException catch (e) {
      print("firebase exception : ${e.code}");
      if (e.code == "not-found") {
        // insert
        await FirebaseFirestore.instance
            .collection("shop_users")
            .doc(user!.uid)
            .collection("cart")
            .doc(cartData.productId)
            .set({"product_id": cartData.productId, "quantity": 1});
      }
    }
  }

  // delete specific product from cart
  Future deleteItemFromCart({required String productId}) async {
    await FirebaseFirestore.instance
        .collection("shop_users")
        .doc(user!.uid)
        .collection("cart")
        .doc(productId)
        .delete();
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
  Future decreaseCount({required String productId}) async {
    await FirebaseFirestore.instance
        .collection("shop_users")
        .doc(user!.uid)
        .collection("cart")
        .doc(productId)
        .update({"quantity": FieldValue.increment(-1)});
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

  // WISHLIST FUNCTIONS - EXISTING
  Stream<QuerySnapshot> readWishlist() {
    return FirebaseFirestore.instance
        .collection("shop_users")
        .doc(user!.uid)
        .collection("wishlist")
        .orderBy("added_at", descending: true)
        .snapshots();
  }

  Future addToWishlist({required String productId}) async {
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

  Future removeFromWishlist({required String productId}) async {
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

  Future<List<String>> getWishlistProductIds() async {
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

  // NEW WISHLIST COLLECTION FUNCTIONS
  Future createWishlistCollection({
    required String name,
    String? description,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection("shop_users")
          .doc(user!.uid)
          .collection("wishlist_collections")
          .add({
        'name': name,
        'description': description,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error creating wishlist collection: $e");
      rethrow;
    }
  }

  Stream<QuerySnapshot> readWishlistCollections() {
    return FirebaseFirestore.instance
        .collection("shop_users")
        .doc(user!.uid)
        .collection("wishlist_collections")
        .orderBy("created_at", descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> readWishlistCollectionItems(String collectionId) {
    final collection = collectionId == 'default'
        ? 'wishlist'
        : 'wishlist_collections/$collectionId/items';

    return FirebaseFirestore.instance
        .collection("shop_users")
        .doc(user!.uid)
        .collection(collection)
        .orderBy("added_at", descending: true)
        .snapshots();
  }

  Future<void> addToWishlistCollection({
    required String productId,
    required String collectionId,
  }) async {
    try {
      final userDoc =
          FirebaseFirestore.instance.collection("shop_users").doc(user!.uid);

      final collectionRef = collectionId == 'default'
          ? userDoc.collection('wishlist')
          : userDoc
              .collection('wishlist_collections')
              .doc(collectionId)
              .collection('items');

      await collectionRef.doc(productId).set({
        'product_id': productId,
        'added_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error adding to wishlist collection: $e");
      rethrow;
    }
  }

  Future<void> removeFromWishlistCollection({
    required String productId,
    required String collectionId,
  }) async {
    try {
      final userDoc =
          FirebaseFirestore.instance.collection("shop_users").doc(user!.uid);

      final collectionRef = collectionId == 'default'
          ? userDoc.collection('wishlist')
          : userDoc
              .collection('wishlist_collections')
              .doc(collectionId)
              .collection('items');

      await collectionRef.doc(productId).delete();
    } catch (e) {
      print("Error removing from wishlist collection: $e");
      rethrow;
    }
  }

  Future deleteWishlistCollection(String collectionId) async {
    try {
      // First delete all items in the collection
      final itemsSnapshot = await FirebaseFirestore.instance
          .collection("shop_users")
          .doc(user!.uid)
          .collection("wishlist_collections")
          .doc(collectionId)
          .collection("items")
          .get();

      for (var doc in itemsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Then delete the collection itself
      await FirebaseFirestore.instance
          .collection("shop_users")
          .doc(user!.uid)
          .collection("wishlist_collections")
          .doc(collectionId)
          .delete();
    } catch (e) {
      print("Error deleting wishlist collection: $e");
      rethrow;
    }
  }

  Future moveToWishlist({
    required String productId,
    required String sourceCollectionId,
    required String targetCollectionId,
  }) async {
    try {
      // Get the item data from source collection
      final sourceCollection = sourceCollectionId == 'default'
          ? 'wishlist'
          : 'wishlist_collections/$sourceCollectionId/items';

      final itemDoc = await FirebaseFirestore.instance
          .collection("shop_users")
          .doc(user!.uid)
          .collection(sourceCollection)
          .doc(productId)
          .get();

      if (itemDoc.exists) {
        // Add to target collection
        await addToWishlistCollection(
          productId: productId,
          collectionId: targetCollectionId,
        );

        // Remove from source collection
        await removeFromWishlistCollection(
          productId: productId,
          collectionId: sourceCollectionId,
        );
      }
    } catch (e) {
      print("Error moving item between wishlists: $e");
      rethrow;
    }
  }
}