import 'dart:async';

import 'package:car_go_pfe_lp_j2ee_driver/global/global_var.dart';
import 'package:car_go_pfe_lp_j2ee_driver/methods/common_methods.dart';
import 'package:car_go_pfe_lp_j2ee_driver/methods/map_theme_methods.dart';
import 'package:car_go_pfe_lp_j2ee_driver/models/direction_details.dart';
import 'package:car_go_pfe_lp_j2ee_driver/models/ended_trip_details.dart';
import 'package:car_go_pfe_lp_j2ee_driver/providers/navigation_provider.dart';
import 'package:car_go_pfe_lp_j2ee_driver/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class TripDetailsScreen extends StatefulWidget {
  const TripDetailsScreen({super.key, required this.endedTripDetails});

  final EndedTripDetails endedTripDetails;

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  final Completer<GoogleMapController> googleMapCompleterController =
      Completer<GoogleMapController>();

  GoogleMapController? controllerGoogleMap;

  PolylinePoints polylinePoints = PolylinePoints();

  List<LatLng> polylineCoordinates = [];

  Set<Marker> markerSet = {};

  Set<Circle> circleSet = {};

  Set<Polyline> polylines = {};

  int tripDistance = 0;

  int tripDuration = 0;

  String tripCost = '';

  DirectionDetails? tripDetailsInfo;

  setTripInfo() {
    setState(() {
      tripDistance = tripDetailsInfo?.distanceValue ?? 0;
      tripDuration = tripDetailsInfo?.durationValue ?? 0;
      print('Fare amount: ${widget.endedTripDetails.fareAmout ?? 'null'}');
      tripCost = widget.endedTripDetails.fareAmout ?? '0';
      print('Trip distance: $tripDistance');
      print('Trip duration: $tripDuration');
      print('Trip cost: $tripCost');
    });
  }

  drawRoute(LatLng start, LatLng end) async {
    showDialog(
      context: context,
      builder: (context) => const LoadingDialog(
        messageText: 'Please wait...',
      ),
    );

    tripDetailsInfo =
        await CommonMethods.getDirectionDetailsFromApi(start, end);

    if (mounted) Navigator.pop(context);

    setTripInfo();

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
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
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

  @override
  Widget build(BuildContext context) {
    // in this screen the user can see the trip details
    // the trip details will include the trip date, the trip distance, the trip duration, the trip cost, and the trip path on the map
    // also the user can see the passenger details, his name and his phone number

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: const EdgeInsets.only(top: 100),
            initialCameraPosition: casablancaInitialPosition,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            markers: markerSet,
            circles: circleSet,
            polylines: polylines,
            onMapCreated: (GoogleMapController mapController) async {
              controllerGoogleMap = mapController;
              MapThemeMethods().updateMapTheme(controllerGoogleMap!, context);

              googleMapCompleterController.complete(controllerGoogleMap);

              await drawRoute(
                  widget.endedTripDetails.pickUpLocationCoordinates!,
                  widget.endedTripDetails.dropOffLocationCoordinates!);
            },
          ),
          Positioned(
            top: 50,
            left: 19,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                Provider.of<NavigationProvider>(context, listen: false)
                    .selectedIndex = 2;
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7),
                      )
                    ]),
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  radius: 20,
                  child: const Icon(
                    Icons.arrow_back,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trip Date: ${widget.endedTripDetails.acceptedAt}',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Trip Distance: $tripDistance',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  // Add more Text widgets for other trip details
                  Text(
                    'Trip Duration: $tripDuration',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Trip Cost: $tripCost',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
