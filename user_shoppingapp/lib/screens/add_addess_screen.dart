import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:user_shoppingapp/controllers/database_service.dart';
import 'package:user_shoppingapp/models/address_model.dart';
import 'package:user_shoppingapp/utils/constants/location_permission.dart';

class AddAddressPage extends StatefulWidget {
  final AddressModel? addressToEdit;

  const AddAddressPage({super.key, this.addressToEdit});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _alternatePhoneController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _houseNoController = TextEditingController();
  final TextEditingController _roadNameController = TextEditingController();

  String? validateField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return "$fieldName cannot be empty.";
    }
    return null;
  }

  Future<void> _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      final addressData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'alternatePhone': _alternatePhoneController.text.trim(),
        'pincode': _pincodeController.text.trim(),
        'state': _stateController.text.trim(),
        'city': _cityController.text.trim(),
        'houseNo': _houseNoController.text.trim(),
        'roadName': _roadNameController.text.trim(),
        if (widget.addressToEdit != null) 'isDefault': widget.addressToEdit!.isDefault,
      };

      try {
        if (widget.addressToEdit != null) {
          await DbService().updateAddress(widget.addressToEdit!.id, addressData);
        } else {
          await DbService().addAddress(addressData);
        }
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.addressToEdit != null
                  ? 'Address updated successfully'
                  : 'Address added successfully'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Future<void> _fetchCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission permanently denied.')),
      );
      return;
    }

    // Fetch user location
    Position position = await Geolocator.getCurrentPosition();
    _getAddressFromLatLng(position);
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        // Autofill fields with fetched data
        setState(() {
          _pincodeController.text = place.postalCode ?? '';
          _stateController.text = place.administrativeArea ?? '';
          _cityController.text = place.locality ?? '';
          _roadNameController.text = place.street ?? '';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching address: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.addressToEdit != null) {
      _nameController.text = widget.addressToEdit!.name;
      _emailController.text = widget.addressToEdit!.email;
      _phoneController.text = widget.addressToEdit!.phone;
      _alternatePhoneController.text = widget.addressToEdit!.alternatePhone;
      _pincodeController.text = widget.addressToEdit!.pincode;
      _stateController.text = widget.addressToEdit!.state;
      _cityController.text = widget.addressToEdit!.city;
      _houseNoController.text = widget.addressToEdit!.houseNo;
      _roadNameController.text = widget.addressToEdit!.roadName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.addressToEdit != null ? 'Edit Address' : 'Add New Address'),
        scrolledUnderElevation: 0,
        forceMaterialTransparency: true,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Name",
                    hintText: "Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => validateField(value, "Name"),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    hintText: "Email",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => validateField(value, "Email"),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: "Add Phone number",
                    hintText: "Phone number(required)",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => validateField(value, "Phone number"),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _alternatePhoneController,
                  decoration: const InputDecoration(
                    labelText: "Add Alternate Phone Number",
                    hintText: "Phone number",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _pincodeController,
                        decoration: const InputDecoration(
                          labelText: "Pincode",
                          hintText: "Pincode",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => validateField(value, "Pincode"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await getLocation();//ask for location access
                        await _fetchCurrentLocation();//access location
                      },
                      icon: const Icon(Icons.my_location),
                      label: const Text('Use My Location'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _stateController,
                  decoration: const InputDecoration(
                    labelText: "State (Required)",
                    hintText: "State (Required)",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => validateField(value, "State"),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    labelText: "City (Required)",
                    hintText: "City (Required)",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => validateField(value, "City"),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _houseNoController,
                  decoration: const InputDecoration(
                    labelText: "House No., Building Name (Required)",
                    hintText: "House No., Building Name (Required)",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => validateField(value, "House No."),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _roadNameController,
                  decoration: const InputDecoration(
                    labelText: "Road name, Area, Colony (Required)",
                    hintText: "Road name, Area, Colony (Required)",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => validateField(value, "Road name"),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 60,
                  width: MediaQuery.of(context).size.width * .9,
                  child: ElevatedButton(
                    onPressed: _saveAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      widget.addressToEdit != null
                          ? 'Update Address'
                          : 'Add Address',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _alternatePhoneController.dispose();
    _pincodeController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _houseNoController.dispose();
    _roadNameController.dispose();
    super.dispose();
  }
}
