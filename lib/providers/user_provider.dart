import 'package:car_go_pfe_lp_j2ee_driver/methods/auth_methods.dart';
import 'package:car_go_pfe_lp_j2ee_driver/models/user.dart' as model;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  model.User? _user;
  final AuthMethods _authMethods = AuthMethods();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  model.User? get getUser => _user;

  Future<model.User?> refreshUser() async {
    print('refreshUser called');
    _user = await _authMethods.getUserDetails();

    print('refreshUser completed: $_user');
    notifyListeners();
    return _user;
  }
}
