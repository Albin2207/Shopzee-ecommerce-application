import 'package:flutter/material.dart';
import 'package:user_shoppingapp/controllers/auth_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SingupPageState();
}

class _SingupPageState extends State<SignupPage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              const SizedBox(height: 80),
              SizedBox(
                width: MediaQuery.of(context).size.width * .9,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Sign Up",
                      style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).primaryColor),
                    ),
                    const Text("Create a new account and get started"),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * .9,
                child: TextFormField(
                  validator: (value) =>
                      value!.isEmpty ? "Name cannot be empty." : null,
                  controller: _nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text("Name"),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: MediaQuery.of(context).size.width * .9,
                child: TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Email cannot be empty.";
                    }
                    String pattern =
                        r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$";
                    RegExp regex = RegExp(pattern);
                    if (!regex.hasMatch(value)) {
                      return "Enter a valid email address.";
                    }
                    return null;
                  },
                  controller: _emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text("Email"),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: MediaQuery.of(context).size.width * .9,
                child: TextFormField(
                  validator: (value) => value!.length < 8
                      ? "Password should have at least 8 characters."
                      : null,
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    label: const Text("Password"),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: MediaQuery.of(context).size.width * .9,
                child: TextFormField(
                  validator: (value) => value != _passwordController.text
                      ? "Passwords do not match."
                      : null,
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    label: const Text("Confirm Password"),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 60,
                width: MediaQuery.of(context).size.width * .9,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      AuthService()
                          .createAccountWithEmail(
                        _nameController.text,
                        _emailController.text,
                        _passwordController.text,
                      )
                          .then((value) {
                        if (value ==
                            "Account created. Please verify your email.") {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Account Created")));
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Email Verification"),
                              content: Text(
                                  "A verification email has been sent to ${_emailController.text}. Please verify your email and then log in."),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  child: const Text("OK"),
                                ),
                              ],
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                              value,
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.red.shade400,
                          ));
                        }
                      });
                    }
                  },
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Login"),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
