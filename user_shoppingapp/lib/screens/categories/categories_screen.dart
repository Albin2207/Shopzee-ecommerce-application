import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:user_shoppingapp/controllers/database_service.dart';
import 'package:user_shoppingapp/models/category_model.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late PageController _pageController;
  late AnimationController _animationController;
  double _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.8,
      initialPage: _selectedIndex,
    );
    _pageController.addListener(_onPageChanged);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  void _onPageChanged() {
    setState(() {
      _currentPage = _pageController.page!;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: DbService().readCategories(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return _buildShimmerLoading();
          }

          List<CategoriesModel> categories =
              CategoriesModel.fromJsonList(snapshot.data!.docs);

          if (categories.isEmpty) {
            return const Center(child: Text("No categories found"));
          }

          return Stack(
            children: [
              // Expanded background image
              Positioned.fill(
                child: Image.network(
                  categories[_selectedIndex].image,
                  fit: BoxFit.cover,
                ),
              ),
              // Overlay gradient for text visibility
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        // ignore: deprecated_member_use
                        Colors.black.withOpacity(0.3),
                        // ignore: deprecated_member_use
                        Colors.black.withOpacity(0.5),
                      ],
                    ),
                  ),
                ),
              ),
              // Top bar with brand name
              Positioned(
                top: 40,
                left: 20,
                child: Text(
                  'Shopzee',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Category title
              Positioned(
                top: MediaQuery.of(context).size.height * 0.15,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${categories[_selectedIndex].name.substring(0, 1).toUpperCase()}${categories[_selectedIndex].name.substring(1)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      'Collection',
                      style: TextStyle(
                        // ignore: deprecated_member_use
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              // Main category display with 3D effect
              Positioned(
                top: MediaQuery.of(context).size.height * 0.4,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      double difference = index - _currentPage;
                      return Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.002) // perspective
                          ..translate(
                            0.0,
                            difference * 50,
                            difference.abs() * -30,
                          )
                          ..scale(1 - difference.abs() * 0.3),
                        alignment: Alignment.center,
                        child: _buildCategoryPage(categories[index]),
                      );
                    },
                  ),
                ),
              ),
              // Bottom thumbnails with animation
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    // Category name
                    Text(
                      '${categories[_selectedIndex].name.substring(0, 1).toUpperCase()}${categories[_selectedIndex].name.substring(1)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Thumbnails
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          bool isSelected = index == _selectedIndex;
                          return TweenAnimationBuilder(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            tween: Tween<double>(
                              begin: 0,
                              end: isSelected ? 1.0 : 0.0,
                            ),
                            builder: (context, double value, child) {
                              return GestureDetector(
                                onTap: () {
                                  _pageController.animateToPage(
                                    index,
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 8),
                                  transform: Matrix4.identity()
                                    ..translate(
                                      0.0,
                                      -value * 8.0,
                                      value * 8.0,
                                    ),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: 45 + (value * 10),
                                    height: 45 + (value * 10),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.8 + (value * 0.2)),
                                        width: 2 + (value * 1),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(30),
                                      child: Image.network(
                                        categories[index].image,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
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
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryPage(CategoriesModel category) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        "/specific",
        arguments: {"name": category.name},
      ),
      child: Hero(
        tag: 'category_${category.id}',
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              category.image,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        color: Colors.white,
      ),
    );
  }
}