import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_shoppingapp/controllers/database_service.dart';
import 'package:user_shoppingapp/provider/user_provider.dart';
import 'package:user_shoppingapp/screens/update_user_profile/widgets/profile_fields.dart';
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
  final TextEditingController _alternatePhoneController =
      TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _houseNoController = TextEditingController();
  final TextEditingController _roadNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
                ProfileFormFields(
                  nameController: _nameController,
                  emailController: _emailController,
                  phoneController: _phoneController,
                  alternatePhoneController: _alternatePhoneController,
                  pincodeController: _pincodeController,
                  stateController: _stateController,
                  cityController: _cityController,
                  houseNoController: _houseNoController,
                  roadNameController: _roadNameController,
                ),
                SizedBox(height: 10),
                SizedBox(
                  height: 60,
                  width: MediaQuery.of(context).size.width * .9,
                  child: ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      "Update Profile",
                      style: TextStyle(fontSize: 16),
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

  Future<void> _handleSubmit() async {
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Profile Updated")));
    }
  }
}
