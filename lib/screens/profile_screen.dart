// ignore_for_file: use_build_context_synchronously

import 'package:car_go_pfe_lp_j2ee_driver/methods/auth_methods.dart';
import 'package:car_go_pfe_lp_j2ee_driver/models/driver.dart';
import 'package:car_go_pfe_lp_j2ee_driver/providers/driver_provider.dart';
import 'package:car_go_pfe_lp_j2ee_driver/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:car_go_pfe_lp_j2ee_driver/methods/common_methods.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? totalTrips;

  String? totalDistance;

  String? totalTime;

  Driver? driver;

  bool isEditing = false;
  TextEditingController? displayNameController;
  TextEditingController? emailController;
  TextEditingController? firstNameController;
  TextEditingController? lastNameController;

  @override
  void initState() {
    super.initState();

    driver = Provider.of<DriverProvider>(context, listen: false).getUser;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    driver = Provider.of<DriverProvider>(context, listen: false).getUser;
    displayNameController = TextEditingController(text: driver?.displayName);
    emailController = TextEditingController(text: driver?.email);
  }

  signout() async {
    showDialog(
        context: context,
        builder: (ctx) => const LoadingDialog(messageText: 'Going offline...'));

    await const CommonMethods().goOfflinePermanently(context);

    if (mounted) Navigator.of(context).pop();

    await AuthMethods().signoutUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: signout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // first section, user informations
          children: [
            Card(
              elevation: 5,
              color: Theme.of(context).cardColor.withOpacity(0.2),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(driver!
                                .photoUrl!), // Replace with the user's profile image URL
                          ),
                          const SizedBox(height: 16),
                          Text(
                            driver!.displayName,
                            overflow: TextOverflow
                                .ellipsis, // Replace with the user's name
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            driver!.email,
                            overflow: TextOverflow
                                .ellipsis, // Replace with the user's email
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Container(
                        height: double.infinity,
                        child: VerticalDivider(
                          color: Colors.transparent,
                          thickness: 1,
                          width: 20,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Theme.of(context).dividerColor,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // total trips
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Trips',
                                style: TextStyle(fontSize: 24),
                              ),
                              Text(totalTrips ?? '0'),
                            ],
                          ),
                          // total distance
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Distance',
                                style: TextStyle(fontSize: 24),
                              ),
                              Text(totalTrips ?? '0'),
                            ],
                          ),
                          // total time
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Time',
                                style: TextStyle(fontSize: 24),
                              ),
                              Text(totalTrips ?? '0'),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Card(
              elevation: 5,
              color: Theme.of(context).cardColor.withOpacity(0.2),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    if (isEditing)
                      TextField(
                        controller: displayNameController,
                      )
                    else
                      Text(driver!.displayName),
                    if (isEditing)
                      TextField(
                        controller: emailController,
                      )
                    else
                      Text(driver!.email),
                    if (isEditing) TextField(),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isEditing = !isEditing;
                        });
                      },
                      child: Text(isEditing ? 'Save' : 'Edit'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
