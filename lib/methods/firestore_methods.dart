import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> getCurrentDriverAvailabilitySatus(String uid) async {
    bool driverAvailabilityStatus = false;

    try {
      await _firestore.collection('drivers').doc(uid).get().then((value) {
        driverAvailabilityStatus = value.data()!['availability'];
      });
    } catch (e) {
      print(e);
    }

    return driverAvailabilityStatus;
  }

  // update the driver availability status
  Future<void> updateDriverAvailabilityStatus(
      String uid, bool availability) async {
    try {
      await _firestore.collection('drivers').doc(uid).update({
        'availability': availability,
      });
    } catch (e) {
      print(e);
    }
  }
}
