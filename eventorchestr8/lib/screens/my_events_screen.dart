import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventorchestr8/screens/event_description.dart';
import 'package:eventorchestr8/widgets/event_list_card.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  _MyEventsScreenState createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<Map<String, dynamic>> events = [];

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      // Fetch events from Firestore
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('events').get();

      // Convert Firestore data to the correct structure
      setState(() {
        events = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            ...data,
            'dateTime': (data['dateTime'] as Timestamp)
                .toDate(), // Always convert Timestamp to DateTime
          };
        }).toList();
      });
    } catch (e) {
      print("Error fetching events: $e");
    }
  }

  List<Map<String, dynamic>> _getEventsForSelectedDay() {
    if (_selectedDay == null) {
      return [];
    }

    return events.where((event) {
      DateTime eventDate = event['dateTime']; // Directly use as DateTime
      return isSameDay(eventDate, _selectedDay);
    }).toList();
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return events.where((event) {
      DateTime eventDate = event['dateTime']; // Directly use as DateTime
      return isSameDay(eventDate, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> list = _getEventsForSelectedDay();
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay; // Update focusedDay as well
            });
          },
          calendarFormat: _calendarFormat,
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          calendarBuilders: CalendarBuilders(
            selectedBuilder: (context, date, events) {
              return Container(
                margin: const EdgeInsets.all(4.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.6), // Change this to your desired color
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${date.day}',
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              );
            },
            markerBuilder: (context, date, events) {
              final eventCount = _getEventsForDay(date).length;
              if (eventCount > 0) {
                return Positioned(
                  top: 6,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    width: 10,
                    height: 10,
                    alignment: Alignment.center,
                    child: Text(
                      '$eventCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                    ),
                  ),
                );
              }
              return null;
            },
          ),
        ),
        Expanded(
          child: (list.isNotEmpty)
              ? ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final event = list[index];
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => EventDescriptionScreen(
                            event: {
                              ...event,
                              'dateTime': Timestamp.fromDate(event[
                                  'dateTime']), // Convert back to Timestamp
                            },
                            isRegistered: true,
                          ),
                        ));
                      },
                      child: EventListTile(
                        imageUrl: event['imageUrl'],
                        title: event['title'],
                        location: event['location'],
                        peopleRegistered: event['peopleRegistered'],
                        dateTime: Timestamp.fromDate(
                            event['dateTime']), // Already DateTime
                      ),
                    );
                  },
                )
              : const Text("No Events!!"),
        ),
      ],
    );
  }
}
