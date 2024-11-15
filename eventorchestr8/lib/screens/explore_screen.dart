import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventorchestr8/screens/community_description_screen.dart';
import 'package:eventorchestr8/screens/event_description.dart';
import 'package:eventorchestr8/widgets/community_list_card.dart';
import 'package:eventorchestr8/widgets/event_list_card.dart';
import 'package:eventorchestr8/widgets/popular_commuty_card.dart';
import 'package:eventorchestr8/widgets/popular_events.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constants/example_events.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.8);
  final PageController _mainPageController = PageController(initialPage: 0);
  int _currentPage = 0;
  int _selectedPage = 0;
  late Timer timer;
  List<Map<String, dynamic>> allCommunities = [];

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (_pageController.hasClients) {
        if (_currentPage < 4) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    });
    _fetchCommunities();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _mainPageController.dispose();
    timer.cancel();
    super.dispose();
  }

  Future<void> _fetchCommunities() async {
    try {
      // Fetch communities from Firestore
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('communities').get();

      // Extract community data from Firestore documents
      setState(() {
        allCommunities = snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      print("Error fetching communities: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton.icon(
                icon: Icon(
                  Icons.group,
                  color: _selectedPage == 0
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).colorScheme.secondaryContainer,
                ),
                label: Text(
                  "Communities",
                  style: TextStyle(
                    color: _selectedPage == 0
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).colorScheme.secondaryContainer,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _selectedPage = 0;
                  });
                  _mainPageController.jumpToPage(0);
                },
              ),
              TextButton.icon(
                icon: Icon(
                  Icons.event,
                  color: _selectedPage == 1
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).colorScheme.secondaryContainer,
                ),
                label: Text(
                  "Events",
                  style: TextStyle(
                    color: _selectedPage == 1
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).colorScheme.secondaryContainer,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _selectedPage = 1;
                  });
                  _mainPageController.jumpToPage(1);
                },
              ),
            ],
          ),
        ),
        toolbarHeight: 40,
      ),
      body: PageView(
        controller: _mainPageController,
        onPageChanged: (index) {
          setState(() {
            _selectedPage = index;
          });
        },
        children: [
          _buildCommunityPage(),
          _buildEventPage(),
        ],
      ),
    );
  }

  Widget _buildCommunityPage() {
    // Sorting communities by number of members
    List<Map<String, dynamic>> popular = List.from(allCommunities);
    popular.sort(
      (a, b) => (b["members"] as int).compareTo(a["members"] as int),
    );

    return _buildListSection(
      title: "Popular Community",
      popular: popular,
      list: allCommunities,
      isCommunity: true,
    );
  }

  Widget _buildEventPage() {
    List<Map<String, Object>> popular = exampleEvents;
    popular.sort(
      (a, b) => (b["peopleRegistered"] as int)
          .compareTo(a["peopleRegistered"] as int),
    );

    return _buildListSection(
      title: "Popular Event",
      popular: popular,
      list: exampleEvents,
      isCommunity: false,
    );
  }

  Widget _buildListSection({
    required String title,
    required List<Map<String, dynamic>> popular,
    required List<Map<String, dynamic>> list,
    required bool isCommunity,
  }) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            height: 150,
            child: PageView.builder(
              controller: _pageController,
              itemCount: popular.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => isCommunity
                            ? CommunityDescriptionScreen(
                                community: popular[index],
                              )
                            : EventDescriptionScreen(
                                event: popular[index],
                                isRegistered: false,
                              ),
                      ));
                    },
                    child: isCommunity
                        ? PopularCommunityCard(
                            imageUrl: popular[index]["imageUrl"] as String,
                            name: popular[index]["name"] as String,
                            tagline: popular[index]["tagline"] as String,
                            membersCount: popular[index]["members"] as int,
                          )
                        : PopularEventCard(
                            imageUrl: popular[index]["imageUrl"] as String,
                            title: popular[index]["title"] as String,
                            location: popular[index]["location"] as String,
                            peopleRegistered:
                                popular[index]["peopleRegistered"] as int,
                            dateTime: popular[index]["dateTime"] as int,
                          ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20),
          Text(
            "All ${isCommunity ? "Communities" : "Events"}",
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: list.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => isCommunity
                        ? CommunityDescriptionScreen(
                            community: list[index],
                          )
                        : EventDescriptionScreen(
                            event: list[index],
                            isRegistered: false,
                          ),
                  ));
                },
                child: isCommunity
                    ? CommunityListTile(
                        imageUrl: list[index]["imageUrl"] as String,
                        name: list[index]["name"] as String,
                        tagline: list[index]["tagline"] as String,
                        membersCount: list[index]["members"] as int,
                      )
                    : EventListTile(
                        imageUrl: list[index]["imageUrl"] as String,
                        title: list[index]["title"] as String,
                        location: list[index]["location"] as String,
                        peopleRegistered:
                            list[index]["peopleRegistered"] as int,
                        dateTime: list[index]["dateTime"] as int,
                      ),
              );
            },
          ),
        ],
      ),
    );
  }
}
