import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:user_shoppingapp/utils/constants/image_strings.dart';
import 'package:user_shoppingapp/utils/constants/text_strings.dart';


class OnboardingProvider extends ChangeNotifier {
  BuildContext? context;
  final PageController pageController = PageController();
  int currentPage = 0;

  // Add a method to set context
  void setContext(BuildContext ctx) {
    context = ctx;
  }

  void updatePageIndicator(int page) {
    currentPage = page;
    notifyListeners();
  }

  void skipPage() {
    if (context != null) {
      Navigator.pushReplacementNamed(context!, "/login");
    }
  }


  void nextPage() {
    if (currentPage == 2) {
      skipPage();
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  void dotNavigationClick(int page) {
    pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
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
              PageView(
                controller: provider.pageController,
                onPageChanged: provider.updatePageIndicator,
                children: const [
                  OnBoardingpage(
                    image: TImages.onBoardingImage1,
                    title: TTexts.onBoardingTitle1,
                    subtitle: TTexts.onBoardingSubTitle1,
                  ),
                  OnBoardingpage(
                    image: TImages.onBoardingImage2,
                    title: TTexts.onBoardingTitle2,
                    subtitle: TTexts.onBoardingSubTitle2,
                  ),
                  OnBoardingpage(
                    image: TImages.onBoardingImage3,
                    title: TTexts.onBoardingTitle3,
                    subtitle: TTexts.onBoardingSubTitle3,
                  ),
                ],
              ),

              // Skip button
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                right: 16,
                child: TextButton(
                  onPressed: provider.skipPage,
                  child: const Text('Skip'),
                ),
              ),

              // Page indicator
              Positioned(
                bottom: MediaQuery.of(context).size.height * 0.1 + 25,
                left: 16,
                child: SmoothPageIndicator(
                  controller: provider.pageController,
                  count: 3,
                  onDotClicked: provider.dotNavigationClick,
                  effect: ExpandingDotsEffect(
                    activeDotColor: isDarkMode ? Colors.white : Colors.black,
                    dotHeight: 6,
                  ),
                ),
              ),

              // Next button
              Positioned(
                right: 16,
                bottom: MediaQuery.of(context).size.height * 0.1,
                child: ElevatedButton(
                  onPressed: provider.nextPage,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: isDarkMode ? Colors.blue : Colors.black,
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Icon(Iconsax.arrow_right_3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnBoardingpage extends StatelessWidget {
  const OnBoardingpage({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
  });

  final String image, title, subtitle;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Image(
            width: size.width * 0.8,
            height: size.height * 0.6,
            image: AssetImage(image),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
