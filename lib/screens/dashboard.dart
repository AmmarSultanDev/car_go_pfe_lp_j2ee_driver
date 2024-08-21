import 'dart:async';
import 'dart:convert';
import 'package:car_go_pfe_lp_j2ee_driver/global/global_var.dart';
import 'package:car_go_pfe_lp_j2ee_driver/methods/auth_methods.dart';
import 'package:car_go_pfe_lp_j2ee_driver/models/user.dart' as model;
import 'package:car_go_pfe_lp_j2ee_driver/providers/user_provider.dart';
import 'package:car_go_pfe_lp_j2ee_driver/screens/authentication/signin_screen.dart';
import 'package:car_go_pfe_lp_j2ee_driver/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final Completer<GoogleMapController> googleMapCompleterController =
      Completer<GoogleMapController>();

  GoogleMapController? controllerGoogleMap;

  Position? currentPositionOfUser;

  Future<model.User?>? _userFuture;

  void updateMapTheme(GoogleMapController controller) {
    getJsonFileFromThemes('themes/night_style.json')
        .then((value) => setGoogleMapStyle(value, controller));
  }

  Future<String> getJsonFileFromThemes(String mapStylePath) async {
    ByteData byteData = await rootBundle.load(mapStylePath);
    var list = byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
    return utf8.decode(list);
  }

  setGoogleMapStyle(String googleMapStyle, GoogleMapController controller) {
    controller.setMapStyle(googleMapStyle);
  }

  getCurrentLiveLocationOfDriver() async {
    Position positionOfUser = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );
    currentPositionOfUser = positionOfUser;

    LatLng positionOfUserInLatLng = LatLng(
        currentPositionOfUser!.latitude, currentPositionOfUser!.longitude);

    CameraPosition cameraPosition = CameraPosition(
      target: positionOfUserInLatLng,
      zoom: 14.4746,
    );

    controllerGoogleMap!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  signout() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LoadingDialog(messageText: 'Signing out ...'),
    );

    await AuthMethods().signoutUser();

    if (context.mounted) {
      Navigator.of(context).pop(); // Close the loading dialog

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const SigninScreen(),
        ),
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _userFuture =
        Provider.of<UserProvider>(context, listen: false).refreshUser();
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
            appBar: AppBar(
              title: Text(user?.displayName ?? 'Driver'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    signout();
                  },
                ),
              ],
            ),
            body: Stack(
              children: [
                GoogleMap(
                  mapType: MapType.normal,
                  myLocationEnabled: true,
                  initialCameraPosition: googlePlexInitialPosition,
                  onMapCreated: (GoogleMapController mapController) {
                    controllerGoogleMap = mapController;
                    updateMapTheme(controllerGoogleMap!);

                    googleMapCompleterController.complete(controllerGoogleMap);

                    getCurrentLiveLocationOfDriver();
                  },
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
