import 'package:flutter/material.dart';
import 'package:user_shoppingapp/screens/home_screen/containers_widgets/category_container.dart';
import 'package:user_shoppingapp/screens/discount_screen/widgets/discount_container.dart';
import 'package:user_shoppingapp/screens/home_screen/containers_widgets/home_page_maker_container.dart';
import 'package:user_shoppingapp/screens/home_screen/containers_widgets/swipe_sontainers.dart';
import 'package:user_shoppingapp/screens/home_screen/containers_widgets/whats_new_container.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            HorizontalPromoContainer(),
            WhatsNewGrid(),
            DiscountContainer(),
            CategoryContainer(),
            HomePageMakerContainer(),
          ],
        ),
      ),
    );
  }
}