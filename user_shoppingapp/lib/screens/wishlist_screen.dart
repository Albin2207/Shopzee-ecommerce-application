import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_shoppingapp/controllers/database_service.dart';
import 'package:user_shoppingapp/models/cart_model.dart';
import 'package:user_shoppingapp/models/product_model.dart';
import 'package:user_shoppingapp/provider/cart_provider.dart';
import 'package:user_shoppingapp/provider/wishlist_provider.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({Key? key}) : super(key: key);

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  bool _isSelectionMode = false;
  Set<String> _selectedProducts = {};

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedProducts.clear();
    });
  }

  void _toggleProductSelection(String productId) {
    setState(() {
      if (_selectedProducts.contains(productId)) {
        _selectedProducts.remove(productId);
      } else {
        _selectedProducts.add(productId);
      }
    });
  }

  void _toggleSelectAll(List<ProductsModel> products) {
    setState(() {
      if (_selectedProducts.length == products.length) {
        _selectedProducts.clear();
      } else {
        _selectedProducts = products.map((p) => p.id).toSet();
      }
    });
  }

  Future<void> _removeSelectedItems(BuildContext context, WishlistProvider wishlistProvider) async {
    final bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Remove Selected Items"),
          content: Text("Are you sure you want to remove ${_selectedProducts.length} items from your wishlist?"),
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
      final productsToRemove = Set<String>.from(_selectedProducts);
      
      setState(() {
        _isSelectionMode = false;
        _selectedProducts.clear();
      });

      for (String productId in productsToRemove) {
        await wishlistProvider.toggleWishlist(productId);
      }
      
      if (mounted) {
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

  Future<void> _addToCart(BuildContext context, ProductsModel product) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

       Provider.of<CartProvider>(context, listen: false).addToCart(
        CartModel(
          productId: product.id,
          quantity: 1,
          selectedSize: product.sizes.isNotEmpty ? product.sizes.first : null,
          selectedColor: product.colors.isNotEmpty ? product.colors.first : null,
        ),
      );

      // Remove loading indicator
      if (mounted) {
        Navigator.pop(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Added to cart"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Remove loading indicator
      if (mounted) {
        Navigator.pop(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to add to cart: ${e.toString()}"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
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
        child: Consumer<WishlistProvider>(
          builder: (context, wishlistProvider, _) {
            return AppBar(
              title: const Text("My Wishlist"),
              actions: [
                if (_isSelectionMode && _selectedProducts.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _removeSelectedItems(context, wishlistProvider),
                  ),
                IconButton(
                  icon: Icon(_isSelectionMode ? Icons.close : Icons.checklist),
                  onPressed: _toggleSelectionMode,
                ),
              ],
            );
          },
        ),
      ),
      body: Consumer<WishlistProvider>(
        builder: (context, wishlistProvider, _) {
          if (wishlistProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return StreamBuilder<QuerySnapshot>(
            stream: DbService().readWishlist(),
            builder: (context, wishlistSnapshot) {
              if (wishlistSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!wishlistSnapshot.hasData || wishlistSnapshot.data!.docs.isEmpty) {
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
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/categories'),
                        child: const Text("Start Shopping"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
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

                  final products = ProductsModel.fromJsonList(productsSnapshot.data!.docs);

                  if (_isSelectionMode) {
                    return Column(
                      children: [
                        ListTile(
                          leading: Checkbox(
                            value: _selectedProducts.length == products.length,
                            onChanged: (_) => _toggleSelectAll(products),
                          ),
                          title: Text(
                            "Select All (${_selectedProducts.length}/${products.length})",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: _buildProductsList(products),
                        ),
                      ],
                    );
                  }

                  return _buildProductsList(products);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProductsList(List<ProductsModel> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 0.65, // Adjusted for better content fit
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return GestureDetector(
          onTap: _isSelectionMode
              ? () => _toggleProductSelection(product.id)
              : () {
                  Navigator.pushNamed(
                    context,
                    '/view_product',
                    arguments: product,
                  );
                },
          child: Card(
            color: Colors.grey.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Container
                    AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Image.network(
                            product.images.isNotEmpty
                                ? product.images.first
                                : product.image,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    color: Colors.grey,
                                    size: 40,
                                  ),
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    // Product Details
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Product Name
                            Text(
                              product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                            if (!_isSelectionMode) ...[
                              // Price and Discount
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "₹${product.old_price}",
                                        style: const TextStyle(
                                          decoration: TextDecoration.lineThrough,
                                          color: Colors.grey,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "₹${product.new_price}",
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                
                                  // Discount and Cart Button
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.arrow_downward,
                                            color: Colors.green,
                                            size: 14,
                                          ),
                                          Text(
                                            "${((product.old_price - product.new_price) / product.old_price * 100).round()}%",
                                            style: const TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (product.maxQuantity > 0)
                                        SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: IconButton(
                                            icon: const Icon(Icons.shopping_cart_outlined),
                                            onPressed: () => _addToCart(context, product),
                                            padding: EdgeInsets.zero,
                                            iconSize: 20,
                                            color: Colors.blue,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Selection Checkbox
                if (_isSelectionMode)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 1,
                          ),
                        ],
                      ),
                      child: Checkbox(
                        value: _selectedProducts.contains(product.id),
                        onChanged: (_) => _toggleProductSelection(product.id),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}