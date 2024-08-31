import 'dart:io';

import 'package:car_go_pfe_lp_j2ee_driver/models/trip_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  setDeviceToken(String token) async {
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
        if (device['id'] == deviceId && device['token'] == token) {
          return;
        } else if (device['id'] == deviceId && device['token'] != token) {
          // Update the device token in the Firestore database
          await _firestore.collection('tokens').doc(user!.uid).update({
            'devices': FieldValue.arrayRemove([
              {
                'id': deviceId,
                'model': phoneModel,
                'token': device['token'],
              }
            ])
          });
          await _firestore.collection('tokens').doc(user!.uid).update({
            'devices': FieldValue.arrayUnion([
              {
                'id': deviceId,
                'model': phoneModel,
                'token': token,
              }
            ])
          });
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

  Future<TripDetails?> retrieveTripDataFromFirebase(String tripId) async {
    // Retrieve the trip data from the Firestore database
    DocumentSnapshot snap =
        await _firestore.collection('tripRequests').doc(tripId).get();

    if (snap.exists) {
      // play notification sound
      // playNotificationSound();

      // get the trip details

      TripDetails tripDetails = TripDetails();
      tripDetails.tripId = tripId;

      Map<String, dynamic>? data = snap.data() as Map<String, dynamic>?;

      tripDetails.pickupLocationCoordinates = LatLng(
        double.parse(data?['pickUpLocationCoordinates']['latitude'] ?? '0'),
        double.parse(data?['pickUpLocationCoordinates']['longitude'] ?? '0'),
      );
      tripDetails.pickupAddress = data?['pickUpAddress'] ?? '';

      tripDetails.destinationLocationCoordinates = LatLng(
        double.parse(data?['dropOffLocationCoordinates']['latitude'] ?? '0'),
        double.parse(data?['dropOffLocationCoordinates']['longitude'] ?? '0'),
      );
      tripDetails.dropOffAddress = data?['dropOffAddress'] ?? '';

      tripDetails.passengerDisplayName =
          data?['passengerInfo']['displayName'] ?? '';
      tripDetails.passengerPhoneNumber =
          data?['passengerInfo']['phoneNumber'] ?? '';

      return tripDetails;
    }
    return null;
  }

  updateTripRequestStatus(String requestId, String status) async {
    try {
      await _firestore
          .collection('tripRequests')
          .doc(requestId)
          .update({'status': status});
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<bool> getDriverAvailabilityStatus() async {
    DatabaseReference dbRef = FirebaseDatabase.instance.ref('onlineDrivers');
    DataSnapshot snapshot = (await dbRef.child(user!.uid).once()).snapshot;

    if (snapshot.value != null) {
      // The child with the user ID exists
      return true;
    } else {
      // The child with the user ID does not exist
      return false;
    }
  }
}
