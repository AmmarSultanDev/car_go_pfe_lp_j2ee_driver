import 'dart:async';
import 'package:car_go_pfe_lp_j2ee_driver/models/user.dart' as model;
import 'package:car_go_pfe_lp_j2ee_driver/providers/user_provider.dart';
import 'package:car_go_pfe_lp_j2ee_driver/screens/earning_screen.dart';
import 'package:car_go_pfe_lp_j2ee_driver/screens/home_screen.dart';
import 'package:car_go_pfe_lp_j2ee_driver/screens/profile_screen.dart';
import 'package:car_go_pfe_lp_j2ee_driver/screens/trips_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  Future<model.User?>? _userFuture;

  TabController? tabController;
  int selectedIndex = 0;

  onBarItemTap(int index) {
    setState(() {
      selectedIndex = index;
      tabController!.index = selectedIndex;
    });
  }

  // signout() async {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) => const LoadingDialog(messageText: 'Signing out ...'),
  //   );

  //   await AuthMethods().signoutUser();

  //   if (context.mounted) {
  //     Navigator.of(context).pop(); // Close the loading dialog

  //     Navigator.of(context).pushReplacement(
  //       MaterialPageRoute(
  //         builder: (context) => const SigninScreen(),
  //       ),
  //     );
  //   }
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _userFuture =
        Provider.of<UserProvider>(context, listen: false).refreshUser();

    tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    tabController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<model.User?>(
      future: _userFuture,
      builder: (BuildContext context, AsyncSnapshot<model.User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child:
                  CircularProgressIndicator()); // Show loading spinner while waiting for user data
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final model.User? user = snapshot.data;
          return Scaffold(
            body: TabBarView(
              controller: tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                HomeScreen(),
                EarningScreen(),
                TripsScreen(),
                ProfileScreen(),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: selectedIndex,
              selectedItemColor: Theme.of(context).primaryColor,
              unselectedItemColor: Theme.of(context).unselectedWidgetColor,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              onTap: onBarItemTap,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.monetization_on),
                  label: 'Earnings',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history),
                  label: 'Trips',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          );
        }
      },
    );
  }
}