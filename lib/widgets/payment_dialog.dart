import 'package:car_go_pfe_lp_j2ee_driver/methods/common_methods.dart';
import 'package:car_go_pfe_lp_j2ee_driver/methods/firestore_methods.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PaymentDialog extends StatefulWidget {
  const PaymentDialog({super.key, required this.fareAmount});

  final String fareAmount;

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  CommonMethods commonMethods = const CommonMethods();
  updateTripStatusToEnded() async {
    await FirestoreMethods()
        .updateDriverTotalEarnings(double.parse(widget.fareAmount));
  }

  @override
  Widget build(BuildContext context) {
    updateTripStatusToEnded();
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
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 21,
            ),
            Text('Payment',
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onSurface,
                    )),
            const SizedBox(
              height: 21,
            ),
            Divider(
              height: 1,
              color: Theme.of(context).dividerColor,
              thickness: 1,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              '\$ ${widget.fareAmount}',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Please collect the fare amount of \$ ${widget.fareAmount}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(
              height: 21,
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      commonMethods.playFairAmountReceivedSound();

                      Navigator.of(context).pop();
                      Navigator.of(context).pop();

                      commonMethods.resumeLocationUpdates();
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
