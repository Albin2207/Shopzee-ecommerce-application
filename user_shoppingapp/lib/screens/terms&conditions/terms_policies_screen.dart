import 'package:flutter/material.dart';
import 'package:user_shoppingapp/screens/terms&conditions/widgets/privacypolicy.dart';
import 'package:user_shoppingapp/screens/terms&conditions/widgets/terms.dart';

class TermsConditionsPrivacy extends StatelessWidget {
  const TermsConditionsPrivacy({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Terms & Policies'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Terms & Conditions'),
              Tab(text: 'Privacy Policy'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            TermsConditionsPage(),
            PrivacyPolicyPage(),
          ],
        ),
      ),
    );
  }
}
