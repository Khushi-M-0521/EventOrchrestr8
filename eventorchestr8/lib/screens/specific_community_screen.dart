import 'package:eventorchestr8/constants/example_events.dart';
import 'package:eventorchestr8/utils/utils.dart';
import 'package:flutter/material.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final List<Map<String, dynamic>> events = exampleEvents.sublist(3, 7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Community')),
      body: Stack(
        children: [
          ListView.builder(
            reverse: true,
            padding: EdgeInsets.only(bottom: 80),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final postDate = formattedDate(event['postTime']);
              final postTime = formattedTime(event['postTime']);
              bool showDateCard = index == events.length - 1 ||
                  formattedDate((events[index + 1]['postTime'])) != postDate;

              return Column(
                children: [
                  if (showDateCard)
                    Center(
                      child: Card(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: Text(postDate),
                        ),
                      ),
                    ),
                  Card(
                    margin: EdgeInsets.all(10),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              FadeInImage(
                                placeholder: AssetImage(
                                    'assets/images/transparent_image.png'),
                                image: NetworkImage(event["imageUrl"]),
                                fit: BoxFit.cover,
                                height: 100,
                                width: 100,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(event['title'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(event['theme']),
                                    Text(formattedDate(event['dateTime'])),
                                    Text(event['location']),
                                    Text('${event['attendees']} attendees'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  // View Stats
                                },
                                child: Text('View Stats'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  // Admit Attendee
                                },
                                child: Text('Admit Attendee'),
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(postTime,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          Positioned(
            bottom: 20,
            right: 0,
            left: 0,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Add new event
                },
                icon: Icon(Icons.add),
                label: Text('Post New Event'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
