import 'package:car_go_pfe_lp_j2ee_driver/methods/firestore_methods.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationSystem {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  generateDeviceRegistrationToken() async {
    await FirestoreMethods().setDeviceToken();

    messaging.subscribeToTopic('drivers');
    messaging.subscribeToTopic('users');
  }

  startListeningForNewNotifications() async {
    ///1. Terminated
    //When the app is terminated
    messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        String tripId = message.data['trip_id'];
      }
    });

    ///2. Foreground
    //When the app is open and it receive a push notification
    FirebaseMessaging.onMessage.listen((RemoteMessage? message) {
      if (message != null) {
        String tripId = message.data['trip_id'];
      }
    });

    ///3. Background
    //when the app is in the background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) {
      if (message != null) {
        String tripId = message.data['trip_id'];
      }
    });
  }
}
