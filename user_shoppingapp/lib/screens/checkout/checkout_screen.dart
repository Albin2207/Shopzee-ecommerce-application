import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:user_shoppingapp/controllers/database_service.dart';
import 'package:user_shoppingapp/provider/address_provider.dart';
import 'package:user_shoppingapp/provider/cart_provider.dart';
import 'package:user_shoppingapp/provider/user_provider.dart';
import 'package:user_shoppingapp/screens/address_screen.dart';
import 'package:user_shoppingapp/screens/checkout/widgets/order_sucess_screen.dart';
import 'package:user_shoppingapp/screens/checkout/widgets/payment.dart';


class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final TextEditingController _couponController = TextEditingController();
  int discount = 0;
  String discountText = "";

  discountCalculator(int disPercent, int totalCost) {
    discount = (disPercent * totalCost) ~/ 100;
    setState(() {});
  }

  Future<void> initPaymentSheet(int cost) async {
    try {
      final selectedAddressProvider =
          Provider.of<SelectedAddressProvider>(context, listen: false);
      final user = Provider.of<UserProvider>(context, listen: false);
      final deliveryAddress = selectedAddressProvider.getDeliveryAddress(user);

      final data = await createPaymentIntent(
        name: deliveryAddress['name']!,
        phone: deliveryAddress['phone']!,
        pincode: deliveryAddress['pincode']!,
        city: deliveryAddress['city']!,
        state: deliveryAddress['state']!,
        houseNo: deliveryAddress['houseNo']!,
        roadName: deliveryAddress['roadName']!,
        amount: (cost * 100).toString(), 
      );

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          customFlow: false,
          merchantDisplayName: 'Flutter Stripe Store Demo',
          paymentIntentClientSecret: data['client_secret'],
          customerEphemeralKeySecret: data['ephemeralKey'],
          customerId: data['id'],
          style: ThemeMode.dark,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
        scrolledUnderElevation: 0,
        forceMaterialTransparency: true,
      ),
      body: SingleChildScrollView(
        child: Consumer<UserProvider>(
          builder: (context, userData, child) => Consumer<CartProvider>(
            builder: (context, cartData, child) {
              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Delivery Details",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500)),
                    Consumer<SelectedAddressProvider>(
                      builder: (context, addressProvider, _) {
                        final user =
                            Provider.of<UserProvider>(context, listen: false);
                        final deliveryAddress =
                            addressProvider.getDeliveryAddress(user);
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                deliveryAddress['name']!,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${deliveryAddress['houseNo']}, ${deliveryAddress['roadName']}\n'
                                '${deliveryAddress['city']}, ${deliveryAddress['state']} - ${deliveryAddress['pincode']}\n'
                                'Phone: ${deliveryAddress['phone']}',
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const AddressesPage()),
                                    );
                                  },
                                  child: const Text("Change Address"),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Text("Have a coupon?"),
                    Row(
                      children: [
                        SizedBox(
                          width: 200,
                          child: TextFormField(
                            textCapitalization: TextCapitalization.characters,
                            controller: _couponController,
                            decoration: InputDecoration(
                              labelText: "Coupon Code",
                              hintText: "Enter Coupon for extra discount",
                              border: InputBorder.none,
                              filled: true,
                              fillColor: Colors.grey.shade200,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            QuerySnapshot querySnapshot = await DbService()
                                .verifyDiscount(
                                    code: _couponController.text.toUpperCase());

                            if (querySnapshot.docs.isNotEmpty) {
                              QueryDocumentSnapshot doc =
                                  querySnapshot.docs.first;
                              int percent = doc.get('discount');
                              discountText =
                                  "a discount of $percent% has been applied.";
                              discountCalculator(percent, cartData.totalCost);
                            } else {
                              discountText = "No discount code found";
                            }
                            setState(() {});
                          },
                          child: Text("Apply"),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    discountText.isEmpty ? Container() : Text(discountText),
                    const SizedBox(height: 20),
                    const Divider(),
                    Text(
                        "Total Quantity of Products: ${cartData.totalQuantity}",
                        style: const TextStyle(fontSize: 16)),
                    Text("Sub Total: ₹ ${cartData.totalCost}",
                        style: const TextStyle(fontSize: 16)),
                    const Divider(),
                    Text("Extra Discount: - ₹ $discount",
                        style: const TextStyle(fontSize: 16)),
                    const Divider(),
                    Text("Total Payable: ₹ ${cartData.totalCost - discount}",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: Consumer<SelectedAddressProvider>(
        builder: (context, addressProvider, _) {
          return Container(
            height: 60,
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () async {
                final user = Provider.of<UserProvider>(context, listen: false);
                final deliveryAddress =
                    addressProvider.getDeliveryAddress(user);
                final cart = Provider.of<CartProvider>(context, listen: false);

                await initPaymentSheet(cart.totalCost - discount);

                try {
                  await Stripe.instance.presentPaymentSheet();

                  List products = cart.products.asMap().entries.map((entry) {
                    int i = entry.key;
                    var product = entry.value;
                    return {
                      "id": product.id,
                      "name": product.name,
                      "images": product.images,
                      "single_price": product.new_price,
                      "total_price": product.new_price * cart.carts[i].quantity,
                      "quantity": cart.carts[i].quantity
                    };
                  }).toList();

                  Map<String, dynamic> orderData = {
                    "user_id": FirebaseAuth.instance.currentUser!.uid,
                    ...deliveryAddress,
                    "discount": discount,
                    "total": cart.totalCost - discount,
                    "products": products,
                    "status": "PAID",
                    "created_at": DateTime.now().millisecondsSinceEpoch
                  };

                  await DbService().createOrder(data: orderData);

                  // Reduce product quantities
                  for (int i = 0; i < cart.products.length; i++) {
                    await DbService().reduceQuantity(
                      productId: cart.products[i].id,
                      quantity: cart.carts[i].quantity,
                    );
                  }

                  await DbService().emptyCart();

                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const OrderSuccessScreen()),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Payment Failed",
                            style: TextStyle(color: Colors.white)),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                }
              },
              child: const Text("Proceed to Pay"),
            ),
          );
        },
      ),
    );
  }
}