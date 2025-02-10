import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_shoppingapp/provider/user_provider.dart';
import 'package:user_shoppingapp/screens/update_profile_screen.dart';
import 'package:user_shoppingapp/widgets/common_appbar.dart';
import 'package:user_shoppingapp/widgets/list_tile_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: GlobalAppBar(
        title: "Profile",
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: const Image(
                        image: AssetImage('assets/images/products/user_img.jpg'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                authProvider.name,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Text(
                authProvider.email,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UpdateProfile(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.yellow,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text("Edit Profile"),
                ),
              ),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 30),
              
              Listtile(
                title: 'Orders',
                icon: Icons.local_shipping_outlined,
                onPress: () {
                  Navigator.pushNamed(context, "/orders");
                },
              ),
              const Divider(thickness: 1, endIndent: 10, indent: 10),
              Listtile(
                title: 'Discount & Offers',
                icon: Icons.discount_outlined,
                onPress: () {
                  Navigator.pushNamed(context, "/discount");
                },
              ),
              const Divider(thickness: 1, endIndent: 10, indent: 10),
               Listtile(
                title: 'Saved Address',
                icon: Icons.discount_outlined,
                onPress: () {
                  Navigator.pushNamed(context, "/address");
                },
              ),
               const Divider(thickness: 1, endIndent: 10, indent: 10),
               Listtile(
                title: 'Terms, Policiees & Connditions',
                icon: Icons.discount_outlined,
                onPress: () {
                  Navigator.pushNamed(context, "/terms_policies");
                },
              ),
              const Divider(thickness: 1, endIndent: 10, indent: 10),
              Listtile(
                title: 'Help & Support',
                icon: Icons.support_agent,
                onPress: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Mail us at thomasalbin35gmail.com"),
                    ),
                  );
                },
              ),
              const Divider(thickness: 1, endIndent: 10, indent: 10),
              Listtile(
                title: 'Logout',
                icon: Icons.logout,
                textColor: Colors.red,
                onPress: () async {
                  final confirmLogout = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Logout Confirmation"),
                      content: const Text("Are you sure you want to logout?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Logout"),
                        ),
                      ],
                    ),
                  );

                  if (confirmLogout == true) {
                    await authProvider.logout();
                    Navigator.pushNamedAndRemoveUntil(
                        context, "/login", (route) => false);
                  }
                },
                endIcon: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}