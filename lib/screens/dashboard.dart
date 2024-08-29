import 'dart:async';
import 'package:car_go_pfe_lp_j2ee_driver/models/driver.dart' as model;
import 'package:car_go_pfe_lp_j2ee_driver/providers/driver_provider.dart';
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
  Future<model.Driver?>? _userFuture;
  model.Driver? user;

  TabController? tabController;
  int selectedIndex = 0;

  onBarItemTap(int index) {
    setState(() {
      selectedIndex = index;
      tabController!.index = selectedIndex;
    });
  }

  getUserFuture() async {
    try {
      _userFuture =
          Provider.of<DriverProvider>(context, listen: false).refreshUser();
      user = await _userFuture;
    } catch (e) {
      print('Error refreshing user: $e');
    }
  }

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 4, vsync: this);
    getUserFuture();
  }

  @override
  void dispose() {
    super.dispose();
    tabController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<model.Driver?>(
        future: _userFuture,
        builder: (BuildContext context, AsyncSnapshot<model.Driver?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator()); // Show loading spinner while waiting for user data
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            if (user == null) {
              return const Center(
                  child: Text('No user data found')); // Handle null user here
            } else {
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
                  type: BottomNavigationBarType.fixed,
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
          }
        });
  }
}
