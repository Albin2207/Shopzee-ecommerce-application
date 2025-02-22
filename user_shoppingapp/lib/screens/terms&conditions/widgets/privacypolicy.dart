import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text('''
Privacy Policy

Shopzee values your privacy. This Privacy Policy outlines how we collect, use, and protect your information...
rivacy Policy

Last Updated: 09 February 2025.

Shopzee values your privacy. This Privacy Policy outlines how we collect, use, and protect your information when you use our shopping app.

1. Information We Collect

Personal Information: When you sign up, we may collect your name, email, and address.

Usage Data: We may collect app usage details to improve user experience.

Device Information: We may collect information about your device for analytics and troubleshooting.

2. How We Use Your Information

To provide and improve our services.

To manage your account and app functionalities.

To comply with legal requirements if necessary.

3. Data Security

We take reasonable measures to protect your data, but we cannot guarantee complete security.

No sensitive financial information (e.g., credit card details) is stored within the app, as this app is not intended for real-world transactions.

4. Third-Party Services

We may use third-party services such as Firebase for authentication and data storage.

These third-party services have their own privacy policies that we encourage you to review.

5. Non-Public Use Disclaimer

Shopzee is a bootcamp project and is not intended for public use or distribution.

Any data entered in the app should be for testing purposes only.

We do not take responsibility for any misuse of the app.

6. Changes to Privacy Policy

We may update this policy from time to time. Continued use of the app indicates acceptance of any changes.

For any privacy concerns, contact us at thomasalbin35@gmail.com.
          '''),
        ),
      ),
    );
  }
}
