import 'package:flutter/material.dart';
import 'package:user_shoppingapp/widgets/list_tile_widget.dart';

class ProfileOptions extends StatelessWidget {
  const ProfileOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildOptionTile(
            context: context,
            title: 'Orders',
            icon: Icons.local_shipping_outlined,
            onPress: () => Navigator.pushNamed(context, "/orders"),
          ),
          _buildDivider(),
          _buildOptionTile(
            context: context,
            title: 'Discount & Offers',
            icon: Icons.discount_outlined,
            onPress: () => Navigator.pushNamed(context, "/discount"),
          ),
          _buildDivider(),
          _buildOptionTile(
            context: context,
            title: 'Saved Address',
            icon: Icons.location_on_outlined,
            onPress: () => Navigator.pushNamed(context, "/address"),
          ),
          _buildDivider(),
          _buildOptionTile(
            context: context,
            title: 'Terms, Policies & Conditions',
            icon: Icons.policy_outlined,
            onPress: () => Navigator.pushNamed(context, "/terms_policies"),
          ),
          _buildDivider(),
          _buildOptionTile(
            context: context,
            title: 'Help & Support',
            icon: Icons.support_agent,
            onPress: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Mail us at thomasalbin35@gmail.com",
                    style: TextStyle(fontSize: 14),
                  ),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.black87,
                  margin: EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onPress,
  }) {
    return Listtile(
      title: title,
      icon: icon,
      onPress: onPress,
     
    );
  }

  Widget _buildDivider() {
    return const Divider(
      thickness: 0.5,
      endIndent: 16,
      indent: 16,
      height: 1,
      color: Colors.grey,
    );
  }
}