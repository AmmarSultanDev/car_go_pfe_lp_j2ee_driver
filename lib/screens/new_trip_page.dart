import 'package:car_go_pfe_lp_j2ee_driver/models/trip_details.dart';
import 'package:flutter/material.dart';

class NewTripPage extends StatefulWidget {
  const NewTripPage({super.key, required this.tripDetails});

  final TripDetails tripDetails;

  @override
  State<NewTripPage> createState() => _NewTripPageState();
}

class _NewTripPageState extends State<NewTripPage> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('New Trip Page'),
    );
  }
}
