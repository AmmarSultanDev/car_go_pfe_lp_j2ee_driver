import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_geofire/flutter_geofire.dart';

String googleMapKey = 'AIzaSyBtgO69A3xicdorydolvLf4CfEG91LAdIM';
// for dev purpose we're getting the location of google plex
const CameraPosition googlePlexInitialPosition = CameraPosition(
  target: LatLng(37.42796133580664, -122.085749655962),
  zoom: 14.4746,
);
const CameraPosition casablancaInitialPosition = CameraPosition(
  target: LatLng(33.5731, -7.5898),
  zoom: 14.4746,
);

StreamSubscription<Position>? homeTabPageStreamSubscription;

bool isGeofireInitialized = false;
