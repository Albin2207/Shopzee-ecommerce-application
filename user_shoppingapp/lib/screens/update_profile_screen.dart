import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_shoppingapp/controllers/database_service.dart';
import 'package:user_shoppingapp/provider/user_provider.dart';
import 'package:user_shoppingapp/widgets/common_appbar.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
final TextEditingController _emailController = TextEditingController();
final TextEditingController _phoneController = TextEditingController();
final TextEditingController _alternatePhoneController = TextEditingController();
final TextEditingController _pincodeController = TextEditingController();
final TextEditingController _stateController = TextEditingController();
final TextEditingController _cityController = TextEditingController();
final TextEditingController _houseNoController = TextEditingController();
final TextEditingController _roadNameController = TextEditingController();


  @override
  void initState() {
    final user = Provider.of<UserProvider>(context, listen: false);
    _nameController.text = user.name;
    _emailController.text = user.email;
    _phoneController.text = user.phone;
    _alternatePhoneController.text = user.alternatePhone;
     _pincodeController.text = user.pincode;
     _stateController.text = user.state;
     _cityController.text = user.city;
    _houseNoController.text = user.houseNo;
    _roadNameController.text = user.roadName;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalAppBar(title: "Update Profile"),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Name",
                    hintText: "Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Name cannot be empty." : null,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _emailController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Email",
                    hintText: "Email",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Email cannot be empty." : null,
                ),
                SizedBox(height: 10),
                TextFormField(
                  maxLines: 3,
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: "Add Phone number",
                    hintText: "Phone number(required)",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Phone number cannot be empty." : null,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _alternatePhoneController,
                  decoration: InputDecoration(
                    labelText: "Add Alternate Phone Number",
                    hintText: "Phone number",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Add as alternate option." : null,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _pincodeController,
                  decoration: InputDecoration(
                    labelText: "Pincode",
                    hintText: "Pincode",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Pincode cannot be empty." : null,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _stateController,
                  decoration: InputDecoration(
                    labelText: "State (Required)",
                    hintText: "State (Required)",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Please provide the necessary details." : null,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    labelText: "City (Required)",
                    hintText: "City (Required)",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Please provide the necessary details." : null,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _houseNoController,
                  decoration: InputDecoration(
                    labelText: "House No., Building Name (Required)",
                    hintText: "House No., Building Name (Required)",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "House No./Building Name cannot be empty." : null,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _roadNameController,
                  decoration: InputDecoration(
                    labelText: "Road name, Area, Colony (Required)",
                    hintText: "Road name, Area, Colony (REquired)",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Road name/Area/Colony cannot be empty." : null,
                ),
                SizedBox(height: 10),
                // TextFormField(
                //   controller: _nearbyLandmarkController,
                //   decoration: InputDecoration(
                //     labelText: "Add Nearby Famous Shop/Mall/Landmark",
                //     hintText: "Add Nearby Famous Shop/Mall/Landmark",
                //     border: OutlineInputBorder(),
                //   ),
                //   validator: null,
                // ),
                
                // SizedBox(height: 10),
                SizedBox(
                    height: 60,
                    width: MediaQuery.of(context).size.width * .9,
                    child: ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            var data = {
                              "name": _nameController.text,
                              "email": _emailController.text,
                              "phone": _phoneController.text,
                              "alternatePhone": _alternatePhoneController.text,
                              "pincode": _pincodeController.text,
                              "state": _stateController.text,
                              "city": _cityController.text,
                              "houseNo": _houseNoController.text,
                              "roadName": _roadNameController.text,
                             
                            };
                            await DbService().updateUserData(extraData: data);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Profile Updated")));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white),
                        child: Text(
                          "Update Profile",
                          style: TextStyle(fontSize: 16),
                        ))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}