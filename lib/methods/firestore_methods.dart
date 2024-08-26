import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
}
