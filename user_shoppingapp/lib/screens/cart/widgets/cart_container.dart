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
        const SnackBar(
          content: Text("Maximum Quantity reached"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Provider.of<CartProvider>(context, listen: false).updateCartQuantity(
      widget.productId,
      count + 1,
      size: currentSize,
      color: currentColor,
    );
  }

  decreaseCount() async {
    if (count > 1) {
      Provider.of<CartProvider>(context, listen: false).updateCartQuantity(
        widget.productId,
        count - 1,
        size: currentSize,
        color: currentColor,
      );
    } else {
      Provider.of<CartProvider>(context, listen: false)
          .deleteItem(widget.productId, currentSize, currentColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final cartItem = cartProvider.carts.firstWhere(
          (item) =>
              item.productId == widget.productId &&
              item.selectedSize == currentSize &&
              item.selectedColor == currentColor,
          orElse: () => CartModel(
              productId: widget.productId,
              quantity: widget.selectedQuantity,
              selectedSize: currentSize,
              selectedColor: currentColor),
        );
        count = cartItem.quantity;
        currentSize = cartItem.selectedSize;
        currentColor = cartItem.selectedColor;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                ProductDetails(widget: widget),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (widget.availableSizes.isNotEmpty) ...[
                      const Text("Size:", style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      DropdownButton<String>(
                        value: currentSize,
                        isDense: true,
                        items: widget.availableSizes
                            .map((size) => DropdownMenuItem(
                                  value: size,
                                  child: Text(size, style: const TextStyle(fontSize: 14)),
                                ))
                            .toList(),
                        onChanged: (value) {
                          currentSize = value;
                          Provider.of<CartProvider>(context, listen: false)
                              .updateVariants(widget.productId, size: value);
                        },
                      ),
                      const SizedBox(width: 16),
                    ],
                    if (widget.availableColors.isNotEmpty) ...[
                      const Text("Color:", style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      DropdownButton<String>(
                        value: currentColor,
                        isDense: true,
                        items: widget.availableColors
                            .map((color) => DropdownMenuItem(
                                  value: color,
                                  child: Text(color, style: const TextStyle(fontSize: 14)),
                                ))
                            .toList(),
                        onChanged: (value) {
                          currentColor = value;
                          Provider.of<CartProvider>(context, listen: false)
                              .updateVariants(widget.productId, color: value);
                        },
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text("Qty:", style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: decreaseCount,
                            icon: const Icon(Icons.remove, size: 16),
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              "$count",
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          IconButton(
                            onPressed: () => increaseCount(widget.maxQuantity),
                            icon: const Icon(Icons.add, size: 16),
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "₹${widget.new_price * count}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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