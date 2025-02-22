

import 'package:flutter/material.dart';
import 'package:user_shoppingapp/provider/user_provider.dart';
import 'package:user_shoppingapp/widgets/list_tile_widget.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({
    super.key,
    required this.authProvider,
  });

  final UserProvider authProvider;

  @override
  Widget build(BuildContext context) {
    return Listtile(
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
    );
  }
}