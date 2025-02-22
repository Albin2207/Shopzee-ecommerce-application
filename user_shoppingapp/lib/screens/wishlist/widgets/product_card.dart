import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_shoppingapp/models/product_model.dart';
import 'package:user_shoppingapp/provider/wishlist_provider.dart';

class WishlistProductCard extends StatelessWidget {
  final ProductsModel product;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onAddToCart;
  
  const WishlistProductCard({
    super.key,
    required this.product,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onSelect,
    required this.onAddToCart,
  });

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Remove from Wishlist"),
          content: const Text("Are you sure you want to remove this item from your wishlist?"),
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
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSelectionMode ? onSelect : () {
        Navigator.pushNamed(context, '/view_product', arguments: product);
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
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      product.images.isNotEmpty ? product.images.first : product.image,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: const Center(child: Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 40)),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      },
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
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                        ),
                        if (!isSelectionMode) ...[
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
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.arrow_downward, color: Colors.green, size: 14),
                                  Text(
                                    "${((product.old_price - product.new_price) / product.old_price * 100).round()}%",
                                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  if (product.maxQuantity > 0)
                                    SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: IconButton(
                                        icon: const Icon(Icons.shopping_cart_outlined),
                                        onPressed: onAddToCart,
                                        padding: EdgeInsets.zero,
                                        iconSize: 20,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () async {
                                        if (await _confirmDelete(context)) {
                                          final wishlistProvider = Provider.of<WishlistProvider>(context, listen: false);
                                          await wishlistProvider.toggleWishlist(product.id);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text("Item removed from wishlist"),
                                                backgroundColor: Colors.green,
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      padding: EdgeInsets.zero,
                                      iconSize: 20,
                                      color: Colors.red,
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
            if (isSelectionMode)
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
                    value: isSelected,
                    onChanged: (_) => onSelect(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}