
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_shoppingapp/models/product_model.dart';
import 'package:user_shoppingapp/provider/wishlist_provider.dart';

class WishlistButton extends StatelessWidget {
  const WishlistButton({
    super.key,
    required this.product,
  });

  final ProductsModel product;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      right: 16,
      child: Consumer<WishlistProvider>(
        builder: (context, wishlistProvider, _) {
          final isWishlisted = wishlistProvider.isWishlisted(product.id);
          return Container(
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
            child: IconButton(
              icon: Icon(
                isWishlisted ? Icons.favorite : Icons.favorite_border,
                color: isWishlisted ? Colors.red : Colors.grey,
                size: 28,
              ),
              onPressed: () {
                wishlistProvider.toggleWishlist(product.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isWishlisted
                          ? "Removed from wishlist"
                          : "Added to wishlist",
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}