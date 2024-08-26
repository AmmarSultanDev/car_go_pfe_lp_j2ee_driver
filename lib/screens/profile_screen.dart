// ignore_for_file: use_build_context_synchronously

import 'package:car_go_pfe_lp_j2ee_driver/methods/auth_methods.dart';
import 'package:flutter/material.dart';
import 'package:car_go_pfe_lp_j2ee_driver/methods/common_methods.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  signout() async {
    await const CommonMethods().goOfflinePermanently(context);

    await AuthMethods().signoutUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              signout();
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: const Center(
        child: Text('Profile Screen'),
      ),
    );
  }
}
