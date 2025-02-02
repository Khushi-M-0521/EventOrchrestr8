import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventorchestr8/screens/payment_screen.dart';
import 'package:eventorchestr8/screens/ticket_screen.dart';
import 'package:eventorchestr8/utils/utils.dart';
import 'package:eventorchestr8/utils/block_creation.dart';
import 'package:eventorchestr8/utils/data_generation.dart';
import 'package:eventorchestr8/widgets/rounded_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDescriptionScreen extends StatefulWidget {
  const EventDescriptionScreen(
      {required this.event, required this.isRegistered, super.key});

  final Map<String, dynamic> event;
  final bool isRegistered;

  @override
  State<EventDescriptionScreen> createState() => _EventDescriptionScreenState();
}

class _EventDescriptionScreenState extends State<EventDescriptionScreen> {
  final data = DataGenerator.generateData();
  late String eventId = data["eventId"];
  late String userId = data["userId"];
  late String uuid = data["uuid"];
  late int price = data["price"];
  int paymentId = DateTime.now().millisecondsSinceEpoch;

  void _launchURL(String location) async {
    final Uri url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=Bangalore, $location');
    try {
      await launchUrl(url);
    } catch (e) {
      showSnackBar(context, 'Could not launch $url');
    }
  }

  void _shareEventDetails() {
    Share.share(
        'Join us at ${widget.event["title"]} on ${formattedDate2(widget.event['dateTime'])}, ${formattedTime2(widget.event['dateTime'])} at ${widget.event['location']}.\n For more details, contact ${widget.event['contacts']['name']} at ${widget.event['contacts']['email']}/${widget.event['contacts']['phone']}. Don’t miss out!');
  }

  Map<String, int> _castToIntMap(Map<String, dynamic> duration) {
    return {
      'hours': duration['hours'] as int,
      'minutes': duration['minutes'] != null
          ? duration['minutes'] as int
          : 0, // Default to 0 if minutes is missing
    };
  }

  @override
  Widget build(BuildContext context) {
    print(widget.event);
    return Scaffold(
      body: Stack(
        children: [
          // Background image with FadeInImage
          Positioned.fill(
            bottom: MediaQuery.of(context).size.height * 0.5,
            child: FadeInImage(
              placeholder: AssetImage(
                  'assets/images/transparent_image.png'), // Placeholder image
              image: widget.event['imageUrl'] != null ||
                      widget.event['imageUrl'] == ""
                  ? NetworkImage(widget.event['imageUrl'])
                  : AssetImage(
                      'assets/images/transparent_image.png'), // Replace with your image asset
              fit: BoxFit.fill,
            ),
          ),
          SafeArea(
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          // Draggable container
          DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.6,
            maxChildSize: 0.7,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.event['title'],
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      _launchURL(widget.event['location']);
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          size: 15,
                                        ),
                                        Expanded(
                                          child: Text(
                                            widget.event['location'],
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Chip(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    width: 1), // Change color and width here
                                borderRadius: BorderRadius.circular(8),
                              ),
                              labelStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.primary),
                              label: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.calendar_today,
                                          size: 10,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        widget.event['dateTime'].runtimeType ==
                                                Timestamp
                                            ? formattedDate2(
                                                widget.event['dateTime'])
                                            : formattedDate(
                                                widget.event['dateTime']),
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                      Text(widget.event['dateTime']
                                                  .runtimeType ==
                                              Timestamp
                                          ? formattedTime2(
                                              widget.event['dateTime'])
                                          : formattedTime(
                                              widget.event['dateTime'])),
                                    ],
                                  ),
                                  Text(
                                    ' ${formatDuration2(_castToIntMap(widget.event['duration']))}',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.palette,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(widget.event['theme']),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.groups_2,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                                '${widget.event['peopleRegistered']} People Registered'),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.event['description'],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Contacts',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${widget.event['contacts']['name']}\n${widget.event['contacts']['email']}\n${widget.event['contacts']['phone']}',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            TextButton.icon(
                              icon: Icon(Icons.share),
                              label: Text('Share '),
                              onPressed: _shareEventDetails,
                            )
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Price',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500)),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                          text: "₹${widget.event["price"]}",
                                          style: TextStyle(
                                              fontSize: 24,
                                              color: Colors.green)),
                                      TextSpan(text: " /Person")
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                RoundedButton(
                                  onPressed: () async {
                                    if (!widget.isRegistered) {
                                      // Only proceed if the user is not yet registered

                                      TicketingWorkflow().handleRegistration(
                                          context,
                                          eventId,
                                          userId,
                                          uuid,
                                          price,
                                          paymentId);
                                      if (widget.event
                                              .containsKey('googleFormUrl') &&
                                          widget.event['googleFormUrl'] !=
                                              null &&
                                          widget.event['googleFormUrl']
                                              .isNotEmpty) {
                                        final Uri googleFormUrl = Uri.parse(
                                            widget.event['googleFormUrl']);

                                        try {
                                          // Open the Google Form
                                          await launchUrl(googleFormUrl,
                                              mode: LaunchMode
                                                  .externalApplication);

                                          // Show instructions to the user
                                          showSnackBar(context,
                                              "After submitting the form, return to proceed with payment.");

                                          // Wait for the user to come back (mock submission detection)
                                          // In a real app, you may handle this with a custom thank-you page redirect
                                          Future.delayed(Duration(seconds: 5),
                                              () {
                                            // Navigate to the payment screen
                                            Navigator.of(context)
                                                .push(MaterialPageRoute(
                                              builder: (context) =>
                                                  PaymentScreen(
                                                      event: widget.event),
                                            ));
                                          });
                                        } catch (e) {
                                          showSnackBar(context,
                                              "Could not open the Google Form.");
                                        }
                                      } else {
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                          builder: (context) => PaymentScreen(
                                              event: widget.event),
                                        ));
                                      }
                                    } else {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => TicketScreen(
                                            leadingWidgetToPreviousScreen:
                                                IconButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    icon:
                                                        Icon(Icons.arrow_back)),
                                            amount: int.parse(widget
                                                    .event["price"]
                                                    .toString()) *
                                                1.1,
                                            event: widget.event,
                                            qr: 'h8j2k4l5m6n7o8p9q1r2s3t4u5v6w7x8y9z1a2b3c4d5e6f7g8h9j0',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: !widget.isRegistered
                                      ? Text('Register')
                                      : Text("View Ticket"),
                                ),
                                if (!widget.isRegistered)
                                  CountdownTimer(
                                    endTime: widget.event['dateTime']
                                                .runtimeType ==
                                            Timestamp
                                        ? (widget.event["dateTime"]
                                                as Timestamp)
                                            .toDate()
                                            .millisecondsSinceEpoch
                                        : DateTime.fromMicrosecondsSinceEpoch(
                                                widget.event['dateTime'] as int)
                                            .millisecondsSinceEpoch,
                                    widgetBuilder: (_, time) {
                                      if (time == null) {
                                        return Text('Registration closed');
                                      }
                                      return Text(
                                        'Time left: ${time.days ?? 0} days ${time.hours ?? 0}:${time.min ?? 0}:${time.sec ?? 0}',
                                        style: TextStyle(fontSize: 12),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
