import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:user_shoppingapp/controllers/database_service.dart';
import 'package:user_shoppingapp/models/orders_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  totalQuantityCalculator(List<OrderProductModel> products) {
    int qty = 0;
    products.map((e) => qty += e.quantity).toList();
    return qty;
  }

  Widget statusIcon(String status) {
    if (status == "PAID") {
      return statusContainer(
          text: "PAID", bgColor: Colors.lightGreen, textColor: Colors.white);
    }
    if (status == "ON_THE_WAY") {
      return statusContainer(
          text: "ON THE WAY", bgColor: Colors.yellow, textColor: Colors.black);
    } else if (status == "DELIVERED") {
      return statusContainer(
          text: "DELIVERED",
          bgColor: Colors.green.shade700,
          textColor: Colors.white);
    } else {
      return statusContainer(
          text: "CANCELED", bgColor: Colors.red, textColor: Colors.white);
    }
  }

  Widget statusContainer(
      {required String text,
      required Color bgColor,
      required Color textColor}) {
    return Container(
      color: bgColor,
      padding: EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(color: textColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Orders",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        scrolledUnderElevation: 0,
        forceMaterialTransparency: true,
      ),
      body: StreamBuilder(
        stream: DbService().readOrders(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<OrdersModel> orders =
                OrdersModel.fromJsonList(snapshot.data!.docs);
            if (orders.isEmpty) {
              return Center(
                child: Text("No orders found"),
              );
            } else {
              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      Navigator.pushNamed(context, "/view_order",
                          arguments: orders[index]);
                    },
                    title: Text(
                        "${totalQuantityCalculator(orders[index].products)} Items Worth ₹ ${orders[index].total}"),
                    subtitle: Text(
                      "Ordered on ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(orders[index].created_at))} "
                      "(${timeago.format(DateTime.fromMillisecondsSinceEpoch(orders[index].created_at))})",
                    ),
                    trailing: statusIcon(orders[index].status),
                  );
                },
              );
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
