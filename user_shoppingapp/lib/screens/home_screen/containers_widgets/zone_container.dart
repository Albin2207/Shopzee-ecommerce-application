import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:user_shoppingapp/models/product_model.dart';
import 'package:user_shoppingapp/utils/constants/discount.dart';
import 'package:user_shoppingapp/controllers/database_service.dart';

class ZoneContainer extends StatefulWidget {
  final String category;
  const ZoneContainer({super.key, required this.category});

  @override
  State<ZoneContainer> createState() => _ZoneContainerState();
}

class _ZoneContainerState extends State<ZoneContainer> {
  Widget specialQuote({required int price, required int dis}) {
    int random = Random().nextInt(2);
    List<String> quotes = ["Starting at ₹$price", "Get upto $dis% off"];
    return Text(
      quotes[random],
      style: TextStyle(
        color: Colors.green.shade600,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: DbService().readProducts(widget.category),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<ProductsModel> products =
              ProductsModel.fromJsonList(snapshot.data!.docs);
          if (products.isEmpty) {
            return Center(
              child: Text(
                "No Products Found",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            );
          } else {
            return AnimatedContainer(
              duration: Duration(milliseconds: 300),
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Header
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      children: [
                        Text(
                          widget.category.substring(0, 1).toUpperCase() +
                              widget.category.substring(1),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade900,
                          ),
                        ),
                        Spacer(),
                        Hero(
                          tag: 'category-${widget.category}',
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  "/specific",
                                  arguments: {"name": widget.category},
                                );
                              },
                              borderRadius: BorderRadius.circular(50),
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.chevron_right,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Products Grid
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (int i = 0;
                          i < (products.length > 4 ? 4 : products.length);
                          i++)
                        TweenAnimationBuilder(
                          duration: Duration(milliseconds: 300 + (i * 100)),
                          tween: Tween<double>(begin: 0, end: 1),
                          builder: (context, double value, child) {
                            return Transform.scale(
                              scale: value,
                              child: child,
                            );
                          },
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                "/view_product",
                                arguments: products[i],
                              );
                            },
                            child: Hero(
                              tag: 'product-${products[i].id}',
                              child: Material(
                                child: Container(
                                  width: MediaQuery.sizeOf(context).width * .43,
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        // ignore: deprecated_member_use
                                        color: Colors.black.withOpacity(0.05),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Product Image
                                      Center(
                                        child: Container(
                                          height: 120,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.network(
                                              products[i].images.isNotEmpty
                                                  ? products[i].images.first
                                                  : products[i].image,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return Shimmer.fromColors(
                                                  baseColor: Colors.grey[300]!,
                                                  highlightColor:
                                                      Colors.grey[100]!,
                                                  child: Container(
                                                    color: Colors.white,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      // Product Name
                                      Text(
                                        products[i].name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      // Price Quote
                                      specialQuote(
                                        price: products[i].new_price,
                                        dis: int.parse(
                                          discountPercent(
                                            products[i].old_price,
                                            products[i].new_price,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            );
          }
        } else {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              margin: EdgeInsets.all(8),
              height: 400,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );
        }
      },
    );
  }
}
