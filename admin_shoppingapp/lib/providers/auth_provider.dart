import 'package:admin_shoppingapp/controllers/auth_service.dart';
import 'package:flutter/material.dart';

class AuthStateProvider extends ChangeNotifier {
  bool isLoadingLogin = false;
  bool isLoadingSignup = false;
  String? errorMessage;
  final AuthService _authService = AuthService();

  void setLoginLoading(bool value) {
    isLoadingLogin = value;
    notifyListeners();
  }

  void setSignupLoading(bool value) {
    isLoadingSignup = value;
    notifyListeners();
  }

  Future<String> login(String email, String password) async {
    setLoginLoading(true);
    final result = await _authService.loginWithEmail(email, password);
    setLoginLoading(false);
    return result;
  }

  Future<String> signup(String email, String password) async {
    setSignupLoading(true);
    final result = await _authService.createAccountWithEmail(email, password);
    setSignupLoading(false);
    return result;
  }

  Future<String> resetPassword(String email) async {
    return await _authService.resetPassword(email);
  }
}
