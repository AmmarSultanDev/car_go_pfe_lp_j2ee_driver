import 'package:cloud_firestore/cloud_firestore.dart';

class Driver {
  String uid;
  final String displayName;
  final String phoneNumber;
  final String email;
  bool isBlocked = false;
  bool availability = false;
  String? photoUrl;
  final String vehiculeNumber;
  final String vehiculeModel;
  final String vehiculeColor;

  Driver({
    required this.uid,
    required this.displayName,
    required this.phoneNumber,
    required this.email,
    required this.vehiculeNumber,
    required this.vehiculeModel,
    required this.vehiculeColor,
    this.isBlocked = false,
    this.availability = false,
    this.photoUrl,
  });

  Driver.withoutUid({
    required this.displayName,
    required this.phoneNumber,
    required this.email,
    required this.vehiculeNumber,
    required this.vehiculeModel,
    required this.vehiculeColor,
  }) : uid = '';

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'displayName': displayName,
        'phoneNumber': phoneNumber,
        'email': email,
        'isBlocked': isBlocked,
        'availability': availability,
        'photoUrl': photoUrl,
        'vehiculeNumber': vehiculeNumber,
        'vehiculeModel': vehiculeModel,
        'vehiculeColor': vehiculeColor,
      };

  static Driver? fromSnap(DocumentSnapshot snap) {
    Map<String, dynamic> snapshot;

    if (snap.toString().isNotEmpty) {
      snapshot = snap.data() as Map<String, dynamic>;

      return Driver(
        uid: snapshot['uid'], // Add the 'uid' named parameter here
        displayName: snapshot['displayName'],
        phoneNumber: snapshot['phoneNumber'],
        email: snapshot['email'],
        isBlocked: snapshot['isBlocked'],
        availability: snapshot['availability'],
        photoUrl: snapshot['photoUrl'],
        vehiculeNumber: snapshot['vehiculeNumber'],
        vehiculeModel: snapshot['vehiculeModel'],
        vehiculeColor: snapshot['vehiculeColor'],
      );
    }
  }
}
