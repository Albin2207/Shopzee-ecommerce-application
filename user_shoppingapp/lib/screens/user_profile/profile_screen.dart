import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_shoppingapp/provider/user_provider.dart';
import 'package:user_shoppingapp/screens/update_user_profile/update_profile_screen.dart';
import 'package:user_shoppingapp/screens/user_profile/widgets/list_options.dart';
import 'package:user_shoppingapp/screens/user_profile/widgets/logout_button.dart';
import 'package:user_shoppingapp/widgets/common_appbar.dart';

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
                        image:
                            AssetImage('assets/images/user/flat-business-man-user-profile-avatar-icon-vector-4333097.jpg'),
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

              const ProfileOptions(),

              // Logout Button
              LogoutButton(authProvider: authProvider),
            ],
          ),
        ),
      ),
    );
  }
}
