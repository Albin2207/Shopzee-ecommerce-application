import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:user_shoppingapp/controllers/database_service.dart';
import 'package:user_shoppingapp/models/promo_banners_model.dart';

class PromoContainer extends StatefulWidget {
  final double width; 
  final double height; 

  const PromoContainer({super.key, this.width = 700, this.height = 400});

  @override
  State<PromoContainer> createState() => _PromoContainerState();
}

class _PromoContainerState extends State<PromoContainer> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: DbService().readPromos(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<PromoBannersModel> promos =
              PromoBannersModel.fromJsonList(snapshot.data!.docs);
          if (promos.isEmpty) {
            return SizedBox();
          } else {
            return Container(
              margin: EdgeInsets.symmetric(vertical: 8),
              child: CarouselSlider(
                items: promos.map((promo) => 
                  Hero(
                    tag: 'promo-${promo.category}',
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(12),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context, 
                            "/specific",
                            arguments: {"name": promo.category}
                          );
                        },
                        child: Container(
                          width: widget.width, // Use adjustable width
                          height: widget.height, // Use adjustable height
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              promo.image,
                              width: widget.width,
                              height: widget.height,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                          (loadingProgress.expectedTotalBytes ?? 1)
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/placeholder.png', // Provide a default placeholder
                                  width: widget.width,
                                  height: widget.height,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ).toList(),
                options: CarouselOptions(
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 5),
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  aspectRatio: widget.width / widget.height,
                  viewportFraction: 0.92,
                  enlargeCenterPage: true,
                  enlargeFactor: 0.3,
                  scrollDirection: Axis.horizontal,
                ),
              ),
            );
          }
        } else {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: widget.height,
              width: widget.width,
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
    );
  }
}
