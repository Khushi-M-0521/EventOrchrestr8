import 'package:eventorchestr8/utils/utils.dart';
import 'package:eventorchestr8/widgets/rounded_button.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDescriptionScreen extends StatefulWidget {
  @override
  State<EventDescriptionScreen> createState() => _EventDescriptionScreenState();
}

class _EventDescriptionScreenState extends State<EventDescriptionScreen> {
  void _launchURL(String location) async {
    final Uri url =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=Bangalore, Institute of Technology, Bangalore, India');
    print(url.toString());
    try {
        await launchUrl(url);
    } catch (e) {
      showSnackBar(context, 'Could not launch $url');
      throw e.toString();
    }
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
                  "https://images.pexels.com/photos/442576/pexels-photo-442576.jpeg?auto=compress&cs=tinysrgb&w=400"), // Replace with your image asset
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
                                  'Summer Fiesta 2023',
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _launchURL("Bangalore, India");
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
                                        'Bangalore, India',
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
                                    children: [
                                      Icon(Icons.calendar_today,
                                          size: 10,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                      Text(
                                        '10th June, 2023',
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
                                      Text('10:00 AM'),
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
                            Text('Outdoor Music & Arts Festival'),
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
                            Text('150 People Registered'),
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
                          'Join us for a day of fun, music, and art! Enjoy live performances, art exhibitions, and food stalls. Bring your friends and family for an unforgettable experience!',
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
                                  'Organizer: John Doe\njohn.doe@example.com\n +1234567890',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            TextButton.icon(
                              icon: Icon(Icons.share),
                              label: Text('Share '),
                              onPressed: () {
                                // Social media sharing logic
                              },
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
                                          text: "₹200",
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
                                    // Booking logic
                                  },
                                  child: Text('Book Tickets'),
                                ),
                                Text(
                                  'Time Left: 5 days 15:14',
                                  style: TextStyle(fontSize: 12),
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
