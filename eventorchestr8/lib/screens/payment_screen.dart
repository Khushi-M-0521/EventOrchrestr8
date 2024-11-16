import 'package:eventorchestr8/screens/home_screen.dart';
import 'package:eventorchestr8/screens/ticket_screen.dart';
import 'package:eventorchestr8/utils/utils.dart';
import 'package:eventorchestr8/widgets/dashed_divider.dart';
import 'package:eventorchestr8/widgets/profile_icon.dart';
import 'package:eventorchestr8/widgets/rounded_button.dart';
import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({required this.event, super.key});

  final Map<String, dynamic> event;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  Widget build(BuildContext context) {
    final ticketFee = widget.event["price"] as int;
    final double convienceFee = ticketFee * 0.1;
    final double amount = ticketFee + convienceFee;
    return Scaffold(
      appBar: AppBar(title: Text('Payment Gateway'), actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: ProfileIcon(),
        ),
      ]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Top Card (Event Details)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: Theme.of(context).colorScheme.inversePrimary,
              margin: EdgeInsets.only(bottom: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 25.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.event["title"],
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            //color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Text(
                          widget.event["theme"],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${formattedDate(widget.event["dateTime"])} | ${formattedTime(widget.event["dateTime"])}',
                          style: TextStyle(
                            fontSize: 16,
                            //color: Colors.blue[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          widget.event["location"],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DashedTicketDivider(
                      color: Theme.of(context).colorScheme.secondaryContainer),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ticket Price',
                          style: TextStyle(
                            fontSize: 16,
                            //color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '₹$ticketFee',
                          style: TextStyle(
                            fontSize: 16,
                            //color: Colors.yellow[900],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Bottom Card (Payment Details)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: Colors.grey[200],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Convenience Fee:',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '₹$convienceFee',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Contribution for reserving your seat.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    DashedDivider(
                      color: Colors.black54,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Payable:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        Text(
                          '₹$amount',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey[600]),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'By Proceeding, I Express My Consent to Complete this Transaction.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: RoundedButton(
                onPressed: () {
                  // Payment processing logic
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => TicketScreen(
                          event: widget.event,
                          amount: amount,
                          qr: 'h8j2k4l5m6n7o8p9q1r2s3t4u5v6w7x8y9z1a2b3c4d5e6f7g8h9j0',
                              leadingWidgetToPreviousScreen: IconButton(
                                  onPressed: () {
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (context) => HomeScreen()),
                                      (Route<dynamic> route) => false,
                                    );
                                  },
                                  icon: Icon(Icons.arrow_back)),
                            )),
                    (Route<dynamic> route) => route.isFirst,
                  );
                },
                child: Text("PAY ₹$amount"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
