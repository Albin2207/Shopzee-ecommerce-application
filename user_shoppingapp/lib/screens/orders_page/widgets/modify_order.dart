import 'package:flutter/material.dart';
import 'package:user_shoppingapp/screens/orders_page/widgets/additional_confirm.dart';
import 'package:user_shoppingapp/controllers/database_service.dart';
import 'package:user_shoppingapp/models/orders_model.dart';

class ModifyOrder extends StatefulWidget {
  final OrdersModel order;
  const ModifyOrder({super.key, required this.order});

  @override
  State<ModifyOrder> createState() => _ModifyOrderState();
}

class _ModifyOrderState extends State<ModifyOrder> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Modify this order"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Chosse want you want to do"),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                    context: context,
                    builder: (context) => AdditionalConfirm(
                        contentText:
                            "After canceling this cannot be changed you need to order again.",
                        onYes: () async {
                          await DbService().updateOrderStatus(
                              docId: widget.order.id,
                              data: {"status": "CANCELLED"});
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Order Updated")));
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        onNo: () {
                          Navigator.pop(context);
                        }));
              },
              child: Text("Cancel Order"))
        ],
      ),
    );
  }
}
