import 'package:car_go_pfe_lp_j2ee_driver/methods/auth_methods.dart';
import 'package:car_go_pfe_lp_j2ee_driver/models/driver.dart' as model;
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  model.Driver? _user;
  final AuthMethods _authMethods = AuthMethods();

  model.Driver? get getUser => _user;

  Future<model.Driver?> refreshUser() async {
    model.Driver? user = await _authMethods.getUserDetails();

    Future.microtask(() {
      _user = user;
      notifyListeners();
    });

    return user;
  }

  set setUser(model.Driver user) {
    Future.microtask(() {
      _user = user;
      notifyListeners();
    });
  }
}
