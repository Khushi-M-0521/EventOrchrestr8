import 'dart:async';
import 'package:eventorchestr8/utils/utils.dart';
import 'package:eventorchestr8/widgets/dashed_divider.dart';
import 'package:eventorchestr8/widgets/label_style.dart';
import 'package:eventorchestr8/widgets/secure_screen.dart';
import 'package:eventorchestr8/widgets/title_text.dart';
import 'package:eventorchestr8/widgets/value_style.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({
    required this.leadingWidgetToPreviousScreen,
    required this.amount,
    required this.event,
    required this.qr,
    super.key,
  });

  final Widget? leadingWidgetToPreviousScreen;
  final Map<String, dynamic> event;
  final double amount;
  final String qr;

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  bool showQr = false;
  int secondsLeft = 5;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    SecureScreen.enableSecureScreen();
  }

  void _showQrCode() {
    setState(() {
      showQr = true;
    });
    timer?.cancel(); // Cancel any previous timer
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (secondsLeft > 0) {
          secondsLeft--;
        } else {
          secondsLeft = 5;
          showQr = false;
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    SecureScreen.disableSecureScreen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SecureScreen.enableSecureScreen();
    return Scaffold(
      appBar: AppBar(
        leading: widget.leadingWidgetToPreviousScreen,
        title: TitleText(text: 'Ticket'),
      ),
      body: SingleChildScrollView(
        child: Stack(children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 30,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25.0, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                widget.event["title"],
                                overflow: TextOverflow.visible,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                              Text(
                                widget.event["theme"],
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimary
                                      .withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.qr_code,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          iconSize: 60, // Adjust as needed
                          onPressed: _showQrCode,
                        ),
                      ],
                    ),
                  ),
                  QrImageView(
                    data: widget.qr,
                    version: QrVersions.auto,
                    size: 300.0,
                    backgroundColor: Colors.white,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  DashedTicketDivider(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  SizedBox(height: 10),
                  // Section 2
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25.0,
                    ),
                    child: Table(
                      children: [
                        TableRow(
                          children: [
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Venue',
                                      style: LabelStyle().copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                    ),
                                    Text(
                                      widget.event["location"],
                                      style: ValueStyle().copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Date',
                                      style: LabelStyle().copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                    ),
                                    Text(
                                      formattedDate2(widget.event["dateTime"]),
                                      style: ValueStyle().copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Status',
                                      style: LabelStyle().copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                    ),
                                    Text(
                                      'Confirmed',
                                      style: ValueStyle().copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Time',
                                      style: LabelStyle().copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                    ),
                                    Text(
                                      formattedTime2(widget.event["dateTime"]),
                                      style: ValueStyle().copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  DashedTicketDivider(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  // Section 3
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25.0, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Name',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                            Text(
                              'John Doe',
                              style: LabelStyle().copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              'Amount',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                            Text(
                              '₹${widget.amount}',
                              style: LabelStyle().copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // QR code overlay
          // if (showQr)
          //   Container(
          //     color: Colors.black54,
          //     alignment: Alignment.center,
          //     child: Column(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         QrImageView(
          //           data: widget.qr,
          //           version: QrVersions.auto,
          //           size: 300.0,
          //           backgroundColor: Colors.white,
          //         ),
          //         SizedBox(height: 20),
          //         Text(
          //           '${secondsLeft}s left',
          //           style: TextStyle(
          //             fontSize: 24,
          //             color: Colors.white,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
        ]),
      ),
    );
  }
}
