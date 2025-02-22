import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_shoppingapp/models/cart_model.dart';
import 'package:user_shoppingapp/provider/cart_provider.dart';
import 'package:user_shoppingapp/screens/cart/widgets/product_details.dart';

class CartContainer extends StatefulWidget {
  final String image, name, productId;
  final int new_price, old_price, maxQuantity, selectedQuantity;
  final String? selectedSize, selectedColor;
  final List<String> availableSizes;
  final List<String> availableColors;

  const CartContainer({
    super.key,
    required this.image,
    required this.name,
    required this.productId,
    required this.new_price,
    required this.old_price,
    required this.maxQuantity,
    required this.selectedQuantity,
    this.selectedSize,
    this.selectedColor,
    required this.availableSizes,
    required this.availableColors,
  });

  @override
  State<CartContainer> createState() => _CartContainerState();
}

class _CartContainerState extends State<CartContainer> {
  late String? currentSize;
  late String? currentColor;
  late int count;

  @override
  void initState() {
    super.initState();
    currentSize = widget.selectedSize;
    currentColor = widget.selectedColor;
    count = widget.selectedQuantity;
  }

  increaseCount(int max) async {
    if (count >= max) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Maximum Quantity reached")),
      );
      return;
    }

    Provider.of<CartProvider>(context, listen: false).updateCartQuantity(
      widget.productId,
      count + 1, // Increase by 1
      size: currentSize,
      color: currentColor,
    );
  }

  decreaseCount() async {
    if (count > 1) {
      Provider.of<CartProvider>(context, listen: false).updateCartQuantity(
        widget.productId,
        count - 1, // Decrease by 1
        size: currentSize,
        color: currentColor,
      );
    } else {
      // Remove the item if count reaches zero
      Provider.of<CartProvider>(context, listen: false)
          .deleteItem(widget.productId, currentSize, currentColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final cartItem = cartProvider.carts.firstWhere(
          (item) => item.productId == widget.productId && item.selectedSize == currentSize && item.selectedColor == currentColor,
          orElse: () => CartModel(productId: widget.productId, quantity: widget.selectedQuantity, selectedSize: currentSize, selectedColor: currentColor),
        );
        count = cartItem.quantity;
        currentSize = cartItem.selectedSize;
        currentColor = cartItem.selectedColor;

        return Card(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.all(10),
            child: Column(
              children: [
                ProductDetails(widget: widget),
                SizedBox(height: 16),
                if (widget.availableSizes.isNotEmpty)
                  Row(
                    children: [
                      Text("Size: "),
                      DropdownButton<String>(
                        value: currentSize,
                        items: widget.availableSizes
                            .map((size) =>
                                DropdownMenuItem(value: size, child: Text(size)))
                            .toList(),
                        onChanged: (value) {
                          currentSize = value;
                          Provider.of<CartProvider>(context, listen: false)
                              .updateVariants(widget.productId, size: value);
                        },
                      ),
                    ],
                  ),
                if (widget.availableColors.isNotEmpty)
                  Row(
                    children: [
                      Text("Color: "),
                      DropdownButton<String>(
                        value: currentColor,
                        items: widget.availableColors
                            .map((color) => DropdownMenuItem(
                                value: color, child: Text(color)))
                            .toList(),
                        onChanged: (value) {
                          currentColor = value;
                          Provider.of<CartProvider>(context, listen: false)
                              .updateVariants(widget.productId, color: value);
                        },
                      ),
                    ],
                  ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Text("Quantity:"),
                    SizedBox(width: 8),
                    IconButton(
                        onPressed: () async {
                          increaseCount(widget.maxQuantity);
                        },
                        icon: Icon(Icons.add)),
                    Text("$count"),
                    IconButton(
                        onPressed: () async {
                          decreaseCount();
                        },
                        icon: Icon(Icons.remove)),
                    Spacer(),
                    Text("Total: ₹${widget.new_price * count}",
                        style:
                            TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}