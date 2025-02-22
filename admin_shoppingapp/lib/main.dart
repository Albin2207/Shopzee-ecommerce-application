import 'package:admin_shoppingapp/firebase_options.dart';
import 'package:admin_shoppingapp/providers/admin_provider.dart';
import 'package:admin_shoppingapp/controllers/auth_service.dart';
import 'package:admin_shoppingapp/providers/auth_provider.dart';
import 'package:admin_shoppingapp/views/admin_home.dart';
import 'package:admin_shoppingapp/views/categories_page.dart';
import 'package:admin_shoppingapp/views/coupons.dart';
import 'package:admin_shoppingapp/views/login.dart';
import 'package:admin_shoppingapp/views/modify_product.dart';
import 'package:admin_shoppingapp/views/modify_promo.dart';
import 'package:admin_shoppingapp/views/orders_list.dart';
import 'package:admin_shoppingapp/views/products_page.dart';
import 'package:admin_shoppingapp/views/promo_banners_page.dart';
import 'package:admin_shoppingapp/views/statistics_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AdminProvider()),
        ChangeNotifierProvider(create: (context) => AuthStateProvider()),
      ],
      child: MaterialApp(
        title: 'Ecommerce Admin App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        routes: {
          "/": (context) => CheckUser(),
          "/login": (context) => LoginPage(),
          "/home": (context) => AdminHome(),
          "/category": (context) => CategoriesPage(),
          "/products": (context) => ProductsPage(),
          "/add_product": (context) => ModifyProduct(),
          "/promos": (context) => PromoBannersPage(),
          "/update_promo": (context) => ModifyPromo(),
          "/coupons": (context) => CouponsPage(),
          "/orders": (context) => OrdersPage(),
          "/view_order": (context) => ViewOrder(),
          "/analytics": (context) => AnalyticsPage()
        },
      ),
    );
  }
}

class CheckUser extends StatefulWidget {
  const CheckUser({super.key});

  @override
  State<CheckUser> createState() => _CheckUserState();
}

class _CheckUserState extends State<CheckUser> {
  @override
  void initState() {
    AuthService().isLoggedIn().then((value) {
      if (value) {
        Navigator.pushReplacementNamed(context, "/home");
      } else {
        Navigator.pushReplacementNamed(context, "/login");
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
