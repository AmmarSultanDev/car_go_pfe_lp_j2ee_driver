import 'dart:typed_data';

import 'package:car_go_pfe_lp_j2ee_driver/methods/auth_methods.dart';
import 'package:car_go_pfe_lp_j2ee_driver/methods/common_methods.dart';
import 'package:car_go_pfe_lp_j2ee_driver/models/driver.dart' as model;
import 'package:flutter/material.dart';

class DriverProvider with ChangeNotifier {
  model.Driver? _user;
  final AuthMethods _authMethods = AuthMethods();

  final CommonMethods _commonMethods = const CommonMethods();

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

  Future<String> updateProfile(
      Map<String, dynamic> data, BuildContext context, Uint8List? file) async {
    model.Driver? user;
    String res =
        await _authMethods.updateDriverInfo(data, file ?? null, context);

    if (res == 'success') {
      user = await _authMethods.getUserDetails();

      Future.microtask(() {
        _user = user;
        notifyListeners();

        return res;
      });
    } else if (res == 'email-verification-sent') {
      return res;
    }

    return res;
  }
}
