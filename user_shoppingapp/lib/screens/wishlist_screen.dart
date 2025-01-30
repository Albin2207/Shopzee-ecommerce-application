import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_shoppingapp/controllers/database_service.dart';
import 'package:user_shoppingapp/models/cart_model.dart';
import 'package:user_shoppingapp/models/product_model.dart';
import 'package:user_shoppingapp/provider/cart_provider.dart';
import 'package:user_shoppingapp/provider/wishlist_provider.dart';
import 'package:user_shoppingapp/widgets/common_appbar.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  bool _isSelecting = false;
  final List<String> _selectedItems = [];

  void _toggleSelection(String productId) {
    setState(() {
      if (_selectedItems.contains(productId)) {
        _selectedItems.remove(productId);
      } else {
        _selectedItems.add(productId);
      }
    });
  }

  void _removeSelectedItems() {
    final wishlistProvider = Provider.of<WishlistProvider>(context, listen: false);
    for (var productId in _selectedItems) {
      wishlistProvider.toggleWishlist(productId);
    }
    setState(() {
      _selectedItems.clear();
      _isSelecting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalAppBar(
        title: _isSelecting ? "Select Items" : "My Wishlist",
      ),
      body: Column(
        children: [
          // 3-Dot Icon Below AppBar
          if (!_isSelecting)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.more_vert),
                    onPressed: () {
                      setState(() {
                        _isSelecting = true;
                      });
                    },
                  ),
                ],
              ),
            ),
          if (_isSelecting)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Select Items",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _isSelecting = false;
                        _selectedItems.clear();
                      });
                    },
                  ),
                ],
              ),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: DbService().readWishlist(),
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
                          "Your wishlist is empty",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Save items you love to your wishlist",
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

                final productIds = wishlistSnapshot.data!.docs
                    .map((doc) => doc['product_id'] as String)
                    .toList();

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
                        return Dismissible(
                          key: Key(product.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(right: 20),
                            color: Colors.red,
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (direction) {
                            // Remove the item from the wishlist
                            Provider.of<WishlistProvider>(context, listen: false)
                                .toggleWishlist(product.id);
                          },
                          child: Card(
                            margin: EdgeInsets.only(bottom: 16),
                            child: InkWell(
                              onTap: () {
                                if (_isSelecting) {
                                  _toggleSelection(product.id);
                                } else {
                                  Navigator.pushNamed(
                                    context,
                                    '/view_product',
                                    arguments: product,
                                  );
                                }
                              },
                              onLongPress: () {
                                setState(() {
                                  _isSelecting = true;
                                  _toggleSelection(product.id);
                                });
                              },
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Product Image
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
                                    // Product Details
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
                                              if (product.maxQuantity > 0 && !_isSelecting)
                                                TextButton.icon(
                                                  onPressed: () {
                                                    // Add to cart logic
                                                    Provider.of<CartProvider>(context, listen: false)
                                                        .addToCart(CartModel(
                                                      productId: product.id,
                                                      quantity: 1,
                                                      selectedSize: product.sizes.isNotEmpty
                                                          ? product.sizes.first
                                                          : null,
                                                      selectedColor: product.colors.isNotEmpty
                                                          ? product.colors.first
                                                          : null,
                                                    ));
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text("Added to cart"),
                                                      ),
                                                    );
                                                  },
                                                  icon: Icon(Icons.shopping_cart),
                                                  label: Text("Add to Cart"),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (_isSelecting)
                                      Checkbox(
                                        value: _selectedItems.contains(product.id),
                                        onChanged: (value) {
                                          _toggleSelection(product.id);
                                        },
                                      ),
                                  ],
                                ),
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
          ),
          if (_isSelecting)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${_selectedItems.length} items selected",
                    style: TextStyle(fontSize: 16),
                  ),
                  ElevatedButton(
                    onPressed: _removeSelectedItems,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    child: Text("Remove from Wishlist"),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}