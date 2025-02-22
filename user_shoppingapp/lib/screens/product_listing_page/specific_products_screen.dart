import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_shoppingapp/controllers/database_service.dart';
import 'package:user_shoppingapp/models/product_model.dart';
import 'package:user_shoppingapp/provider/wishlist_provider.dart';
import 'package:user_shoppingapp/screens/product_listing_page/widgets/product_card.dart';


class SpecificProducts extends StatelessWidget {
  const SpecificProducts({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String categoryName = args["name"];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${categoryName.substring(0, 1).toUpperCase()}${categoryName.substring(1)}",
        ),
      ),
      body: StreamBuilder(
        stream: DbService().readProducts(categoryName), // Fetch products from Firebase
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No products found."));
          }

          List<ProductsModel> products = ProductsModel.fromJsonList(snapshot.data!.docs);

          return Consumer<WishlistProvider>(
            builder: (context, wishlistProvider, _) {
              return GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 0.7,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return ProductCard(product: products[index]);
                },
              );
            },
          );
        },
      ),
    );
  }
}
