import 'dart:convert';
import 'dart:io';

import 'package:car_go_pfe_lp_j2ee_driver/global/global_var.dart';
import 'package:car_go_pfe_lp_j2ee_driver/models/direction_details.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class CommonMethods {
  const CommonMethods();

  checkConnectivity(BuildContext context) async {
    var connectionResult = await Connectivity().checkConnectivity();

    if (!connectionResult.contains(ConnectivityResult.mobile) &&
        !connectionResult.contains(ConnectivityResult.wifi)) {
      if (context.mounted) {
        displaySnackBar('No internet connection!', context);
      }
    }
  }

  void displaySnackBar(String text, BuildContext context) {
    // Display a snackbar
    if (context.mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(text),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  askForLocationPermission() async {
    if (await Permission.locationWhenInUse.isDenied ||
        await Permission.locationWhenInUse.status.isGranted != true) {
      await Permission.location.request();
    }
  }

  askForPhotosPermission() async {
    if (await Permission.photos.isDenied ||
        await Permission.photos.status.isGranted != true) {
      await Permission.photos.request();
    }
  }

  askForNotificationPermission() async {
    if (await Permission.notification.isDenied ||
        await Permission.notification.status.isGranted != true) {
      await Permission.notification.request();
    }
  }

  pickImage(ImageSource source) async {
    final ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: source);
    if (file != null) {
      var result = await FlutterImageCompress.compressWithFile(
        file.path,
        minWidth: 600,
        minHeight: 600,
        quality: 88,
        format: CompressFormat.png, // Add this line
      );
      if (result == null) {
        return null;
      }
      img.Image? image = img.decodeImage(result);
      if (image != null) {
        return img.encodePng(image);
      }
    }
  }

  goOfflinePermanently(BuildContext ctx) async {
    try {
      if (homeTabPageStreamSubscription != null) {
        await homeTabPageStreamSubscription!.cancel();
        homeTabPageStreamSubscription = null;
      }

      if (isGeofireInitialized) {
        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          await Geofire.removeLocation(currentUser.uid);
        }
      }
    } catch (e) {
      if (ctx.mounted) displaySnackBar('Error: $e', ctx);
    }
  }

  pauseLocationUpdates() async {
    if (homeTabPageStreamSubscription != null) {
      homeTabPageStreamSubscription!.pause();
    }
    // the driver now is busy
    Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid);
  }

  resumeLocationUpdates(Position driverCurrentPosition) async {
    if (homeTabPageStreamSubscription != null) {
      homeTabPageStreamSubscription!.resume();
    }
    // the driver now is available
    Geofire.setLocation(FirebaseAuth.instance.currentUser!.uid,
        driverCurrentPosition.latitude, driverCurrentPosition.longitude);
  }

  static sendRequestToApi(String apiURL) async {
    if (kDebugMode) {
      print(apiURL);
    }
    http.Response response = await http.get(Uri.parse(apiURL));

    try {
      if (response.statusCode == 200) {
        String dataFromApi = response.body;
        var dataDecoded = jsonDecode(dataFromApi);
        if (dataDecoded['status'] == 'REQUEST_DENIED') {
          return 'use_unrestricted';
        }
        return dataDecoded;
      } else {
        return 'error';
      }
    } catch (e) {
      return 'error';
    }
  }

  static Future<DirectionDetails?> getDirectionDetailsFromApi(
      LatLng source, LatLng destination) async {
    String? apiKey = Platform.isIOS
        ? dotenv.env['GOOGLE_MAPS_API_KEY_IOS']
        : dotenv.env['GOOGLE_MAPS_API_KEY_ANDROID'];
    String urlDirectionsApi =
        'https://maps.googleapis.com/maps/api/directions/json?destination=${destination.latitude},${destination.longitude}&origin=${source.latitude},${source.longitude}&mode=driving&key=$apiKey';

    var response = await sendRequestToApi(urlDirectionsApi);

    if (response != 'error') {
      if (response == 'use_unrestricted') {
        String urlDirectionsApiNoRestriction =
            'https://maps.googleapis.com/maps/api/directions/json?destination=${destination.latitude},${destination.longitude}&origin=${source.latitude},${source.longitude}&mode=driving&key=${dotenv.env['GOOGLE_MAPS_NO_RESTRICTION_API_KEY']}';

        response = await sendRequestToApi(urlDirectionsApiNoRestriction);

        if (response['status'] == 'OK') {
          DirectionDetails directionDetails = DirectionDetails(
            distanceText: response['routes'][0]['legs'][0]['distance']['text'],
            distanceValue: response['routes'][0]['legs'][0]['distance']
                ['value'],
            durationText: response['routes'][0]['legs'][0]['duration']['text'],
            durationValue: response['routes'][0]['legs'][0]['duration']
                ['value'],
            encodedPoints: response['routes'][0]['overview_polyline']['points'],
          );

          return directionDetails;
        }
      }
    }

    return null;
  }
}
