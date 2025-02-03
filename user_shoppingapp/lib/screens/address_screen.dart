import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:user_shoppingapp/controllers/database_service.dart';
import 'package:user_shoppingapp/models/address_model.dart';
import 'package:user_shoppingapp/provider/user_provider.dart';
import 'package:user_shoppingapp/screens/add_addess_screen.dart';


class AddressesPage extends StatelessWidget {
  const AddressesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User not logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Addresses'),
        scrolledUnderElevation: 0,
        forceMaterialTransparency: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddAddressPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Main user address
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text(userProvider.name),
                  subtitle: Text(
                    '${userProvider.houseNo}, ${userProvider.roadName}\n'
                    '${userProvider.city}, ${userProvider.state} - ${userProvider.pincode}\n'
                    'Phone: ${userProvider.phone}',
                  ),
                  trailing: Chip(
                    label: Text('Default'),
                    backgroundColor: Colors.green.shade100,
                  ),
                ),
              );
            },
          ),
          
          // Additional addresses
          Expanded(
            child: StreamBuilder<List<AddressModel>>(
              stream: DbService().readAddresses(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No additional addresses found'),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final address = snapshot.data![index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        title: Text(address.name),
                        subtitle: Text(
                          '${address.houseNo}, ${address.roadName}\n'
                          '${address.city}, ${address.state} - ${address.pincode}\n'
                          'Phone: ${address.phone}',
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.more_vert),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) => Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: Icon(Icons.edit),
                                    title: Text('Edit'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddAddressPage(
                                            addressToEdit: address,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.delete),
                                    title: Text('Delete'),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      await DbService().deleteAddress(address.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Address deleted'),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}