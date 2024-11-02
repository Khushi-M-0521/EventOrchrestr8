import 'dart:async';

import 'package:eventorchestr8/constants/example_communites.dart';
import 'package:eventorchestr8/constants/example_events.dart';
import 'package:eventorchestr8/screens/community_description_screen.dart';
import 'package:eventorchestr8/screens/event_description.dart';
import 'package:eventorchestr8/widgets/community_list_card.dart';
import 'package:eventorchestr8/widgets/event_list_card.dart';
import 'package:eventorchestr8/widgets/popular_commuty_card.dart';
import 'package:eventorchestr8/widgets/popular_events.dart';
import 'package:flutter/material.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.8);
  int _currentPage = 0;
  bool isCommunity = true;

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 5), (Timer timer) {
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
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, Object>> popular = [];
    List<Map<String, Object>> list = [];

    if (isCommunity) {
      list = exampleCommunities;
      popular = exampleCommunities;
      popular.sort(
        (a, b) => (b["members"] as int).compareTo(a["members"] as int),
      );
    } else {
      list = exampleEvents;
      popular = exampleEvents;
      popular.sort(
        (a, b) => (b["peopleRegistered"] as int)
            .compareTo(a["peopleRegistered"] as int),
      );
    }
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
                  color: isCommunity
                      ? null
                      : Theme.of(context).colorScheme.secondaryContainer,
                ),
                label: Text(
                  "Communities",
                  style: TextStyle(
                    color: isCommunity
                        ? null
                        : Theme.of(context).colorScheme.secondaryContainer,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    isCommunity = true;
                  });
                },
              ),
              TextButton.icon(
                icon: Icon(Icons.event,color: !isCommunity?null:Theme.of(context).colorScheme.secondaryContainer,),
                label: Text("Events",style: TextStyle(color: !isCommunity?null:Theme.of(context).colorScheme.secondaryContainer,),),
                onPressed: () {
                  setState(() {
                    isCommunity = false;
                  });
                },
              ),
            ],
          ),
        ),
        toolbarHeight: 40,
      ),
      body: SingleChildScrollView(
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
                "Popuplar ${isCommunity ? "Community" : "Event"}",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              height: 150,
              child: PageView.builder(
                controller: _pageController,
                itemCount: 5, // Ensure at least 5 items for demo
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: InkWell(
                      onTap: () {Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
                    isCommunity?  CommunityDescriptionScreen(community: popular[index],):EventDescriptionScreen(event: popular[index],)));
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
            SizedBox(
              height: 20,
            ),
            Text(
              "All ${isCommunity ? "Communities" : "Events"}",
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            ListView.builder(
              physics:
                  NeverScrollableScrollPhysics(), // Prevent nested scrolling conflicts
              shrinkWrap: true,
              itemCount:
                  list.length, // Replace with the actual number of communities or events
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=> isCommunity? CommunityDescriptionScreen(community: list[index],):EventDescriptionScreen(event: list[index],)));
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
      ),
    );
  }
}
