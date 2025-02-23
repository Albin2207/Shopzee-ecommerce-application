import 'package:flutter/material.dart';
import 'package:user_shoppingapp/screens/orders_page/widgets/additional_confirm.dart';
import 'package:user_shoppingapp/controllers/database_service.dart';
import 'package:user_shoppingapp/models/orders_model.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ModifyOrder extends StatefulWidget {
  final OrdersModel order;
  const ModifyOrder({super.key, required this.order});

  @override
  State<ModifyOrder> createState() => _ModifyOrderState();
}

class _ModifyOrderState extends State<ModifyOrder> {
  bool canCancelOrder() {
    // Get current time and order time
    final now = DateTime.now();
    final orderTime = DateTime.fromMillisecondsSinceEpoch(widget.order.created_at);
    
    // Calculate difference in days
    final difference = now.difference(orderTime).inDays;
    
    // Can't cancel if:
    // 1. More than 5 days have passed
    // 2. Order is already on the way
    // 3. Order is already delivered or cancelled
    return difference <= 5 && 
           widget.order.status == "PAID" &&
           !["DELIVERED", "CANCELED", "ON_THE_WAY"].contains(widget.order.status);
  }

  String getCancellationMessage() {
    if (widget.order.status == "ON_THE_WAY") {
      return "Cannot cancel order as it's already on the way";
    } else if (widget.order.status == "DELIVERED") {
      return "Cannot cancel order as it's already delivered";
    } else if (widget.order.status == "CANCELED") {
      return "Order is already cancelled";
    }

    final orderTime = DateTime.fromMillisecondsSinceEpoch(widget.order.created_at);
    final daysLeft = 5 - DateTime.now().difference(orderTime).inDays;
    
    if (daysLeft <= 0) {
      return "Cancellation period has expired (5 days limit)";
    }
    
    return "You can cancel this order within $daysLeft days";
  }

  @override
  Widget build(BuildContext context) {
    final bool canCancel = canCancelOrder();
    
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: Text(
        "Modify Order",
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ).animate().fadeIn().slideX(),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Status Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    getCancellationMessage(),
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().scale(),

          const SizedBox(height: 20),

          // Cancel Order Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: canCancel ? () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => AdditionalConfirm(
                    contentText: "Are you sure you want to cancel this order?\n\n"
                        "• This action cannot be undone\n"
                        "• You'll need to place a new order if needed\n"
                        "• Refund will be processed as per policy",
                    onYes: () async {
                      try {
                        await DbService().updateOrderStatus(
                          docId: widget.order.id,
                          data: {"status": "CANCELLED"}
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Order cancelled successfully"),
                            backgroundColor: Colors.green,
                          )
                        );
                        Navigator.pop(context);
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Failed to cancel order. Please try again."),
                            backgroundColor: Colors.red,
                          )
                        );
                      }
                    },
                    onNo: () {
                      Navigator.pop(context);
                    }
                  ),
                );
              } : null,
              icon: const Icon(Icons.cancel_outlined),
              label: const Text(
                "Cancel Order",
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                disabledBackgroundColor: Colors.grey.shade300,
              ),
            ),
          ).animate().fadeIn().slideY(),

          const SizedBox(height: 12),

          // Close Button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Close",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ).animate().fadeIn().slideY(delay: 100.ms),
        ],
      ),
    );
  }
}