import 'package:eventorchestr8/constants/example_events.dart';
import 'package:eventorchestr8/screens/community_description_screen.dart';
import 'package:eventorchestr8/screens/create_event_form.dart';
import 'package:eventorchestr8/screens/event_description.dart';
import 'package:eventorchestr8/screens/qr_scanner_screen.dart';
import 'package:eventorchestr8/utils/utils.dart';
import 'package:eventorchestr8/widgets/value_style.dart';
import 'package:flutter/material.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen(
      {required this.community, required this.isOwner, super.key});
  final Map<String, dynamic> community;
  final bool isOwner;

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final List<Map<String, dynamic>> events = exampleEvents.sublist(3, 7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 25,
        title: InkWell(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  CommunityDescriptionScreen(community: widget.community))),
          child: Row(
            children: [
              ClipOval(
                child: FadeInImage(
                  placeholder:
                      AssetImage('assets/images/transparent_image.png'),
                  image: NetworkImage(widget.community["imageUrl"]),
                  fit: BoxFit.cover,
                  width: 40,
                  height: 40,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Text(widget.community['name'])
            ],
          ),
        ),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.more_vert))],
      ),
      body: Stack(
        children: [
          ListView.builder(
            reverse: true,
            padding: EdgeInsets.only(bottom: widget.isOwner? 80:10),
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
                        margin: EdgeInsets.symmetric(vertical: 5),
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: Text(postDate),
                        ),
                      ),
                    ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => EventDescriptionScreen(
                              event: event, isRegistered: false)));
                    },
                    child: Card(
                      margin: EdgeInsets.all(10),
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: FadeInImage(
                                    placeholder: AssetImage(
                                        'assets/images/transparent_image.png'),
                                    image: NetworkImage(event["imageUrl"]),
                                    fit: BoxFit.fill,
                                    height: 100,
                                    width: 100,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(event['title'],
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Text(
                                                event['theme'],
                                                style: ValueStyle(),
                                              ),
                                            ],
                                          ),
                                          if(widget.isOwner)
                                          IconButton(
                                              onPressed: () {},
                                              icon: Icon(
                                                Icons.edit,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ))
                                        ],
                                      ),
                                      if(!widget.isOwner)
                                      const SizedBox(height: 5,),
                                      Text(
                                        '${formattedDate(event['dateTime'])} | ${formattedTime(event['dateTime'])} |${formatDuration(event['duration'] as Map<String, int>)}',
                                        style: ValueStyle().copyWith(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        event['location'],
                                        style: ValueStyle(),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        '${event['peopleRegistered']} attendees',
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Divider(),
                            if(widget.isOwner)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                FilledButton(
                                  onPressed: () {
                                    // View Stats
                                  },
                                  child: Text('View Stats'),
                                ),
                                FilledButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                QRScannerScreen()));
                                  },
                                  child: Text('Admit Attendee'),
                                ),
                              ],
                            ),
                            if(!widget.isOwner)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                FilledButton(
                                  onPressed: () {
                                    // Register
                                  },
                                  child: Text('Register'),
                                ),
                              ],
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(postTime,
                                  style: ValueStyle()
                                      .copyWith(color: Colors.grey)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          if(widget.isOwner)
          Positioned(
            bottom: 20,
            right: 0,
            left: 0,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => CreateEventPage()));
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


/**
 * time duration
 * style
 * community appbar
 * click to see details
 * edit icon
 * QR Scanner
 * 
 * attendee pov
 */