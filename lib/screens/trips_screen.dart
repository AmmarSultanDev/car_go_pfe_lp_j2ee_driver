import 'package:car_go_pfe_lp_j2ee_driver/methods/firestore_methods.dart';
import 'package:car_go_pfe_lp_j2ee_driver/widgets/trip_list_item.dart';
import 'package:flutter/material.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  getTrips() async {
    // get the trips of the user
    await FirestoreMethods().getTrips()?.then((value) {
      setState(() {
        endedTripDetails = value;
      });
    });
  }

  List endedTripDetails = [];

  @override
  Widget build(BuildContext context) {
    getTrips();

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
        ),
        width: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height,
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 100,
                  ),
                  Image.asset(
                    'assets/images/trips.png',
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Expanded(
                      child: ListView.builder(
                    itemCount: endedTripDetails.length,
                    itemBuilder: (ctx, index) {
                      if (endedTripDetails.isNotEmpty) {
                        return TripListItem(
                            endedTripDetails: endedTripDetails[index]);
                      } else {
                        return Text('No trips found');
                      }
                    },
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
