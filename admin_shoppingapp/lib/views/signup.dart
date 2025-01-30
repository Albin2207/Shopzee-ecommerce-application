// import 'package:admin_shoppingapp/providers/auth_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class SingupPage extends StatefulWidget {
//   const SingupPage({super.key});

//   @override
//   State<SingupPage> createState() => _SingupPageState();
// }

// class _SingupPageState extends State<SingupPage> {
//   final formKey = GlobalKey<FormState>();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _confirmPasswordController =
//       TextEditingController();
//   bool _obscurePassword = true;
//   bool _obscureConfirmPassword = true;

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<AuthStateProvider>(
//       builder: (context, authState, child) {
//         return Scaffold(
//           body: SingleChildScrollView(
//             child: Form(
//               key: formKey,
//               child: Column(
//                 children: [
//                   SizedBox(
//                     height: 120,
//                   ),
//                   SizedBox(
//                     width: MediaQuery.of(context).size.width * .9,
//                     child: TextFormField(
//                       validator: (value) {
//                         if (value!.isEmpty) {
//                           return "Email cannot be empty.";
//                         }
//                         // Email format validation using regex
//                         String pattern =
//                             r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$";
//                         RegExp regex = RegExp(pattern);
//                         if (!regex.hasMatch(value)) {
//                           return "Enter a valid email address.";
//                         }
//                         return null;
//                       },
//                       controller: _emailController,
//                       decoration: InputDecoration(
//                         border: OutlineInputBorder(),
//                         label: Text("Email"),
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   SizedBox(
//                     width: MediaQuery.of(context).size.width * .9,
//                     child: TextFormField(
//                       validator: (value) => value!.length < 8
//                           ? "Password should have at least 8 characters."
//                           : null,
//                       controller: _passwordController,
//                       obscureText: _obscurePassword,
//                       decoration: InputDecoration(
//                         border: OutlineInputBorder(),
//                         label: Text("Password"),
//                         suffixIcon: IconButton(
//                           icon: Icon(_obscurePassword
//                               ? Icons.visibility_off
//                               : Icons.visibility),
//                           onPressed: () {
//                             setState(() {
//                               _obscurePassword = !_obscurePassword;
//                             });
//                           },
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   SizedBox(
//                     width: MediaQuery.of(context).size.width * .9,
//                     child: TextFormField(
//                       validator: (value) => value != _passwordController.text
//                           ? "Passwords do not match."
//                           : null,
//                       controller: _confirmPasswordController,
//                       obscureText: _obscureConfirmPassword,
//                       decoration: InputDecoration(
//                         border: OutlineInputBorder(),
//                         label: Text("Confirm Password"),
//                         suffixIcon: IconButton(
//                           icon: Icon(_obscureConfirmPassword
//                               ? Icons.visibility_off
//                               : Icons.visibility),
//                           onPressed: () {
//                             setState(() {
//                               _obscureConfirmPassword =
//                                   !_obscureConfirmPassword;
//                             });
//                           },
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   SizedBox(
//                     height: 60,
//                     width: MediaQuery.of(context).size.width * .9,
//                     child: ElevatedButton(
//                         onPressed: () {
//                           if (formKey.currentState!.validate()) {
//                             context
//                                 .read<AuthStateProvider>()
//                                 .signup(_emailController.text,
//                                     _passwordController.text)
//                                 .then((value) {
//                               if (value ==
//                                   "Account created. Please verify your email.") {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                     SnackBar(content: Text("Account Created")));

//                                 // Show a dialog prompting the user to verify their email
//                                 showDialog(
//                                   context: context,
//                                   builder: (context) => AlertDialog(
//                                     title: Text("Email Verification"),
//                                     content: Text(
//                                         "A verification email has been sent to ${_emailController.text}. Please verify your email and then log in."),
//                                     actions: [
//                                       TextButton(
//                                         onPressed: () {
//                                           Navigator.pop(
//                                               context); // Close the dialog
//                                           Navigator.pop(
//                                               context); // Go back to the login page
//                                         },
//                                         child: Text("OK"),
//                                       ),
//                                     ],
//                                   ),
//                                 );
//                               } else {
//                                 ScaffoldMessenger.of(context)
//                                     .showSnackBar(SnackBar(
//                                   content: Text(
//                                     value,
//                                     style: TextStyle(color: Colors.white),
//                                   ),
//                                   backgroundColor: Colors.red.shade400,
//                                 ));
//                               }
//                             });
//                           }
//                         },
//                         child: authState.isLoadingSignup
//                             ? const CircularProgressIndicator(
//                                 color: Colors.black)
//                             : Text(
//                                 "Sign Up",
//                                 style: TextStyle(fontSize: 16),
//                               )),
//                   ),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text("Already have an account?"),
//                       TextButton(
//                           onPressed: () {
//                             Navigator.pop(context);
//                           },
//                           child: Text("Login"))
//                     ],
//                   )
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
