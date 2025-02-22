import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_shoppingapp/models/cart_model.dart';
import 'package:user_shoppingapp/models/product_model.dart';
import 'package:user_shoppingapp/provider/cart_provider.dart';

class CartButton extends StatelessWidget {
  const CartButton({
    super.key,
    required this.product,
    required this.selectedSize,
    required this.selectedColor,
  });

  final ProductsModel product;
  final String? selectedSize;
  final String? selectedColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              if (product.sizes.isNotEmpty && selectedSize == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Please select a size")),
                );
                return;
              }
              if (product.colors.isNotEmpty && selectedColor == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Please select a color")),
                );
                return;
              }
              
              Provider.of<CartProvider>(context, listen: false).addToCart(
                CartModel(
                  productId: product.id,
                  quantity: 1,
                  selectedSize: selectedSize,
                  selectedColor: selectedColor,
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Added to cart")),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: Text("Add to Cart"),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              if (product.sizes.isNotEmpty && selectedSize == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Please select a size")),
                );
                return;
              }
              if (product.colors.isNotEmpty && selectedColor == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Please select a color")),
                );
                return;
              }
              
              Provider.of<CartProvider>(context, listen: false).addToCart(
                CartModel(
                  productId: product.id,
                  quantity: 1,
                  selectedSize: selectedSize,
                  selectedColor: selectedColor,
                ),
              );
              Navigator.pushNamed(context, "/checkout");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
            ),
            child: Text("Buy Now"),
          ),
        ),
      ],
    );
  }
}
