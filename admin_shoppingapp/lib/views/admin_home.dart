import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin_shoppingapp/containers/dashboard_text.dart';
import 'package:admin_shoppingapp/containers/home_button.dart';
import 'package:admin_shoppingapp/controllers/auth_service.dart';
import 'package:admin_shoppingapp/providers/admin_provider.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 108, 218, 163),
                const Color.fromARGB(255, 197, 195, 202)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  title: const Text("Logout Confirmation"),
                  content: const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        Provider.of<AdminProvider>(context, listen: false)
                            .cancelProvider();
                        await AuthService().logout();
                        Navigator.pushNamedAndRemoveUntil(
                            context, "/login", (route) => false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.logout, color: Colors.white),
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 60, 19, 163),
              const Color.fromARGB(255, 118, 250, 195)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
                child: Column(
                  children: [
                    _buildStatsCard(context, isMobile, isTablet),
                    const SizedBox(height: 20),
                    _buildActionButtons(context, isMobile, isTablet),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, bool isMobile, bool isTablet) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Consumer<AdminProvider>(
          builder: (context, value, child) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardText(
                keyword: "Total Categories",
                value: "${value.categories.length}",
              ),
              DashboardText(
                keyword: "Total Products",
                value: "${value.products.length}",
              ),
              DashboardText(
                keyword: "Total Orders",
                value: "${value.totalOrders}",
              ),
              DashboardText(
                keyword: "Orders Not Shipped",
                value: "${value.orderPendingProcess}",
              ),
              DashboardText(
                keyword: "Orders Shipped",
                value: "${value.ordersOnTheWay}",
              ),
              DashboardText(
                keyword: "Orders Delivered",
                value: "${value.ordersDelivered}",
              ),
              DashboardText(
                keyword: "Orders Cancelled",
                value: "${value.ordersCancelled}",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isMobile, bool isTablet) {
    return Column(
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            HomeButton(name: "Orders", icon: Icons.shopping_cart, onTap: () => Navigator.pushNamed(context, "/orders")),
            HomeButton(name: "Products", icon: Icons.inventory, onTap: () => Navigator.pushNamed(context, "/products")),
            HomeButton(name: "Promos", icon: Icons.local_offer, onTap: () => Navigator.pushNamed(context, "/promos", arguments: {"promo": true})),
            HomeButton(name: "Banners", icon: Icons.photo_library, onTap: () => Navigator.pushNamed(context, "/promos", arguments: {"promo": false})),
            HomeButton(name: "Categories", icon: Icons.category, onTap: () => Navigator.pushNamed(context, "/category")),
            HomeButton(name: "Coupons", icon: Icons.card_giftcard, onTap: () => Navigator.pushNamed(context, "/coupons")),
            HomeButton(name: "Admin Analytics", icon: Icons.analytics, onTap: () => Navigator.pushNamed(context, "/analytics")),
          ],
        ),
      ],
    );
  }
}
