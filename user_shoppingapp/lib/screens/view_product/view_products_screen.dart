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
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: currentIndex == index ? 24 : 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: currentIndex == index ? Colors.blue : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }

  Widget _buildFeatureChip(String text, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.blue),
          SizedBox(width: 4),
          Text(text, style: TextStyle(color: Colors.blue)),
        ],
      ),
    );
  }

  Widget _buildReviewCard(
      String name, String comment, double rating, String date) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey.shade200,
                      child:
                          Text(name[0], style: TextStyle(color: Colors.blue)),
                    ),
                    SizedBox(width: 8),
                    Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Text(date, style: TextStyle(color: Colors.grey)),
              ],
            ),
            SizedBox(height: 8),
            _buildRatingStars(rating),
            SizedBox(height: 8),
            Text(comment),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = ModalRoute.of(context)!.settings.arguments as ProductsModel;
    final List<String> displayImages =
        product.images.isEmpty ? [product.image] : product.images;

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
                  // Image Carousel with zoom capability
                  Stack(
                    children: [
                      Hero(
                        tag: 'product-${product.id}',
                        child: Container(
                          height: 500,
                          child: PageView.builder(
                            onPageChanged: (index) {
                              provider.setImageIndex(index);
                            },
                            itemCount: displayImages.length,
                            itemBuilder: (context, index) {
                              return InteractiveViewer(
                                minScale: 0.5,
                                maxScale: 4,
                                child: Image.network(
                                  displayImages[index],
                                  fit: BoxFit.contain,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      WishlistButton(product: product),
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
                                  index, provider.currentImageIndex),
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
                        SizedBox(height: 8),

                        // Product name
                        Text(
                          product.name,
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 12),

                        // Rating summary
                        Row(
                          children: [
                            _buildRatingStars(4.5),
                            SizedBox(width: 8),
                            Text(
                              "4.5",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              " (245 reviews)",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),

                        // Price information with animation
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
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
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

                        // Product features
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildFeatureChip(
                                "Free Delivery", Icons.local_shipping),
                            _buildFeatureChip("7 Day Return", Icons.replay),
                            _buildFeatureChip(
                                "Genuine Product", Icons.verified),
                          ],
                        ),

                        SizedBox(height: 24),

                        // Size Selection with better visualization
                        if (product.sizes.isNotEmpty) ...[
                          Text(
                            "Select Size",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: product.sizes.map((size) {
                                bool isSelected = provider.selectedSize == size;
                                return Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: InkWell(
                                    onTap: () {
                                      provider
                                          .selectSize(isSelected ? null : size);
                                    },
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 300),
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.blue
                                            : Colors.white,
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.blue
                                              : Colors.grey,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          size,
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          SizedBox(height: 24),
                        ],

                        // Color Selection with color preview
                        if (product.colors.isNotEmpty) ...[
                          Text(
                            "Select Color",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: product.colors.map((color) {
                                bool isSelected =
                                    provider.selectedColor == color;
                                return Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: InkWell(
                                    onTap: () {
                                      provider.selectColor(
                                          isSelected ? null : color);
                                    },
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 300),
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.blue.shade50
                                            : Colors.white,
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.blue
                                              : Colors.grey,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            color,
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.blue
                                                  : Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          SizedBox(height: 24),
                        ],

                        // Stock Status with animation
                        AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: product.maxQuantity > 0
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                product.maxQuantity > 0
                                    ? Icons.check_circle
                                    : Icons.warning,
                                color: product.maxQuantity > 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              SizedBox(width: 8),
                              Text(
                                product.maxQuantity > 0
                                    ? "In Stock: ${product.maxQuantity} items left"
                                    : "Out of Stock",
                                style: TextStyle(
                                  color: product.maxQuantity > 0
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 24),

                        // Description with expandable text
                        Text(
                          "Description",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          product.description,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),

                        SizedBox(height: 24),

                        // Reviews Section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Customer Reviews",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Navigate to all reviews
                                  },
                                  child: Text("See All"),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),

                            // Rating Statistics
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      children: [
                                        Text(
                                          "4.5",
                                          style: TextStyle(
                                            fontSize: 48,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        _buildRatingStars(4.5),
                                        SizedBox(height: 4),
                                        Text(
                                          "245 reviews",
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      children: List.generate(5, (index) {
                                        final rating = 5 - index;
                                        final percentage =
                                            [70, 20, 5, 3, 2][index];
                                        return Padding(
                                          padding:
                                              EdgeInsets.symmetric(vertical: 2),
                                          child: Row(
                                            children: [
                                              Text("$rating"),
                                              SizedBox(width: 8),
                                              Icon(Icons.star,
                                                  size: 16,
                                                  color: Colors.amber),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  child:
                                                      LinearProgressIndicator(
                                                    value: percentage / 100,
                                                    backgroundColor:
                                                        Colors.grey.shade200,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                            Color>(Colors.blue),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Text("$percentage%"),
                                            ],
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 24),

                            // Review Cards
                            _buildReviewCard(
                              "John Doe",
                              "Great product! The quality is excellent and it fits perfectly. Highly recommended!",
                              5.0,
                              "2 days ago",
                            ),
                            _buildReviewCard(
                              "Jane Smith",
                              "Good value for money. Delivery was quick and the product matches the description.",
                              4.0,
                              "1 week ago",
                            ),
                            _buildReviewCard(
                              "Mike Johnson",
                              "Decent product but the color is slightly different from what's shown in the images.",
                              3.5,
                              "2 weeks ago",
                            ),

                            // Write Review Button
                            SizedBox(height: 16),
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // Navigate to write review screen
                                },
                                icon: Icon(Icons.rate_review),
                                label: Text("Write a Review"),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
