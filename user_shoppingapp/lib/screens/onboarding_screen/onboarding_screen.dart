import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:user_shoppingapp/screens/onboarding_screen/widgets/onboarding_widget.dart';
import 'package:user_shoppingapp/utils/constants/image_strings.dart';
import 'package:user_shoppingapp/utils/constants/text_strings.dart';

class OnboardingProvider extends ChangeNotifier {
  BuildContext? context;
  final PageController pageController = PageController();
  int currentPage = 0;
  bool isLastPage = false;

  void setContext(BuildContext ctx) {
    context = ctx;
  }

  void updatePageIndicator(int page) {
    currentPage = page;
    isLastPage = currentPage == 2;
    notifyListeners();
  }

  void skipPage() {
    if (context != null) {
      Navigator.pushReplacementNamed(context!, "/login");
    }
  }

  void nextPage() {
    if (isLastPage) {
      skipPage();
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutQuart,
      );
    }
  }

  void dotNavigationClick(int page) {
    pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutQuart,
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ChangeNotifierProvider(
      create: (_) {
        final provider = OnboardingProvider();
        provider.setContext(context);
        return provider;
      },
      child: Scaffold(
        body: Consumer<OnboardingProvider>(
          builder: (context, provider, _) => Stack(
            children: [
              // Background gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDarkMode 
                      ? [Colors.blue.shade900, Colors.black]
                      : [Colors.white, Colors.grey.shade100],
                  ),
                ),
              ),

              // PageView with pages
              PageView(
                controller: provider.pageController,
                onPageChanged: provider.updatePageIndicator,
                children: const [
                  OnBoardingPage(
                    image: TImages.onBoardingImage1,
                    title: TTexts.onBoardingTitle1,
                    subtitle: TTexts.onBoardingSubTitle1,
                  ),
                  OnBoardingPage(
                    image: TImages.onBoardingImage2,
                    title: TTexts.onBoardingTitle2,
                    subtitle: TTexts.onBoardingSubTitle2,
                  ),
                  OnBoardingPage(
                    image: TImages.onBoardingImage3,
                    title: TTexts.onBoardingTitle3,
                    subtitle: TTexts.onBoardingSubTitle3,
                  ),
                ],
              ),

              // Skip button with animation
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                right: 16,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: provider.isLastPage ? 0.0 : 1.0,
                  child: TextButton(
                    onPressed: provider.isLastPage ? null : provider.skipPage,
                    style: TextButton.styleFrom(
                      backgroundColor: isDarkMode 
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom navigation area
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        isDarkMode 
                          ? Colors.black.withOpacity(0.8)
                          : Colors.white.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Page indicator
                      SmoothPageIndicator(
                        controller: provider.pageController,
                        count: 3,
                        onDotClicked: provider.dotNavigationClick,
                        effect: ExpandingDotsEffect(
                          activeDotColor: isDarkMode 
                            ? Colors.blue 
                            : Colors.black,
                          dotColor: isDarkMode 
                            ? Colors.white38 
                            : Colors.black26,
                          dotHeight: 8,
                          dotWidth: 8,
                          spacing: 6,
                          expansionFactor: 4,
                        ),
                      ),

                      // Animated next/finish button
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: ElevatedButton(
                          onPressed: provider.nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDarkMode 
                              ? Colors.blue 
                              : Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 3,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                provider.isLastPage ? 'Get Started' : 'Next',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                provider.isLastPage 
                                  ? Iconsax.login
                                  : Iconsax.arrow_right_3,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}