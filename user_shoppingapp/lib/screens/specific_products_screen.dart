import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_shoppingapp/controllers/database_service.dart';
import 'package:user_shoppingapp/models/product_model.dart';
import 'package:user_shoppingapp/provider/wishlist_provider.dart';
import 'package:user_shoppingapp/utils/constants/discount.dart';
import 'package:user_shoppingapp/widgets/wishlist_dialog.dart';


class SpecificProducts extends StatefulWidget {
  const SpecificProducts({super.key});

  @override
  State<SpecificProducts> createState() => _SpecificProductsState();
}

class _SpecificProductsState extends State<SpecificProducts> {
  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        forceMaterialTransparency: true,
        title: Text(
          "${args["name"].substring(0, 1).toUpperCase()}${args["name"].substring(1)}",
        ),
      ),
      body: StreamBuilder(
        stream: DbService().readProducts(args["name"]),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<ProductsModel> products =
                ProductsModel.fromJsonList(snapshot.data!.docs);

            if (products.isEmpty) {
              return const Center(
                child: Text("No products found."),
              );
            } else {
              return GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Number of items per row
                  crossAxisSpacing: 8.0, // Space between items horizontally
                  mainAxisSpacing: 8.0, // Space between items vertically
                  childAspectRatio: 0.7, // Adjust aspect ratio
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, "/view_product",
                          arguments: product);
                    },
                    child: Card(
                      color: Colors.grey.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
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
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  product.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      "₹${product.old_price}",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "₹${product.new_price}",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.arrow_downward,
                                      color: Colors.green,
                                      size: 14,
                                    ),
                                    Text(
                                      "${discountPercent(product.old_price, product.new_price)}%",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Consumer<WishlistProvider>(
                              builder: (context, wishlistProvider, child) {
                                return IconButton(
                                  icon: Icon(
                                    wishlistProvider.isWishlisted(product.id)
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: wishlistProvider.isWishlisted(product.id)
                                        ? Colors.red
                                        : null,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => WishlistSelectionDialog(
                                        productId: product.id,
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
