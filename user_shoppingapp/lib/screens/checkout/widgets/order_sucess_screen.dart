import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Optional: Change background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/images/animations/order confirmed.json',
              width: 350, // Adjust as needed
              height: 350,
              fit: BoxFit.contain,
              repeat: false,
            ),
            const SizedBox(height: 20),
            const Text(
              "Order Confirmed!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Thank you for your purchase!",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst); // Go back to home
              },
              child: const Text("Continue Shopping"),
            ),
          ],
        ),
      ),
    );
  }
}