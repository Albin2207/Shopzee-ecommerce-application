import 'package:flutter/material.dart';

class ProfileFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController alternatePhoneController;
  final TextEditingController pincodeController;
  final TextEditingController stateController;
  final TextEditingController cityController;
  final TextEditingController houseNoController;
  final TextEditingController roadNameController;

  const ProfileFormFields({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.alternatePhoneController,
    required this.pincodeController,
    required this.stateController,
    required this.cityController,
    required this.houseNoController,
    required this.roadNameController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTextFormField(nameController, "Name", "Name"),
        SizedBox(height: 10),
        _buildTextFormField(emailController, "Email", "Email", readOnly: true),
        SizedBox(height: 10),
        _buildTextFormField(
            phoneController, "Add Phone number", "Phone number (required)"),
        SizedBox(height: 10),
        _buildTextFormField(alternatePhoneController,
            "Add Alternate Phone Number", "Phone number"),
        SizedBox(height: 10),
        _buildTextFormField(pincodeController, "Pincode", "Pincode"),
        SizedBox(height: 10),
        _buildTextFormField(
            stateController, "State (Required)", "State (Required)"),
        SizedBox(height: 10),
        _buildTextFormField(
            cityController, "City (Required)", "City (Required)"),
        SizedBox(height: 10),
        _buildTextFormField(
            houseNoController,
            "House No., Building Name (Required)",
            "House No., Building Name (Required)"),
        SizedBox(height: 10),
        _buildTextFormField(
            roadNameController,
            "Road name, Area, Colony (Required)",
            "Road name, Area, Colony (Required)"),
      ],
    );
  }

  Widget _buildTextFormField(
      TextEditingController controller, String labelText, String hintText,
      {bool readOnly = false}) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(),
      ),
      validator: (value) =>
          value!.isEmpty ? "$labelText cannot be empty." : null,
    );
  }
}
