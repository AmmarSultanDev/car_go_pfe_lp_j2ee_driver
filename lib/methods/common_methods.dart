import 'package:car_go_pfe_lp_j2ee_driver/global/global_var.dart';
import 'package:car_go_pfe_lp_j2ee_driver/screens/authentication/signin_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';

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
}
