import 'package:eventorchestr8/screens/my_communities_screen.dart';
import 'package:eventorchestr8/screens/explore_screen.dart';
import 'package:eventorchestr8/screens/my_events_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    ExploreScreen(),
    MyCommunitiesScreen(),
    MyEventsScreen(),
  ];

  static final List<AppBar> _appBarOptions = <AppBar>[
    //ExploreScreen.appBar(),
    AppBar(
      toolbarHeight: 40,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
               "Hey User,",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "What are you looking for?",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    AppBar(
        title: Text(
               "Communities",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            toolbarHeight: 30,
      ),
    AppBar(
         title: Text(
               "My Events",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            toolbarHeight: 30,
      ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBarOptions[_selectedIndex],
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'My Communities',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Upcoming Events',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}