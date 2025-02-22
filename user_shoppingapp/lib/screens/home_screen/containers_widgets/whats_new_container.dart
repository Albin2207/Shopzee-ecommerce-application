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
                  child: Builder(
                    builder: (context) => GestureDetector(
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
              ),

              const SizedBox(width: 16),

              // Right Column with Image + Text
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    // Top Right Box (Replaced with Custom Image)
                    AspectRatio(
                      aspectRatio: 0.6,
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(context, "/discount"),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            "assets/percent-discount-adoption-statistics-offer.jpg", 
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Bottom Right - Text Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Exciting New Arrivals!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
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
