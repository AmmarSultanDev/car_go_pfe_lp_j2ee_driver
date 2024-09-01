import 'dart:async';
import 'dart:io';

import 'package:car_go_pfe_lp_j2ee_driver/global/global_var.dart';
import 'package:car_go_pfe_lp_j2ee_driver/methods/common_methods.dart';
import 'package:car_go_pfe_lp_j2ee_driver/methods/firestore_methods.dart';
import 'package:car_go_pfe_lp_j2ee_driver/methods/map_theme_methods.dart';
import 'package:car_go_pfe_lp_j2ee_driver/models/trip_details.dart';
import 'package:car_go_pfe_lp_j2ee_driver/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
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

  PolylinePoints polylinePoints = PolylinePoints();

  List<LatLng> polylineCoordinates = [];

  Set<Marker> markerSet = {};

  Set<Circle> circleSet = {};

  Set<Polyline> polylines = {};

  BitmapDescriptor? movingMarkerIcon;

  makeMarker() async {
    if (movingMarkerIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: const Size(38, 38));

      BitmapDescriptor.asset(
              imageConfiguration, 'assets/images/pin_map_tracking.png')
          .then((value) {
        movingMarkerIcon = value;
      });
    }
  }

  drawRoute(LatLng start, LatLng end) async {
    showDialog(
      context: context,
      builder: (context) => const LoadingDialog(
        messageText: 'Please wait...',
      ),
    );

    var tripDetailsInfo =
        await CommonMethods.getDirectionDetailsFromApi(start, end);

    if (mounted) Navigator.pop(context);

    List<PointLatLng> latlngPoints =
        polylinePoints.decodePolyline(tripDetailsInfo!.encodedPoints!);

    polylineCoordinates.clear();

    if (latlngPoints.isNotEmpty) {
      for (var point in latlngPoints) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }
    // draw polyline
    polylines.clear();

    setState(() {
      Polyline polyline = Polyline(
        polylineId: const PolylineId('polylineId'),
        color: Colors.blue,
        points: polylineCoordinates,
        width: 5,
        jointType: JointType.round,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polylines.add(polyline);
    });
    // fit polyline into the map
    LatLngBounds latLngBounds;

    if (start.latitude > end.latitude && start.longitude > end.longitude) {
      latLngBounds = LatLngBounds(southwest: end, northeast: start);
    } else if (start.longitude > end.longitude) {
      latLngBounds = LatLngBounds(
        southwest: LatLng(start.latitude, end.longitude),
        northeast: LatLng(end.latitude, start.longitude),
      );
    } else if (start.latitude > end.latitude) {
      latLngBounds = LatLngBounds(
        southwest: LatLng(end.latitude, start.longitude),
        northeast: LatLng(start.latitude, end.longitude),
      );
    } else {
      latLngBounds = LatLngBounds(southwest: start, northeast: end);
    }

    controllerGoogleMap!
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    //add marker
    Marker startMarker = Marker(
      markerId: const MarkerId('startMarkerId'),
      position: start,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: const InfoWindow(title: 'Start'),
    );

    Marker endMarker = Marker(
      markerId: const MarkerId('endMarkerId'),
      position: end,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: const InfoWindow(title: 'End'),
    );

    setState(() {
      markerSet.add(startMarker);
      markerSet.add(endMarker);
    });

    //add cicrle
    Circle startCircle = Circle(
      circleId: const CircleId('startCircleId'),
      radius: 12,
      center: start,
      strokeColor: Colors.green,
      fillColor: Colors.green,
    );

    Circle endCircle = Circle(
      circleId: const CircleId('endCircleId'),
      radius: 12,
      center: end,
      strokeColor: Colors.red,
      fillColor: Colors.red,
    );

    setState(() {
      circleSet.add(startCircle);
      circleSet.add(endCircle);
    });
  }

  getLiveLocationUpdates() {
    LatLng lastPosition = const LatLng(0, 0);

    newTripStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      currentPositionOfDriver = position;

      LatLng currentPosition = LatLng(position.latitude, position.longitude);

      Marker carMarker = Marker(
        markerId: const MarkerId('carMarkerId'),
        position: currentPosition,
        icon: movingMarkerIcon!,
        infoWindow: const InfoWindow(title: 'Current Location'),
      );

      setState(() {
        CameraPosition cameraPosition =
            CameraPosition(target: currentPosition, zoom: 16);

        controllerGoogleMap!
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

        markerSet
            .removeWhere((marker) => marker.markerId.value == 'carMarkerId');

        markerSet.add(carMarker);
      });

      lastPosition = currentPosition;

      //update tip details informations

      // update driver location tripRequest
      FirestoreMethods().updateTripRequestDriverLocation(
          widget.tripDetails.tripId!, lastPosition);
    });
  }

  @override
  Widget build(BuildContext context) {
    makeMarker();
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
            markers: markerSet,
            circles: circleSet,
            polylines: polylines,
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

              // get the driver's current location
              getLiveLocationUpdates();
            },
          ),
        ],
      ),
    );
  }
}
