import 'package:car_go_pfe_lp_j2ee_driver/methods/firestore_methods.dart';
import 'package:car_go_pfe_lp_j2ee_driver/widgets/loading_dialog.dart';
import 'package:car_go_pfe_lp_j2ee_driver/widgets/notification_dialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class PushNotificationSystem {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  generateDeviceRegistrationToken() async {
    await FirestoreMethods().setDeviceToken();

    messaging.subscribeToTopic('drivers');
    messaging.subscribeToTopic('users');
  }

  startListeningForNewNotifications(BuildContext context) async {
    ///1. Terminated
    //When the app is terminated
    messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        String tripId = message.data['tripId'];

        retrieveTripData(tripId, context);
      }
    });

    ///2. Foreground
    //When the app is open and it receive a push notification
    FirebaseMessaging.onMessage.listen((RemoteMessage? message) {
      if (message != null) {
        String tripId = message.data['tripId'];

        retrieveTripData(tripId, context);
      }
    });

    ///3. Background
    //when the app is in the background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) {
      if (message != null) {
        String tripId = message.data['tripId'];

        retrieveTripData(tripId, context);
      }
    });
  }

  retrieveTripData(String tripId, BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => const LoadingDialog(
              messageText: 'Loading Trip Data...',
            ));
    var response = await FirestoreMethods().retrieveTripData(tripId, context);

    if (context.mounted) Navigator.of(context).pop();

    if (response != null) {
      showDialog(
          context: context,
          builder: (context) => NotificationDialog(
                tripDetails: response,
              ));
    }
  }
}
