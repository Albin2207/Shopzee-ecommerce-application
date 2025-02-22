import 'package:flutter/material.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text('''
Terms and Conditions

Welcome to Shopzee! These Terms and Conditions govern your use of our shopping application...
Terms and Conditions

Last Updated: 09 February 2025.

Welcome to Shopzee! These Terms and Conditions govern your use of our shopping application. By accessing or using the app, you agree to comply with these terms. If you do not agree, please do not use the app.

1. General Information

This application is built for learning and testing purposes as part of a bootcamp project.

Shopzee is not intended for public or commercial use.

The app is provided "as-is" without any warranties or guarantees of service.

We reserve the right to modify, suspend, or discontinue the app at any time without notice.

2. User Responsibilities

You must be at least 18 years old or have parental consent to use the app.

You agree to use the app lawfully and not engage in any fraudulent or harmful activities.

Any purchases or transactions made within the app are simulated and do not involve real monetary transactions.

3. Limitation of Liability

We do not take responsibility for any losses or damages resulting from the use of this app.

The app may contain third-party links; we are not responsible for their content or services.

4. Changes to Terms

We reserve the right to update these terms at any time. Continued use of the app implies acceptance of the latest terms.

For any questions, contact us at thomasalbin35@gmail.com.


          '''),
        ),
      ),
    );
  }
}
