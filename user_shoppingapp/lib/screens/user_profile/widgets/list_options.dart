import 'package:flutter/material.dart';
import 'package:user_shoppingapp/widgets/list_tile_widget.dart';

class ProfileOptions extends StatelessWidget {
  const ProfileOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
          icon: Icons.location_on_outlined,
          onPress: () {
            Navigator.pushNamed(context, "/address");
          },
        ),
        const Divider(thickness: 1, endIndent: 10, indent: 10),
        Listtile(
          title: 'Terms, Policies & Conditions',
          icon: Icons.policy_outlined,
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
                content: Text("Mail us at thomasalbin35@gmail.com"),
              ),
            );
          },
        ),
        const Divider(thickness: 1, endIndent: 10, indent: 10),
      ],
    );
  }
}
