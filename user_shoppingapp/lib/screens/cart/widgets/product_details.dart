
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_shoppingapp/provider/cart_provider.dart';
import 'package:user_shoppingapp/screens/cart/widgets/cart_container.dart';
import 'package:user_shoppingapp/utils/constants/discount.dart';

class ProductDetails extends StatelessWidget {
  const ProductDetails({
    super.key,
    required this.widget,
  });

  final CartContainer widget;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
            height: 80, width: 80, child: Image.network(widget.image)),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    "₹${widget.old_price}",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.lineThrough),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "₹${widget.new_price}",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_downward,
                    color: Colors.green,
                    size: 20,
                  ),
                  Text(
                    "${discountPercent(widget.old_price, widget.new_price)}%",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                ],
              )
            ],
          ),
        ),
        IconButton(
            onPressed: () async {
              Provider.of<CartProvider>(context, listen: false)
                  .deleteItem(widget.productId, widget.selectedSize, widget.selectedColor);
            },
            icon: Icon(
              Icons.delete,
              color: Colors.red.shade400,
            ))
      ],
    );
  }
}
