import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_shoppingapp/controllers/database_service.dart';
import 'package:user_shoppingapp/models/product_model.dart';
import 'package:user_shoppingapp/models/wishlist_model.dart';
import 'package:user_shoppingapp/widgets/common_appbar.dart';

class WishlistsPage extends StatelessWidget {
  const WishlistsPage({super.key});

  void _createNewCollection(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String name = '';
        String? description;
        
        return AlertDialog(
          title: Text('Create New Wishlist'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Wishlist Name'),
                onChanged: (value) => name = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Description (Optional)'),
                onChanged: (value) => description = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (name.isNotEmpty) {
                  DbService().createWishlistCollection(
                    name: name,
                    description: description,
                  );
                  Navigator.pop(context);
                }
              },
              child: Text('Create'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalAppBar(
        title: "My Wishlists",
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _createNewCollection(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: DbService().readWishlistCollections(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final collections = snapshot.data?.docs ?? [];

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: collections.length + 1, // +1 for default wishlist
            itemBuilder: (context, index) {
              if (index == 0) {
                return _WishlistCard(
                  name: 'Default Wishlist',
                  description: 'Your main wishlist',
                  collectionId: 'default',
                );
              }

              final doc = collections[index - 1];
              final data = doc.data() as Map<String, dynamic>;

              return _WishlistCard(
                name: data['name'] ?? 'Untitled',
                description: data['description'],
                collectionId: doc.id,
                canDelete: true,
              );
            },
          );
        },
      ),
    );
  }
}

class _WishlistCard extends StatelessWidget {
  final String name;
  final String? description;
  final String collectionId;
  final bool canDelete;

  const _WishlistCard({
    required this.name,
    this.description,
    required this.collectionId,
    this.canDelete = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/wishlist_items',
            arguments: {
              'name': name,
              'collection_id': collectionId,
            },
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.favorite_border, size: 32),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (description != null)
                      Text(
                        description!,
                        style: TextStyle(color: Colors.grey),
                      ),
                  ],
                ),
              ),
              if (canDelete)
                IconButton(
                  icon: Icon(Icons.delete_outline),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Delete Wishlist'),
                        content: Text('Are you sure you want to delete this wishlist?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              DbService().deleteWishlistCollection(collectionId);
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// wishlist_items_page.dart - Page showing items in a specific wishlist
class WishlistItemsPage extends StatelessWidget {
  const WishlistItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String collectionName = args['name'];
    final String collectionId = args['collection_id'];

    return Scaffold(
      appBar: GlobalAppBar(
        title: collectionName,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: DbService().readWishlistCollectionItems(collectionId),
        builder: (context, wishlistSnapshot) {
          if (wishlistSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!wishlistSnapshot.hasData || wishlistSnapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "This wishlist is empty",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Add items to your wishlist while shopping",
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/categories'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    child: Text("Start Shopping"),
                  ),
                ],
              ),
            );
          }

          final wishlistItems = wishlistSnapshot.data!.docs
              .map((doc) => WishlistModel.fromJson(doc.data() as Map<String, dynamic>))
              .toList();

          final productIds = wishlistItems.map((item) => item.productId).toList();

          return StreamBuilder<QuerySnapshot>(
            stream: DbService().searchProducts(productIds),
            builder: (context, productsSnapshot) {
              if (!productsSnapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final products = ProductsModel.fromJsonList(productsSnapshot.data!.docs);

              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 16),
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/view_product',
                          arguments: product,
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: NetworkImage(
                                    product.images.isNotEmpty
                                        ? product.images.first
                                        : product.image,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        "₹${product.old_price}",
                                        style: TextStyle(
                                          decoration: TextDecoration.lineThrough,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "₹${product.new_price}",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        product.maxQuantity > 0
                                            ? "In Stock"
                                            : "Out of Stock",
                                        style: TextStyle(
                                          color: product.maxQuantity > 0
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                      PopupMenuButton(
                                        itemBuilder: (context) => [
                                          PopupMenuItem(
                                            value: 'move',
                                            child: Text('Move to another wishlist'),
                                          ),
                                          PopupMenuItem(
                                            value: 'remove',
                                            child: Text('Remove'),
                                          ),
                                        ],
                                        onSelected: (value) async {
                                          if (value == 'move') {
                                            // Show wishlist selection dialog
                                            final collections = await DbService()
                                                .readWishlistCollections()
                                                .first;
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text('Move to Wishlist'),
                                                content: SizedBox(
                                                  width: double.maxFinite,
                                                  child: ListView.builder(
                                                    shrinkWrap: true,
                                                    itemCount: collections.docs.length + 1,
                                                    itemBuilder: (context, index) {
                                                      if (index == 0) {
                                                        return ListTile(
                                                          title: Text('Default Wishlist'),
                                                          onTap: () {
                                                            // Move to default wishlist
                                                            DbService().moveToWishlist(
                                                              productId: product.id,
                                                              sourceCollectionId: collectionId,
                                                              targetCollectionId: 'default',
                                                            );
                                                            Navigator.pop(context);
                                                          },
                                                        );
                                                      }
                                                      final doc = collections.docs[index - 1];
                                                      return ListTile(
                                                        title: Text(doc['name']),
                                                        onTap: () {
                                                          DbService().moveToWishlist(
                                                            productId: product.id,
                                                            sourceCollectionId: collectionId,
                                                            targetCollectionId: doc.id,
                                                          );
                                                          Navigator.pop(context);
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            );
                                          } else if (value == 'remove') {
                                            DbService().removeFromWishlistCollection(
                                              productId: product.id,
                                              collectionId: collectionId,
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}