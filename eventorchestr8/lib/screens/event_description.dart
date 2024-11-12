import 'package:eventorchestr8/screens/payment_screen.dart';
import 'package:eventorchestr8/screens/ticket_screen.dart';
import 'package:eventorchestr8/utils/utils.dart';
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
        'Join us at ${widget.event["title"]} on ${formattedDate(widget.event['dateTime'])}, ${formattedTime(widget.event['dateTime'])} at ${widget.event['location']}.\n For more details, contact ${widget.event['contacts']['name']} at ${widget.event['contacts']['email']}/${widget.event['contacts']['phone']}. Don’t miss out!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image with FadeInImage
          Positioned.fill(
            bottom: MediaQuery.of(context).size.height * 0.5,
            child: FadeInImage(
              placeholder: AssetImage(
                  'assets/images/transparent.png'), // Placeholder image
              image: NetworkImage(
                  widget.event['imageUrl']), // Replace with your image asset
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
                            Column(
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
                                      Text(
                                        widget.event['location'],
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
                                        formattedDate(widget.event['dateTime']),
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
                                      Text(formattedTime(
                                          widget.event['dateTime'])),
                                    ],
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
                                  onPressed: () {
                                     Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) => !widget.isRegistered?PaymentScreen(
                                                  event: widget.event,
                                                ):TicketScreen(leadingWidgetToPreviousScreen: IconButton(onPressed: (){
                                                  Navigator.of(context).pop();
                                                }, icon: Icon(Icons.arrow_back)), amount: widget.event["price"]*1.1, event: widget.event, qr: 'h8j2k4l5m6n7o8p9q1r2s3t4u5v6w7x8y9z1a2b3c4d5e6f7g8h9j0',)));
                                  },
                                  child: !widget.isRegistered
                                      ? Text('Book Tickets')
                                      : Text("Veiw Ticket"),
                                ),
                                if (!widget.isRegistered)
                                  CountdownTimer(
                                    endTime:
                                        DateTime.fromMicrosecondsSinceEpoch(
                                                widget.event["dateTime"] as int)
                                            .millisecondsSinceEpoch,
                                    widgetBuilder: (_, time) {
                                      if (time == null) {
                                        return Text('Registration closed');
                                      }
                                      return Text(
                                        'Time left: ${time.days} days ${time.hours}:${time.min}:${time.sec}',
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
