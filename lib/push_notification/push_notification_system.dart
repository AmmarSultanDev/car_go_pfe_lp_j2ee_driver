import 'package:car_go_pfe_lp_j2ee_driver/methods/firestore_methods.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationSystem {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  generateDeviceRegistrationToken() async {
    await FirestoreMethods().setDeviceToken();

    messaging.subscribeToTopic('drivers');
    messaging.subscribeToTopic('users');
  }
}
