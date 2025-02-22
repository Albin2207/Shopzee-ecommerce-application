import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:user_shoppingapp/models/orders_model.dart';
import 'package:user_shoppingapp/screens/orders_page/widgets/modify_order.dart';

class ViewOrder extends StatefulWidget {
  const ViewOrder({super.key});

  @override
  State<ViewOrder> createState() => _ViewOrderState();
}

class _ViewOrderState extends State<ViewOrder> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as OrdersModel;
    return Scaffold(
      appBar: AppBar(
        title: Text("Order Summary"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  "Delivery Details",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(8),
                color: Colors.grey.shade100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Order Id : ${args.id}"),
                    Text(
                       "Order on ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(args.created_at))} "
                      ),
                    Text("Order by : ${args.name}"),
                    Text("Phone : ${args.phone}"),
                    Text("House Number : ${args.houseNo}"),
                    Text("Area/Colony : ${args.roadName}"),
                    Text("City : ${args.pincode}"),
                    Text("Pincode : ${args.state}"),
                    Text("State : ${args.city}"),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: args.products
                    .map((e) => Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    height: 50,
                                    width: 50,
                                    child: e.images.isNotEmpty
                                        ? PageView.builder(
                                            itemCount: e.images.length,
                                            itemBuilder: (context, imgIndex) {
                                              return Image.network(
                                                e.images[imgIndex],
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    Icon(
                                                        Icons
                                                            .image_not_supported,
                                                        size: 50),
                                              );
                                            },
                                          )
                                        : Icon(Icons.image_not_supported,
                                            size: 50),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(child: Text(e.name)),
                                ],
                              ),
                              Text(
                                "₹${e.single_price.toString()} x ${e.quantity.toString()} quantity",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "₹${e.total_price.toString()}",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Discount : ₹${args.discount}",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    Text(
                      "Total : ₹${args.total}",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    Text(
                      "Status : ${args.status}",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 8,
              ),
              args.status == "PAID" || args.status == "ON_THE_WAY"
                  ? SizedBox(
                      height: 60,
                      width: MediaQuery.of(context).size.width * .9,
                      child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) => ModifyOrder(
                                    order: args,
                                  ));
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white),
                        child: Text("Modify Order"),
                      ),
                    )
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
