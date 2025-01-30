import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:user_shoppingapp/controllers/auth_service.dart';
import 'package:user_shoppingapp/controllers/database_service.dart';
import 'package:user_shoppingapp/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  StreamSubscription<DocumentSnapshot>? _userSubscription;

  String name = "";
  String email = "";
  String address = "";
  String phone = "";
  bool isLoggedIn = false;

  UserProvider() {
    initializeUser();
    loadUserData();
  }

  Future<void> initializeUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      isLoggedIn = true;
      loadUserData();//added to make sure login loads user data in profile page. remove if it doesnt work
      notifyListeners();
    }
  }

  void loadUserData() {
    _userSubscription?.cancel();
    _userSubscription = DbService().readUserData().listen((snapshot) {
      print(snapshot.data());
      final UserModel data = UserModel.fromJson(snapshot.data() as Map<String, dynamic>);
      name = data.name;
      email = data.email;
      address = data.address;
      phone = data.phone;
      notifyListeners();
    });
  }

  Future<void> logout() async {
    await _authService.logout();
    _userSubscription?.cancel();
    isLoggedIn = false;
    notifyListeners();
  }

  void cancelProvider() {
    _userSubscription?.cancel();
  }

  @override
  void dispose() {
    cancelProvider();
    super.dispose();
  }
}