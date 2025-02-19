// import 'package:eventorchestr8/constants/example_events.dart';
import 'package:eventorchestr8/screens/analytics_screen.dart';
import 'package:eventorchestr8/screens/community_description_screen.dart';
import 'package:eventorchestr8/screens/create_event_form.dart';
import 'package:eventorchestr8/screens/event_description.dart';
import 'package:eventorchestr8/screens/qr_scanner_screen.dart';
import 'package:eventorchestr8/utils/utils.dart';
import 'package:eventorchestr8/widgets/value_style.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen(
      {required this.community, required this.isOwner, super.key});
  final Map<String, dynamic> community;
  final bool isOwner;

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  late Future<List<Map<String, dynamic>>> eventsFuture;

  @override
  void initState() {
    super.initState();
    // Fetch events for the particular community
    eventsFuture = _fetchEventsForCommunity(
        widget.community['created_by'], widget.community['name']);
  }

  Map<String, int> _castToIntMap(dynamic duration) {
    if (duration is Map) {
      return duration.map(
          (key, value) => MapEntry(key, int.tryParse(value.toString()) ?? 0));
    }
    return {};
  }

  String formattedDate2(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate(); // Convert to DateTime
    return DateFormat('MMMM dd, yyyy')
        .format(dateTime); // Format as "November 30, 2024"
  }

  String formattedTime2(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate(); // Convert to DateTime
    return DateFormat('hh:mm a').format(dateTime); // Format as "11:30 AM"
  }

  String formatDuration2(Map<String, int> duration) {
    int hours = duration['hours'] ?? 0; // Extract hours
    int minutes = duration['minutes'] ?? 0; // Extract minutes (if applicable)
    return '${hours}h ${minutes}m'; // e.g., "1h 30m"
  }

  String formattedPostDate(DateTime dateTime) {
    return DateFormat('MMMM dd, yyyy')
        .format(dateTime); // Format as "November 30, 2024"
  }

  String formattedPostTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime); // Format as "11:30 AM"
  }

  Future<List<Map<String, dynamic>>> _fetchEventsForCommunity(
      String created_by, String community_id) async {
    try {
      // Query Firestore for events created by this user and belonging to the specified community
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('created_by', isEqualTo: created_by)
          .where('community_id', isEqualTo: community_id)
          .get();

      // Map the documents to a list of maps
      return snapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();
    } catch (e) {
      print("Error fetching events: $e");
      return [];
    }
  }

  void _handleMenuItem(String value) {
      _showCancelDialog(value);
  }

  void _showCancelDialog(String leave_close) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$leave_close Confirmation'),
          content: Text('Are you sure you want to ${leave_close.toLowerCase()} it?'),
          actions: [
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
                // Close the dialog
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
                // Close the dialog and handle the cancel action
                // Add your cancel action here
                print('Action closed');
              },
            ),
          ],
        );
      },
    );
  }

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
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: _handleMenuItem,
            itemBuilder: (BuildContext context) {
              return [
                widget.isOwner? PopupMenuItem<String>(
                  value: 'Close',
                  child: Text('Close'),
                ):PopupMenuItem<String>(
                  value: 'Leave',
                  child: Text('Leave'),
                ),
              ];
            },
            icon: Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Stack(
        children: [
          FutureBuilder<List<Map<String, dynamic>>>(
            future: eventsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              final events = snapshot.data ?? [];

              return events.isEmpty
                  ? Center(
                      child: Text(
                        'No events available for this community.',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    )
                  : ListView.builder(
                      reverse: true,
                      padding:
                          EdgeInsets.only(bottom: widget.isOwner ? 80 : 10),
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        print(event['duration']);
                        // DateTime postTime = event[
                        //     'postTime']; // Ensure this is a DateTime object

                        // String postDate = formattedPostDate(postTime);
                        // String postTim = formattedPostTime(postTime);
                        final postDate = formattedDate(event['postTime']);
                        final postTime = formattedTime(event['postTime']);
                        bool showDateCard = index == events.length - 1 ||
                            formattedDate((events[index + 1]['postTime'])) !=
                                postDate;
                        print(formattedDate(1731917404989));
                        print(postTime);
                        print(postDate);

                        return Column(
                          children: [
                            if (showDateCard)
                              Center(
                                child: Card(
                                  margin: EdgeInsets.symmetric(vertical: 5),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    child: Text(postDate),
                                  ),
                                ),
                              ),
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        EventDescriptionScreen(
                                            event: event,
                                            isRegistered: false)));
                              },
                              child: Card(
                                margin: EdgeInsets.all(10),
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            child: FadeInImage(
                                              placeholder: AssetImage(
                                                  'assets/images/transparent_image.png'),
                                              image: event["imageUrl"] != "" &&
                                                      event["imageUrl"] != null
                                                  ? NetworkImage(
                                                      event["imageUrl"])
                                                  : AssetImage(
                                                      'assets/images/transparent_image.png'),
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
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(event['title'],
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        Text(
                                                          event['theme'],
                                                          style: ValueStyle(),
                                                        ),
                                                      ],
                                                    ),
                                                    if (widget.isOwner)
                                                      IconButton(
                                                          onPressed: () {},
                                                          icon: Icon(
                                                            Icons.edit,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .primary,
                                                          ))
                                                  ],
                                                ),
                                                if (!widget.isOwner)
                                                  const SizedBox(height: 5),
                                                Text(
                                                  '${event['dateTime'].runtimeType == Timestamp ? formattedDate2(event['dateTime']) : formattedDate(event['dateTime'])} | ${event['dateTime'].runtimeType == Timestamp ? formattedTime2(event['dateTime']) : formattedTime(event['dateTime'])} | ${formatDuration2(_castToIntMap(event['duration']))}',
                                                  style: ValueStyle().copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
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
                                      if (widget.isOwner)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            FilledButton(
                                              onPressed: () {
                                                // View Stats
                                                Navigator.of(context).push(MaterialPageRoute(builder: (context)=> AnalyticsScreen()));
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
                                      if (!widget.isOwner)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
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
                    );
            },
          ),
          if (widget.isOwner)
            Positioned(
              bottom: 20,
              right: 0,
              left: 0,
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => CreateEventPage(
                          communityId: widget.community['name']),
                    ));
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
