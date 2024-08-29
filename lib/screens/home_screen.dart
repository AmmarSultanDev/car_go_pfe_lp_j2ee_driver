import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:car_go_pfe_lp_j2ee_driver/global/global_var.dart';
import 'package:car_go_pfe_lp_j2ee_driver/push_notification/push_notification_system.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final Completer<GoogleMapController> googleMapCompleterController =
      Completer<GoogleMapController>();

  GoogleMapController? controllerGoogleMap;

  Position? currentPositionOfDriver;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isDriverAvailable = false;
  String driverStatusText = 'Go Online';
  Color driverStatusColor = Colors.green;

  DatabaseReference onlineDriversRef =
      FirebaseDatabase.instance.ref().child('onlineDrivers');

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

  // Load driver's status
  Future<bool> loadDriverStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isDriverOnline') ?? false;
  }

  // Save driver's status
  Future<void> saveDriverStatus(bool isOnline) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDriverOnline', isOnline);
  }

  goOnline() async {
    bool initialized = await Geofire.initialize('onlineDrivers');
    if (initialized) {
      isGeofireInitialized = true;
    }
    await saveDriverStatus(true);
  }

  goOffline() async {
    await homeTabPageStreamSubscription!.cancel();
    homeTabPageStreamSubscription = null;

    bool? geofireRemoveLocationWithSuccess =
        await Geofire.removeLocation(_auth.currentUser!.uid);

    if (geofireRemoveLocationWithSuccess == false ||
        geofireRemoveLocationWithSuccess == null) {
      await onlineDriversRef.child(_auth.currentUser!.uid).remove();
      isGeofireInitialized = false;
    } else {
      isGeofireInitialized = false;
    }

    await saveDriverStatus(false);
  }

  initializePushNotificationSystem() {
    PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    pushNotificationSystem.generateDeviceRegistrationToken();
    pushNotificationSystem.startListeningForNewNotifications(context);
  }

  @override
  void initState() {
    super.initState();
    loadDriverStatus().then((isOnline) {
      if (isOnline) {
        setState(() {
          driverStatusColor = Colors.red;
          driverStatusText = 'Go Offline';
          isDriverAvailable = true;
        });
      } else {
        setState(() {
          driverStatusColor = Colors.green;
          driverStatusText = 'Go Online';
          isDriverAvailable = false;
        });
      }
    });
    initializePushNotificationSystem();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

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

        // go online offline container
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

                                          await goOnline();

                                          setAndGetLocationUpdates();
                                        } else {
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
