import 'package:flutter/material.dart';
import 'package:user_shoppingapp/screens/home_screen/containers_widgets/featured_container.dart';

class WhatsNewGrid extends StatelessWidget {
  const WhatsNewGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "WHAT'S NEW?" Header
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "WHAT'S NEW?",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w300,
              letterSpacing: 1.5,
              color: Colors.black87,
            ),
          ),
        ),

        // Grid Layout
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Large Left Box with Image Preview for FeaturedPage
              Expanded(
                flex: 3,
                child: AspectRatio(
                  aspectRatio: 0.6,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FeaturedPage(),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        "assets/west.jpg",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Right Column with Two Text Boxes
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                  
                    SizedBox(
                      height: 210, 
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(context, "/discount"),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 228, 171, 84),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Text(
                              "Exclusive Discounts Coupons!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Bottom Right 
                    SizedBox(
                      height: 140, 
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Text(
                            "Exciting New Arrivals!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
