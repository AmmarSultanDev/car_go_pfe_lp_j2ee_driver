import 'package:car_go_pfe_lp_j2ee_driver/models/trip_details.dart';
import 'package:flutter/material.dart';

class NotificationDialog extends StatefulWidget {
  const NotificationDialog({super.key, required this.tripDetails});

  final TripDetails tripDetails;

  @override
  State<NotificationDialog> createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<NotificationDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: Theme.of(context).canvasColor,
      child: Container(
        margin: const EdgeInsets.all(5),
        width: double.infinity,
        decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.circular(4)),
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            Image.asset(
              'assets/images/electric_car.png',
              width: 140,
            ),
            const SizedBox(
              height: 16.0,
            ),
            Text(
              'New Trip Request',
              style: DefaultTextStyle.of(context).style.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
            ),
            const SizedBox(
              height: 20,
            ),
            Divider(
              height: 1,
              color: Theme.of(context).dividerColor,
              thickness: 1,
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // pick up
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/images/pin_map_start.png',
                        height: 16,
                        width: 16,
                      ),
                      const SizedBox(
                        width: 18,
                      ),
                      Expanded(
                        child: Text(
                          widget.tripDetails.pickupAddress!,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  // drop off
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/images/pin_map_destination.png',
                        height: 16,
                        width: 16,
                      ),
                      const SizedBox(
                        width: 18,
                      ),
                      Expanded(
                        child: Text(
                          widget.tripDetails.dropOffAddress!,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Divider(
              height: 1,
              color: Theme.of(context).dividerColor,
              thickness: 1,
            ),
            const SizedBox(
              height: 8,
            ),
            // accept and decline buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }
}
