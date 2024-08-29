import 'dart:io';

import 'package:car_go_pfe_lp_j2ee_driver/models/trip_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  setDeviceToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    String? token = await messaging.getToken();
    String phoneModel = 'unknown';
    String? deviceId = 'unknown';

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      phoneModel = androidInfo.model;
      deviceId = androidInfo.id; // Unique device ID for Android
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      phoneModel = iosInfo.utsname.machine;
      deviceId = iosInfo.identifierForVendor; // Unique device ID for iOS
    }

    // Check if the phone is already registered
    DocumentSnapshot doc =
        await _firestore.collection('tokens').doc(user!.uid).get();
    if (doc.exists) {
      // Check if the device is already registered
      List<dynamic> devices = doc.get('devices');
      for (var device in devices) {
        if (device['id'] == deviceId) {
          return;
        }
      }
      // Update the device token in the Firestore database
      await _firestore.collection('tokens').doc(user!.uid).update({
        'devices': FieldValue.arrayUnion([
          {
            'id': deviceId,
            'model': phoneModel,
            'token': token,
          }
        ])
      });
    } else {
      // Set the device token in the Firestore database
      await _firestore.collection('tokens').doc(user!.uid).set({
        'devices': [
          {
            'id': deviceId,
            'model': phoneModel,
            'token': token,
          },
        ],
      });
    }
  }

  Future<TripDetails?> retrieveTripData(String tripId, context) async {
    // Retrieve the trip data from the Firestore database
    DocumentSnapshot snap =
        await _firestore.collection('tripRequests').doc(tripId).get();

    if (snap.exists) {
      // play notification sound
      // playNotificationSound();

      // get the trip details

      TripDetails tripDetails = TripDetails();
      tripDetails.tripId = tripId;

      tripDetails.pickupLocationCoordinates = LatLng(
        double.parse(
            (snap.data() as Map)['pickUpLocationCoordinates']['latitude']),
        double.parse(
            (snap.data() as Map)['pickUpLocationCoordinates']['longitude']),
      );
      tripDetails.pickupAddress = (snap.data() as Map)['pickUpAddress'];

      tripDetails.destinationLocationCoordinates = LatLng(
        double.parse(
            (snap.data() as Map)['dropOffLocationCoordinates']['latitude']),
        double.parse(
            (snap.data() as Map)['dropOffLocationCoordinates']['longitude']),
      );

      tripDetails.dropOffAddress = (snap.data() as Map)['dropOffAddress'];

      tripDetails.passengerDisplayName =
          (snap.data() as Map)['userInfo']['displayName'];

      tripDetails.passengerPhoneNumber =
          (snap.data() as Map)['userInfo']['phoneNumber'];

      return tripDetails;
    }
    return null;
  }
}
