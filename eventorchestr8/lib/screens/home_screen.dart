import 'package:eventorchestr8/provider/shared_preferences_provider.dart';
import 'package:eventorchestr8/screens/my_communities_screen.dart';
import 'package:eventorchestr8/screens/explore_screen.dart';
import 'package:eventorchestr8/screens/my_events_screen.dart';
import 'package:eventorchestr8/widgets/profile_icon.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late SharedPreferencesProvider sp;

  @override
  void initState(){
    sp = SharedPreferencesProvider();
    super.initState();
  } 

  

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

  final List<Widget> _widgetOptions = <Widget>[
    ExploreScreen(),
    MyCommunitiesScreen(),
    MyEventsScreen(),
  ];

  final List<AppBar> _appBarOptions = <AppBar>[
    //ExploreScreen.appBar(),
    AppBar(
      toolbarHeight: 40,
      title: Builder(
        builder: (context) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hey ${sp.userDetails["name"]},",
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
              ProfileIcon(),
            ],
          );
        },
      ),
    ),
    AppBar(
      toolbarHeight: 40,
      title: Builder(
        builder: (BuildContext context) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Communities",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ProfileIcon(),
            ],
          );
        },
      ),
    ),
    AppBar(
      //toolbarHeight: 40,
      title: Builder(
        builder: (BuildContext context) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "My Events",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ProfileIcon(),
            ],
          );
        },
      ),
    ),
  ];

    return FutureBuilder<void>(
      future: sp.getData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error fetching profile data"));
          }
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
      },
    );
  }
}
