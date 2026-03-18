import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String? _token;
  String? _role;

  String? get token => _token;
  String? get role => _role;

  void setInitialData(String? token, String? role) {
    _token = token;
    _role = role;
  }

  void updateAuth(String token, String role) {
    _token = token;
    _role = role;
    notifyListeners();
  }

  void logout() {
    _token = null;
    _role = null;
    notifyListeners();
  }
}
