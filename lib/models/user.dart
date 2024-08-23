import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String uid;
  final String displayName;
  final String phoneNumber;
  final String email;
  bool isBlocked = false;
  String? photoUrl;
  final String vehiculeNumber;
  final String vehiculeModel;
  final String vehiculeColor;

  User({
    required this.uid,
    required this.displayName,
    required this.phoneNumber,
    required this.email,
    required this.vehiculeNumber,
    required this.vehiculeModel,
    required this.vehiculeColor,
    this.isBlocked = false,
    this.photoUrl,
  });

  User.withoutUid({
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
        'photoUrl': photoUrl,
        'vehiculeNumber': vehiculeNumber,
        'vehiculeModel': vehiculeModel,
        'vehiculeColor': vehiculeColor,
      };

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot;

    if (snap.toString().length > 0) {
      snapshot = snap.data() as Map<String, dynamic>;

      return User(
        uid: snapshot['uid'], // Add the 'uid' named parameter here
        displayName: snapshot['displayName'],
        phoneNumber: snapshot['phoneNumber'],
        email: snapshot['email'],
        isBlocked: snapshot['isBlocked'],
        photoUrl: snapshot['photoUrl'],
        vehiculeNumber: snapshot['vehiculeNumber'],
        vehiculeModel: snapshot['vehiculeModel'],
        vehiculeColor: snapshot['vehiculeColor'],
      );
    }

    return User(
        uid: 'uid',
        displayName: 'displayName',
        phoneNumber: 'phoneNumber',
        email: 'email',
        vehiculeNumber: 'vehiculeNumber',
        vehiculeModel: 'vehiculeModel',
        vehiculeColor: 'vehiculeColor');
  }
}
