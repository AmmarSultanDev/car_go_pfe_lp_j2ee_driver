import 'package:flutter/material.dart';

class TripDetailsScreen extends StatefulWidget {
  const TripDetailsScreen({super.key});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    // in this screen the user can see the trip details
    // the trip details will include the trip date, the trip distance, the trip duration, the trip cost, and the trip path on the map
    // also the user can see the passenger details, his name and his phone number
    return const Placeholder();
  }
}
