import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_shoppingapp/containers/cart_container.dart';
import 'package:user_shoppingapp/provider/cart_provider.dart';
import 'package:user_shoppingapp/widgets/common_appbar.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalAppBar(
        title: "Your Cart",
      ),
      body: Consumer<CartProvider>(
        builder: (context, value, child) {
          if (value.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (value.carts.isEmpty) {
            return const Center(child: Text("No items in cart"));
          }

          // Make sure we have matching products for each cart item
          return ListView.builder(
            itemCount: value.carts.length,
            itemBuilder: (context, index) {
              // Safety check for index bounds
              if (index >= value.products.length || index >= value.carts.length) {
                return const SizedBox();
              }

              final cartItem = value.carts[index];
              final product = value.products[index];

              return CartContainer(
                image: product.images.isNotEmpty 
                    ? product.images.first 
                    : product.image,
                name: product.name,
                new_price: product.new_price,
                old_price: product.old_price,
                maxQuantity: product.maxQuantity,
                selectedQuantity: cartItem.quantity,
                selectedSize: cartItem.selectedSize,
                selectedColor: cartItem.selectedColor,
                productId: product.id,
              );
            },
          );
        },
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, value, child) {
          if (value.carts.isEmpty) {
            return const SizedBox();
          }

          return Container(
            width: double.infinity,
            height: 60,
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total : ₹${value.totalCost}",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/checkout");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Proceed to Checkout"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}