import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:car_go_pfe_lp_j2ee_driver/global/global_var.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Completer<GoogleMapController> googleMapCompleterController =
      Completer<GoogleMapController>();

  GoogleMapController? controllerGoogleMap;

  Position? currentPositionOfDriver;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Color driverStatusColor = Colors.green;
  String driverStatusText = 'Go Online';
  bool isDriverAvailable = false;

  void updateMapTheme(GoogleMapController controller, BuildContext context) {
    String mapStylePath = Theme.of(context).brightness == Brightness.dark
        ? 'themes/night_style.json'
        : 'themes/standard_style.json';
    getJsonFileFromThemes(mapStylePath)
        .then((value) => setGoogleMapStyle(value, controller));
  }

  Future<String> getJsonFileFromThemes(String mapStylePath) async {
    ByteData byteData = await rootBundle.load(mapStylePath);
    var list = byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
    return utf8.decode(list);
  }

  setGoogleMapStyle(String googleMapStyle, GoogleMapController controller) {
    // ignore: deprecated_member_use
    controller.setMapStyle(googleMapStyle);
  }

  getCurrentLiveLocationOfDriver() async {
    Position positionOfUser = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );
    currentPositionOfDriver = positionOfUser;

    LatLng positionOfUserInLatLng = LatLng(
        currentPositionOfDriver!.latitude, currentPositionOfDriver!.longitude);

    CameraPosition cameraPosition = CameraPosition(
      target: positionOfUserInLatLng,
      zoom: 14.4746,
    );

    controllerGoogleMap!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  goOnline() async {
    await Geofire.initialize('onlineDrivers');
  }

  setAndGetLocationUpdates() {
    homeTabPageStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      currentPositionOfDriver = position;

      if (isDriverAvailable) {
        Geofire.setLocation(
          _auth.currentUser!.uid,
          currentPositionOfDriver!.latitude,
          currentPositionOfDriver!.longitude,
        );

        LatLng positionOfDriverInLatLng =
            LatLng(position.latitude, position.longitude);

        controllerGoogleMap!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: positionOfDriverInLatLng,
              zoom: 14.4746,
            ),
          ),
        );
      }
    });
  }

  goOffline() async {
    await homeTabPageStreamSubscription!.cancel();
    homeTabPageStreamSubscription = null;

    await Geofire.removeLocation(_auth.currentUser!.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          padding: Platform.isAndroid
              ? const EdgeInsets.only(top: 55, right: 10)
              : const EdgeInsets.only(bottom: 16, right: 28, left: 16),
          myLocationButtonEnabled: true,
          zoomControlsEnabled: false,
          mapType: MapType.normal,
          myLocationEnabled: true,
          initialCameraPosition: casablancaInitialPosition,
          onMapCreated: (GoogleMapController mapController) {
            controllerGoogleMap = mapController;
            updateMapTheme(controllerGoogleMap!, context);

            googleMapCompleterController.complete(controllerGoogleMap);

            getCurrentLiveLocationOfDriver();
          },
        ),

        // go online offline conatiner
        Positioned(
          top: 61,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isDismissible: false,
                    builder: (BuildContext context) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 15,
                              spreadRadius: 0.5,
                              offset: Offset(0.7, 0.7),
                            ),
                          ],
                        ),
                        height: 221,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 18,
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 12),
                              Text(
                                (!isDriverAvailable)
                                    ? 'GO ONLINE'
                                    : 'GO OFFLINE',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium!
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                (!isDriverAvailable)
                                    ? 'You are about to become available to receive trip requests from passengers'
                                    : 'You are about to become unavailable to receive trip requests from passengers',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color: Theme.of(context).hintColor,
                                    ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (mounted) Navigator.pop(context);
                                      },
                                      child: Text(
                                        'Cancel',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        if (!isDriverAvailable) {
                                          //close the bottom sheet
                                          if (mounted) Navigator.pop(context);

                                          setState(() {
                                            driverStatusColor = Colors.red;
                                            driverStatusText = 'Go Offline';
                                            isDriverAvailable = true;
                                          });

                                          // TODO: go online
                                          await goOnline();

                                          // TODO: get driver location updates
                                          setAndGetLocationUpdates();
                                        } else {
                                          // go offline

                                          if (mounted) Navigator.pop(context);

                                          setState(() {
                                            driverStatusColor = Colors.green;
                                            driverStatusText = 'Go Online';
                                            isDriverAvailable = false;
                                          });

                                          await goOffline();
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            (driverStatusText == 'Go Online')
                                                ? Colors.green
                                                : Colors.red,
                                      ),
                                      child: Text(
                                        'Confirm',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: driverStatusColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  driverStatusText,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
