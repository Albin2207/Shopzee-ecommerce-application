import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:user_shoppingapp/controllers/database_service.dart';
import 'package:user_shoppingapp/models/address_model.dart';
import 'package:user_shoppingapp/provider/address_provider.dart';
import 'package:user_shoppingapp/screens/add_addess_screen.dart';
import 'package:user_shoppingapp/widgets/common_appbar.dart';

class AddressesPage extends StatelessWidget {
  const AddressesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final addressProvider = Provider.of<SelectedAddressProvider>(context);

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User not logged in')),
      );
    }

    return Scaffold(
      appBar: GlobalAppBar(title: "Address List"),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<AddressModel>>(
              stream: DbService().readAddresses(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No saved addresses found'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final address = snapshot.data![index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: RadioListTile<String>(
                        value: address.id,
                        groupValue: addressProvider.selectedAddress?.id,
                        onChanged: (value) {
                          addressProvider.selectAddress(address);
                        },
                        title: Text(address.name),
                        subtitle: Text(
                          '${address.houseNo}, ${address.roadName}\n'
                          '${address.city}, ${address.state} - ${address.pincode}\n'
                          'Phone: ${address.phone}',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // "Add Address" Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddAddressPage(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text("Add Address"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
            ),
          ),

          // "Use this Address" Button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Return to checkout with selected address
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text("Use this Address"),
            ),
          ),
        ],
      ),
    );
  }
}
