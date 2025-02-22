import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:user_shoppingapp/screens/home_screen/containers_widgets/banner_container.dart';
import 'package:user_shoppingapp/screens/home_screen/containers_widgets/zone_container.dart';
import 'package:user_shoppingapp/controllers/database_service.dart';
import 'package:user_shoppingapp/models/category_model.dart';
import 'package:user_shoppingapp/models/promo_banners_model.dart';

class HomePageMakerContainer extends StatefulWidget {
  const HomePageMakerContainer({super.key});

  @override
  State<HomePageMakerContainer> createState() => _HomePageMakerContainerState();
}

class _HomePageMakerContainerState extends State<HomePageMakerContainer> {
  int min = 0;

  minCalculator(int a, int b) {
    return min = a > b ? b : a;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: DbService().readCategories(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<CategoriesModel> categories =
                CategoriesModel.fromJsonList(snapshot.data!.docs);
            if (categories.isEmpty) {
              return const SizedBox();
            } else {
              // Filter out "popular items" from categories
              final filteredDocs = snapshot.data!.docs.where((doc) => 
                doc["name"].toString().toLowerCase() != "popular items"
              ).toList();

              return StreamBuilder(
                stream: DbService().readBanners(),
                builder: (context, bannerSnapshot) {
                  if (bannerSnapshot.hasData) {
                    List<PromoBannersModel> banners =
                        PromoBannersModel.fromJsonList(bannerSnapshot.data!.docs);
                    if (banners.isEmpty) {
                      return const SizedBox();
                    } else {
                      return Column(
                        children: [
                          for (int i = 0;
                              i < minCalculator(filteredDocs.length,
                                  bannerSnapshot.data!.docs.length);
                              i++)
                            Column(
                              children: [
                                ZoneContainer(
                                    category: filteredDocs[i]["name"]),
                                BannerContainer(
                                    image: bannerSnapshot.data!.docs[i]["image"],
                                    category: bannerSnapshot.data!.docs[i]["category"])
                              ],
                            )
                        ],
                      );
                    }
                  } else {
                    return const SizedBox();
                  }
                },
              );
            }
          } else {
            return Shimmer(
                gradient: LinearGradient(
                    colors: [Colors.grey.shade200, Colors.white]),
                child: const SizedBox(
                  height: 400,
                  width: double.infinity,
                ));
          }
        });
  }
}