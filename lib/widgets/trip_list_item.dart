import 'package:car_go_pfe_lp_j2ee_driver/models/ended_trip_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TripListItem extends StatelessWidget {
  const TripListItem({super.key, required this.endedTripDetails});

  final EndedTripDetails endedTripDetails;

  String get locationImage {
    final lat = endedTripDetails.destinationCoordinates!.latitude;
    final lng = endedTripDetails.destinationCoordinates!.longitude;
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng=&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C$lat,$lng&key=${dotenv.env['GOOGLE_MAPS_NO_RESTRICTION_API_KEY']}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(24)),
        color: Theme.of(context).canvasColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onPrimary,
            blurRadius: 15.0,
            spreadRadius: 0.5,
            offset: const Offset(
              0.7,
              0.7,
            ),
          )
        ],
      ),
      child: GestureDetector(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.network(locationImage, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
