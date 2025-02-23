import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:user_shoppingapp/models/orders_model.dart';
import 'package:user_shoppingapp/screens/orders_page/widgets/modify_order.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:user_shoppingapp/widgets/common_appbar.dart';

class ViewOrder extends StatefulWidget {
  const ViewOrder({super.key});

  @override
  State<ViewOrder> createState() => _ViewOrderState();
}

class _ViewOrderState extends State<ViewOrder> {
  Widget _buildStatusBadge(String status) {
    final statusConfig = {
      'PAID': StatusInfo(
        color: Colors.blue,
        icon: Icons.payment,
        text: 'Paid',
      ),
      'ON_THE_WAY': StatusInfo(
        color: Colors.orange,
        icon: Icons.local_shipping,
        text: 'On The Way',
      ),
      'DELIVERED': StatusInfo(
        color: Colors.green,
        icon: Icons.check_circle,
        text: 'Delivered',
      ),
      'CANCELED': StatusInfo(
        color: Colors.red,
        icon: Icons.cancel,
        text: 'Canceled',
      ),
    };

    final info = statusConfig[status] ?? statusConfig['CANCELED']!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: info.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: info.color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(info.icon, size: 16, color: info.color),
          const SizedBox(width: 4),
          Text(
            info.text,
            style: TextStyle(
              color: info.color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as OrdersModel;
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: GlobalAppBar(title: 'My Orders'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Badge
              Center(
                child: _buildStatusBadge(args.status),
              ).animate().fadeIn().scale(),

              const SizedBox(height: 20),

              // Delivery Details Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Delivery Details",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ).animate().fadeIn().slideX(),
                      const Divider(height: 20),
                      InfoRow(
                        icon: Icons.numbers,
                        title: "Order ID",
                        value: args.id,
                      ),
                      InfoRow(
                        icon: Icons.calendar_today,
                        title: "Order Date",
                        value: DateFormat('dd MMM yyyy, hh:mm a').format(
                          DateTime.fromMillisecondsSinceEpoch(args.created_at),
                        ),
                      ),
                      InfoRow(
                        icon: Icons.person,
                        title: "Customer",
                        value: args.name,
                      ),
                      InfoRow(
                        icon: Icons.phone,
                        title: "Phone",
                        value: args.phone,
                      ),
                      InfoRow(
                        icon: Icons.home,
                        title: "Address",
                        value: "${args.houseNo}, ${args.roadName}\n${args.city}, ${args.state} - ${args.pincode}",
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn().slideY(),

              const SizedBox(height: 20),
              
              // Order Items Section
              const Text(
                "Order Items",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn().slideX(),
              const SizedBox(height: 10),
              
              ...args.products.asMap().entries.map((entry) {
                final e = entry.value;
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            height: 80,
                            width: 80,
                            child: e.images.isNotEmpty
                                ? PageView.builder(
                                    itemCount: e.images.length,
                                    itemBuilder: (context, imgIndex) {
                                      return Image.network(
                                        e.images[imgIndex],
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.image_not_supported, size: 50),
                                      );
                                    },
                                  )
                                : const Icon(Icons.image_not_supported, size: 50),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "₹${e.single_price} × ${e.quantity} items",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "₹${e.total_price}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate(delay: (100 * entry.key).ms).fadeIn().slideX();
              }).toList(),

              // Price Summary Card
              Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Subtotal
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Subtotal",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            "₹${args.total + args.discount}",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Discount
                      if (args.discount > 0) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Discount",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.green[700],
                              ),
                            ),
                            Text(
                              "-₹${args.discount}",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.green[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      
                      const Divider(),
                      const SizedBox(height: 8),
                      
                      // Final Total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total Amount",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "₹${args.total}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn().slideY(),

              // Modify Order Button
              if (args.status == "PAID" || args.status == "ON_THE_WAY")
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => ModifyOrder(order: args),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Modify Order",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ).animate().fadeIn().scale(),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const InfoRow({
    required this.icon,
    required this.title,
    required this.value,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StatusInfo {
  final Color color;
  final IconData icon;
  final String text;

  StatusInfo({
    required this.color,
    required this.icon,
    required this.text,
  });
}