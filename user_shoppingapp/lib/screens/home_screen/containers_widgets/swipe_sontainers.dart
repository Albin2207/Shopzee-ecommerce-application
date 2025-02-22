import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:user_shoppingapp/controllers/database_service.dart';
import 'package:user_shoppingapp/models/promo_banners_model.dart';

class HorizontalPromoContainer extends StatefulWidget {
  final ScrollController? parentScrollController;
  final double width;
  final double height;

  const HorizontalPromoContainer({
    super.key,
    this.parentScrollController,
    this.width = 1000,
    this.height = 600,
  });

  @override
  State<HorizontalPromoContainer> createState() => _HorizontalPromoContainerState();
}

class _HorizontalPromoContainerState extends State<HorizontalPromoContainer> {
  final PageController _horizontalController = PageController();
  int _currentPage = 0;

  void scrollToNextSection() {
    if (widget.parentScrollController != null) {
      final containerHeight = MediaQuery.of(context).size.height * 1.2;
      widget.parentScrollController!.animateTo(
        widget.parentScrollController!.position.pixels + containerHeight,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: DbService().readPromos(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<PromoBannersModel> promos = PromoBannersModel.fromJsonList(snapshot.data!.docs);

          if (promos.isEmpty) {
            return const SizedBox();
          }

          return Stack(
            children: [
              // Full-Screen Container
              SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: PageView.builder(
                  controller: _horizontalController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: promos.length,
                  itemBuilder: (context, index) {
                    final promo = promos[index];
                    return Hero(
                      tag: 'promo-${promo.category}',
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            "/specific",
                            arguments: {"name": promo.category},
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              promo.image,
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              fit: BoxFit.cover, // Ensures full coverage
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
                                  'assets/placeholder.png',
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bottom Page Indicators
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(promos.length, (index) {
                    return Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? Colors.green
                            : Colors.green.withOpacity(0.3),
                      ),
                    );
                  }),
                ),
              ),

              // Scroll Down Button
              Positioned(
                bottom: 70,
                right: 16,
                child: FloatingActionButton(
                  onPressed: scrollToNextSection,
                  backgroundColor: Colors.green,
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    size: 30,
                  ),
                ),
              ),
            ],
          );
        } else {
          // Shimmer effect
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
