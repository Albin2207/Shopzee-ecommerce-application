import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_shoppingapp/firebase_options.dart';
import 'package:user_shoppingapp/provider/address_provider.dart';
import 'package:user_shoppingapp/provider/cart_provider.dart';
import 'package:user_shoppingapp/provider/filter_provider.dart';
import 'package:user_shoppingapp/provider/search_provider.dart';
import 'package:user_shoppingapp/provider/user_provider.dart';
import 'package:user_shoppingapp/provider/wishlist_provider.dart';
import 'package:user_shoppingapp/screens/add_addess_screen.dart';
import 'package:user_shoppingapp/screens/address_screen.dart';
import 'package:user_shoppingapp/screens/cart/cart_screen.dart';
import 'package:user_shoppingapp/screens/categories/categories_screen.dart';
import 'package:user_shoppingapp/screens/checkout/checkout_screen.dart';
import 'package:user_shoppingapp/screens/discount_screen/discount_screen.dart';
import 'package:user_shoppingapp/screens/authentication/login_screen.dart';
import 'package:user_shoppingapp/screens/onboarding_screen/onboarding_screen.dart';
import 'package:user_shoppingapp/screens/orders_page/orders_screen.dart';
import 'package:user_shoppingapp/screens/orders_page/view_order_screen.dart';
import 'package:user_shoppingapp/screens/search/search_screen.dart';
import 'package:user_shoppingapp/screens/authentication/sigup_screen.dart';
import 'package:user_shoppingapp/screens/product_listing_page/specific_products_screen.dart';
import 'package:user_shoppingapp/screens/splash_screen.dart';
import 'package:user_shoppingapp/screens/terms&conditions/terms_policies_screen.dart';
import 'package:user_shoppingapp/screens/update_user_profile/update_profile_screen.dart';
import 'package:user_shoppingapp/screens/view_product/view_products_screen.dart';
import 'package:user_shoppingapp/screens/view_product/widgets/provider.dart';
import 'package:user_shoppingapp/screens/wishlist/widgets/provider.dart';
import 'package:user_shoppingapp/screens/wishlist/wishlist_screen.dart';
import 'package:user_shoppingapp/widgets/bottom_navigationbar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");
  Stripe.publishableKey = dotenv.env["STRIPE_PUBLISH_KEY"]!;
  Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
  Stripe.urlScheme = 'flutterstripe';
  await Stripe.instance.applySettings();

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()..initializeUser()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(
          create: (context) => CartProvider(),
        ),
        ChangeNotifierProvider(create: (_) => FilterProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => SelectedAddressProvider()),
         ChangeNotifierProvider(create: (_) => WishlistSelectionProvider()),
         ChangeNotifierProvider(create: (_) => ViewProductProvider()),


      ],
      child: MaterialApp(
        title: "Shopzee",
        // themeMode: ThemeMode.system,
        // theme: TAppTheme.lightTheme,
        // darkTheme: TAppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: "/splash",
        routes: {
          "/splash": (context) => const SplashScreen(),
          "/onboarding": (context) => OnboardingScreen(),
          "/checkuser": (context) => const CheckUser(),
          "/login": (context) => const LoginPage(),
          "/signup": (context) => const SignupPage(),
          "/home": (context) => const MainPage(),
          "/update_profile": (context) => const UpdateProfile(),
          "/specific": (context) => SpecificProducts(),
          "/view_product": (context) => ViewProduct(),
          "/search_screen": (context) => SearchResultsScreen(),
          "/cart": (context) => CartPage(),
          "/wishlist": (context) => WishlistPage(),
          "/categories": (context) => CategoriesScreen(),
          "/discount": (context) => DiscountPage(),
          "/checkout": (context) => CheckoutPage(),
          "/orders": (context) => OrdersPage(),
          "/view_order": (context) => ViewOrder(),
          "/address": (context) => AddressesPage(),
          "/add_address": (context) => AddAddressPage(),
          "/terms_policies": (context) => TermsConditionsPrivacy()
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
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
  bool isFirstLaunch = await FirstLaunchCheck.isFirstLaunch();
  debugPrint("Is first launch: $isFirstLaunch");

  if (!mounted) return;

  if (isFirstLaunch) {
    Navigator.pushReplacementNamed(context, "/onboarding");
    return; // Stop execution here to prevent further navigation
  }
   // Small delay to ensure the provider is available
  await Future.delayed(Duration(milliseconds: 100));

  try {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.initializeUser();
    debugPrint("User logged in: ${userProvider.isLoggedIn}");

    if (mounted) {
      if (userProvider.isLoggedIn) {
        Navigator.pushReplacementNamed(context, "/home");
      } else {
        Navigator.pushReplacementNamed(context, "/login");
      }
    }
  } catch (e, stackTrace) {
    debugPrint("Error in _checkFirstLaunch: $e\n$stackTrace");
  }
}



  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class FirstLaunchCheck {
  static const String _keyFirstLaunch = 'isFirstLaunch';

  static Future<bool> isFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool(_keyFirstLaunch) ?? true;
    if (isFirstLaunch) {
      await prefs.setBool(_keyFirstLaunch, false);
    }
    return isFirstLaunch;
  }
}