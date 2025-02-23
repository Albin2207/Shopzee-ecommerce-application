import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_shoppingapp/controllers/database_service.dart';
import 'package:user_shoppingapp/models/cart_model.dart';
import 'package:user_shoppingapp/models/product_model.dart';
import 'package:user_shoppingapp/provider/cart_provider.dart';
import 'package:user_shoppingapp/provider/wishlist_provider.dart';
import 'package:user_shoppingapp/screens/wishlist/widgets/product_card.dart';
import 'package:user_shoppingapp/screens/wishlist/widgets/provider.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  Future<void> _removeSelectedItems(
      BuildContext context,
      WishlistProvider wishlistProvider,
      WishlistSelectionProvider selectionProvider) async {
    final bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Remove Selected Items"),
          content: Text(
              "Are you sure you want to remove ${selectionProvider.selectedProducts.length} items from your wishlist?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("CANCEL"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("REMOVE"),
            ),
          ],
        );
      },
    );

    if (confirm) {
      final productsToRemove =
          Set<String>.from(selectionProvider.selectedProducts);

      selectionProvider.clearSelection();

      for (String productId in productsToRemove) {
        await wishlistProvider.toggleWishlist(productId);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Selected items removed from wishlist"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Consumer2<WishlistProvider, WishlistSelectionProvider>(
          builder: (context, wishlistProvider, selectionProvider, _) {
            return AppBar(
              backgroundColor: Colors.blue,
              title: const Text(
                "My Wishlist",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              actions: [
                if (selectionProvider.isSelectionMode &&
                    selectionProvider.selectedProducts.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _removeSelectedItems(
                        context, wishlistProvider, selectionProvider),
                  ),
                IconButton(
                  icon: Icon(selectionProvider.isSelectionMode
                      ? Icons.close
                      : Icons.checklist),
                  onPressed: selectionProvider.toggleSelectionMode,
                ),
              ],
            );
          },
        ),
      ),
      body: Consumer2<WishlistProvider, WishlistSelectionProvider>(
        builder: (context, wishlistProvider, selectionProvider, _) {
          if (wishlistProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return StreamBuilder<QuerySnapshot>(
            stream: DbService().readWishlist(),
            builder: (context, wishlistSnapshot) {
              if (wishlistSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!wishlistSnapshot.hasData ||
                  wishlistSnapshot.data!.docs.isEmpty) {
                return _buildEmptyWishlist();
              }

              final productIds = wishlistSnapshot.data!.docs
                  .map((doc) => doc['product_id'] as String)
                  .toList();

              return StreamBuilder<QuerySnapshot>(
                stream: DbService().searchProducts(productIds),
                builder: (context, productsSnapshot) {
                  if (!productsSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final products =
                      ProductsModel.fromJsonList(productsSnapshot.data!.docs);

                  if (selectionProvider.isSelectionMode) {
                    return Column(
                      children: [
                        ListTile(
                          leading: Checkbox(
                            value: selectionProvider.selectedProducts.length ==
                                products.length,
                            onChanged: (_) => selectionProvider.toggleSelectAll(
                                products.map((p) => p.id).toList()),
                          ),
                          title: Text(
                            "Select All (${selectionProvider.selectedProducts.length}/${products.length})",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child:
                              _buildProductsList(products, selectionProvider),
                        ),
                      ],
                    );
                  }

                  return _buildProductsList(products, selectionProvider);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyWishlist() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite_border, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            "Your wishlist is empty",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Save items you love to your wishlist",
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/categories'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text("Start Shopping"),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(List<ProductsModel> products,
      WishlistSelectionProvider selectionProvider) {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 0.65,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return WishlistProductCard(
          product: product,
          isSelectionMode: selectionProvider.isSelectionMode,
          isSelected: selectionProvider.selectedProducts.contains(product.id),
          onSelect: () => selectionProvider.toggleProductSelection(product.id),
          onAddToCart: () =>
              Provider.of<CartProvider>(context, listen: false).addToCart(
            CartModel(
              productId: product.id,
              quantity: 1,
              selectedSize:
                  product.sizes.isNotEmpty ? product.sizes.first : null,
              selectedColor:
                  product.colors.isNotEmpty ? product.colors.first : null,
            ),
          ),
        );
      },
    );
  }
}
