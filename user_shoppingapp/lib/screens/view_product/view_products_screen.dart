import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_shoppingapp/models/product_model.dart';
import 'package:user_shoppingapp/screens/view_product/widgets/cart_button.dart';
import 'package:user_shoppingapp/screens/view_product/widgets/provider.dart';
import 'package:user_shoppingapp/screens/view_product/widgets/wishlist_button.dart';
import 'package:user_shoppingapp/utils/constants/discount.dart';
import 'package:user_shoppingapp/widgets/common_appbar.dart';


class ViewProduct extends StatelessWidget {
  const ViewProduct({super.key});

  Widget _buildImageIndicator(int index, int currentIndex) {
    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: currentIndex == index ? Colors.blue : Colors.grey.shade300,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = ModalRoute.of(context)!.settings.arguments as ProductsModel;
    final List<String> displayImages = product.images.isEmpty ? [product.image] : product.images;

    return ChangeNotifierProvider(
      create: (_) => ViewProductProvider(),
      child: Scaffold(
        appBar: GlobalAppBar(title: "Product Details"),
        body: Consumer<ViewProductProvider>(
          builder: (context, provider, child) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      // Image Carousel
                      SizedBox(
                        height: 500,
                        child: PageView.builder(
                          onPageChanged: (index) {
                            provider.setImageIndex(index);
                          },
                          itemCount: displayImages.length,
                          itemBuilder: (context, index) {
                            return Image.network(
                              displayImages[index],
                              fit: BoxFit.contain,
                            );
                          },
                        ),
                      ),
                      // Wishlist button
                      WishlistButton(product: product),
                      // Image indicators
                      if (displayImages.length > 1)
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              displayImages.length,
                              (index) => _buildImageIndicator(
                                index,
                                provider.currentImageIndex,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),

                        // Price information
                        Row(
                          children: [
                            Text(
                              "₹${product.old_price}",
                              style: TextStyle(
                                fontSize: 18,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              "₹${product.new_price}",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            SizedBox(width: 12),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "${discountPercent(product.old_price, product.new_price)}% OFF",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 24),

                        // Size Selection
                        if (product.sizes.isNotEmpty) ...[
                          Text(
                            "Select Size",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: product.sizes.map((size) {
                              bool isSelected = provider.selectedSize == size;
                              return ChoiceChip(
                                label: Text(size),
                                selected: isSelected,
                                onSelected: (selected) {
                                  provider.selectSize(selected ? size : null);
                                },
                                selectedColor: Colors.blue.shade100,
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 16),
                        ],

                        // Color Selection
                        if (product.colors.isNotEmpty) ...[
                          Text(
                            "Select Color",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: product.colors.map((color) {
                              bool isSelected = provider.selectedColor == color;
                              return ChoiceChip(
                                label: Text(color),
                                selected: isSelected,
                                onSelected: (selected) {
                                  provider.selectColor(selected ? color : null);
                                },
                                selectedColor: Colors.blue.shade100,
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 16),
                        ],

                        // Stock Status
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: product.maxQuantity > 0 ? Colors.green.shade50 : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            product.maxQuantity > 0
                                ? "In Stock: ${product.maxQuantity} items left"
                                : "Out of Stock",
                            style: TextStyle(
                              color: product.maxQuantity > 0 ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        SizedBox(height: 16),

                        // Description
                        Text(
                          "Description",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          product.description,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: product.maxQuantity > 0
            ? Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Consumer<ViewProductProvider>(
                  builder: (context, provider, child) {
                    return CartButton(
                      product: product,
                      selectedSize: provider.selectedSize,
                      selectedColor: provider.selectedColor,
                    );
                  },
                ),
              )
            : null,
      ),
    );
  }
}
