import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:user_shoppingapp/controllers/database_service.dart';

class WishlistProvider with ChangeNotifier {
  final DbService _dbService = DbService();
  Map<String, List<String>> _wishlistedItemsByCollection = {};
  final String _defaultCollectionId = 'default';

  Map<String, List<String>> get wishlistedItemsByCollection => _wishlistedItemsByCollection;
  String get defaultCollectionId => _defaultCollectionId;

  // Fixed: Properly check if item is wishlisted in any collection
  bool isWishlisted(String productId) {
    return _wishlistedItemsByCollection.values
        .any((items) => items.contains(productId));
  }

  // Fixed: Check collection membership with null safety
  bool isWishlistedInCollection(String productId, String collectionId) {
    final items = _wishlistedItemsByCollection[collectionId];
    return items != null && items.contains(productId);
  }

  // Fixed: Load collection items with proper path structure
  Future<void> loadCollectionItems(String collectionId) async {
    try {
      final userDoc = FirebaseFirestore.instance
          .collection("shop_users")
          .doc(_dbService.user!.uid);
          
      final snapshot = collectionId == 'default'
          ? await userDoc.collection('wishlist').get()
          : await userDoc
              .collection('wishlist_collections')
              .doc(collectionId)
              .collection('items')
              .get();
      
      _wishlistedItemsByCollection[collectionId] = 
          snapshot.docs.map((doc) => doc.data()['product_id'] as String).toList();
      
      notifyListeners();
    } catch (e) {
      print("Error loading collection items: $e");
      _wishlistedItemsByCollection[collectionId] = [];
      notifyListeners();
    }
  }

  // Fixed: Toggle wishlist with proper error handling and state management
  Future<void> toggleWishlist(String productId, String collectionId) async {
    try {
      if (isWishlistedInCollection(productId, collectionId)) {
        await _dbService.removeFromWishlistCollection(
          productId: productId,
          collectionId: collectionId,
        );
        _wishlistedItemsByCollection[collectionId]?.remove(productId);
      } else {
        await _dbService.addToWishlistCollection(
          productId: productId,
          collectionId: collectionId,
        );
        if (!_wishlistedItemsByCollection.containsKey(collectionId)) {
          _wishlistedItemsByCollection[collectionId] = [];
        }
        _wishlistedItemsByCollection[collectionId]!.add(productId);
      }
      notifyListeners();
    } catch (e) {
      print("Error in toggleWishlist: $e");
      // Reload collection to ensure UI is in sync with database
      await loadCollectionItems(collectionId);
      rethrow;
    }
  }

  // Fixed: Load all wishlists with proper initialization
  Future<void> loadAllWishlists() async {
    try {
      // Clear existing data
      _wishlistedItemsByCollection.clear();
      
      // Load default wishlist
      await loadCollectionItems('default');

      // Load custom collections
      final collectionsSnapshot = await FirebaseFirestore.instance
          .collection("shop_users")
          .doc(_dbService.user!.uid)
          .collection("wishlist_collections")
          .get();

      for (var collection in collectionsSnapshot.docs) {
        await loadCollectionItems(collection.id);
      }
    } catch (e) {
      print("Error loading all wishlists: $e");
      // Initialize empty state on error
      _wishlistedItemsByCollection = {'default': []};
      notifyListeners();
    }
  }
  Future<void> createWishlistCollection(String name, {String? description}) async {
    await _dbService.createWishlistCollection(
      name: name,
      description: description,
    );
    notifyListeners();
  }
}