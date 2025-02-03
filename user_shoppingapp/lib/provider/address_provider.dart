import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_shoppingapp/controllers/database_service.dart';
import 'package:user_shoppingapp/models/address_model.dart';
import 'package:user_shoppingapp/provider/user_provider.dart';


class SelectedAddressProvider extends ChangeNotifier {
  AddressModel? selectedAddress;
  bool useDefaultAddress = true;

  void selectAddress(AddressModel address) {
    selectedAddress = address;
    useDefaultAddress = false;
    notifyListeners();
  }

  void selectDefaultAddress() {
    selectedAddress = null;
    useDefaultAddress = true;
    notifyListeners();
  }

  Map<String, String> getDeliveryAddress(UserProvider userProvider) {
    if (useDefaultAddress) {
      return {
        'name': userProvider.name,
        'email': userProvider.email,
        'phone': userProvider.phone,
        'alternatePhone': userProvider.alternatePhone,
        'pincode': userProvider.pincode,
        'state': userProvider.state,
        'city': userProvider.city,
        'houseNo': userProvider.houseNo,
        'roadName': userProvider.roadName,
      };
    } else {
      return {
        'name': selectedAddress!.name,
        'email': selectedAddress!.email,
        'phone': selectedAddress!.phone,
        'alternatePhone': selectedAddress!.alternatePhone,
        'pincode': selectedAddress!.pincode,
        'state': selectedAddress!.state,
        'city': selectedAddress!.city,
        'houseNo': selectedAddress!.houseNo,
        'roadName': selectedAddress!.roadName,
      };
    }
  }
}

class DeliveryAddressSelection extends StatelessWidget {
  const DeliveryAddressSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        return Consumer<SelectedAddressProvider>(
          builder: (context, addressProvider, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Select Delivery Address",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                // Default Address Card
                RadioListTile<bool>(
                  value: true,
                  groupValue: addressProvider.useDefaultAddress,
                  onChanged: (value) => addressProvider.selectDefaultAddress(),
                  title: Text(userProvider.name),
                  subtitle: Text(
                    '${userProvider.houseNo}, ${userProvider.roadName}\n'
                    '${userProvider.city}, ${userProvider.state} - ${userProvider.pincode}\n'
                    'Phone: ${userProvider.phone}',
                  ),
                ),
                // Additional Addresses
                StreamBuilder<List<AddressModel>>(
                  stream: DbService().readAddresses(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      children: snapshot.data!.map((address) {
                        return RadioListTile<String>(
                          value: address.id,
                          groupValue: addressProvider.useDefaultAddress
                              ? null
                              : addressProvider.selectedAddress?.id,
                          onChanged: (value) => addressProvider.selectAddress(address),
                          title: Text(address.name),
                          subtitle: Text(
                            '${address.houseNo}, ${address.roadName}\n'
                            '${address.city}, ${address.state} - ${address.pincode}\n'
                            'Phone: ${address.phone}',
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}