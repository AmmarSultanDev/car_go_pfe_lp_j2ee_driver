import 'dart:async';
import 'dart:io';

import 'package:car_go_pfe_lp_j2ee_driver/global/global_var.dart';
import 'package:car_go_pfe_lp_j2ee_driver/methods/map_theme_methods.dart';
import 'package:car_go_pfe_lp_j2ee_driver/models/trip_details.dart';
import 'package:car_go_pfe_lp_j2ee_driver/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NewTripPage extends StatefulWidget {
  const NewTripPage({super.key, required this.tripDetails});

  final TripDetails tripDetails;

  @override
  State<NewTripPage> createState() => _NewTripPageState();
}

class _NewTripPageState extends State<NewTripPage> {
  final Completer<GoogleMapController> googleMapCompleterController =
      Completer<GoogleMapController>();

  GoogleMapController? controllerGoogleMap;

  drawRoute(LatLng start, LatLng end) async {
    showDialog(
      context: context,
      builder: (context) => const LoadingDialog(
        messageText: 'Please wait...',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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
            onMapCreated: (GoogleMapController mapController) async {
              controllerGoogleMap = mapController;
              MapThemeMethods().updateMapTheme(controllerGoogleMap!, context);

              googleMapCompleterController.complete(controllerGoogleMap);

              var driverCurrentPositionLatLng = LatLng(
                currentPositionOfDriver!.latitude,
                currentPositionOfDriver!.longitude,
              );

              var userPickUpoLocation =
                  widget.tripDetails.pickupLocationCoordinates;

              await drawRoute(
                  driverCurrentPositionLatLng, userPickUpoLocation!);
            },
          ),
        ],
      ),
    );
  }
}
