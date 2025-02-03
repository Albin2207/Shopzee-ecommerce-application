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
  String phone = "";
  String alternatePhone = "";
  String pincode = "";
  String state = "";
  String city = "";
  String houseNo = "";
  String roadName = "";

  bool isLoggedIn = false;

  UserProvider() {
    initializeUser();
    loadUserData();
  }

  Future<void> initializeUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      isLoggedIn = true;
      loadUserData();
      notifyListeners();
    }
  }

  void loadUserData() {
    _userSubscription?.cancel();
    _userSubscription = DbService().readUserData().listen((snapshot) {
      final UserModel data =
          UserModel.fromJson(snapshot.data() as Map<String, dynamic>);
      name = data.name;
      email = data.email;
      phone = data.phone;
      alternatePhone = data.alternatePhone;
      pincode = data.pincode;
      state = data.state;
      city = data.city;
      houseNo = data.houseNo;
      roadName = data.roadName;

      notifyListeners();
    });
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String alternatePhone,
    required String pincode,
    required String state,
    required String city,
    required String houseNo,
    required String roadName,

  }) async {
    final data = {
      "name": name,
      "email": email,
      "phone": phone,
      "alternatePhone": alternatePhone,
      "pincode": pincode,
      "state": state,
      "city": city,
      "houseNo": houseNo,
      "roadName": roadName,

    };
    await DbService().updateUserData(extraData: data);
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
