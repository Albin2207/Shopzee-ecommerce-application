import 'package:flutter/material.dart';
import 'package:user_shoppingapp/main.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<Color?> _backgroundColorAnimation;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _backgroundColorAnimation = ColorTween(
      begin: Colors.black,
      end: Colors.green[300],
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _fadeInAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward().whenComplete(() => _navigateToNextScreen());
  }

  void _navigateToNextScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const CheckUser()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          // Gradient background
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black, 
                  _backgroundColorAnimation.value ?? Colors.green[300]!,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Rotating Logo
                  Transform.rotate(
                    angle: _rotationAnimation.value * 2 * 3.14159, // 360 degrees
                    child: Image.asset(
                      Theme.of(context).brightness == Brightness.dark
                          ? 'assets/logos/t-store-splash-logo-white.png'
                          : 'assets/logos/t-store-splash-logo-black.png',
                      width: 250,
                      height: 250,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Gradient Text
                  ShaderMask(
                    shaderCallback: (rect) => LinearGradient(
                      colors: [
                        Colors.white, 
                        Colors.black,
                      ],
                    ).createShader(rect),
                    child: Opacity(
                      opacity: _fadeInAnimation.value,
                      child: Text(
                        "Shopzee",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, 
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
