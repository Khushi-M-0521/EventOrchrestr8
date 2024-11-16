import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:eventorchestr8/widgets/community_list_card.dart';
import 'package:eventorchestr8/screens/create_community.dart';
import 'package:eventorchestr8/screens/specific_community_screen.dart';

import '../constants/example_communites.dart';

class MyCommunitiesScreen extends StatefulWidget {
  const MyCommunitiesScreen({super.key});

  @override
  State<MyCommunitiesScreen> createState() => _MyCommunitiesScreenState();
}

class _MyCommunitiesScreenState extends State<MyCommunitiesScreen> {
  List<Map<String, dynamic>> ownedCommunities = [];
  PageController _pageController = PageController(initialPage: 0);
  int _selectedPage = 0;

  @override
  void initState() {
    super.initState();
    _fetchOwnedCommunities();
  }

  Future<void> _fetchOwnedCommunities() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;

      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('communities')
          .where('created_by', isEqualTo: userId)
          .get();

      setState(() {
        ownedCommunities = snapshot.docs.map((doc) {
          return doc.data() as Map<String, dynamic>;
        }).toList();
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> joinedCommunities =
        exampleCommunities.sublist(4);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedPage = 0;
                  });
                  _pageController.jumpToPage(0);
                },
                child: Text(
                  "Joined Communities",
                  style: TextStyle(
                    color: _selectedPage == 0
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).colorScheme.secondaryContainer,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedPage = 1;
                  });
                  _pageController.jumpToPage(1);
                },
                child: Text(
                  "Owned Communities",
                  style: TextStyle(
                    color: _selectedPage == 1
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).colorScheme.secondaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
        toolbarHeight: 40,
      ),
      floatingActionButton: _selectedPage == 1
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => CommunityForm()));
              },
              child: Icon(Icons.add),
            )
          : null,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedPage = index;
          });
        },
        children: [
          _buildCommunityList(joinedCommunities,false),
          _buildCommunityList(ownedCommunities,true),
        ],
      ),
    );
  }

  Widget _buildCommunityList(List<Map<String, dynamic>> communities, bool isOwner) {
    return ListView.builder(
      itemCount: communities.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => CommunityScreen(community: communities[index], isOwner: isOwner,)));
          },
          child: CommunityListTile(
            imageUrl: communities[index]["imageUrl"] ?? '',
            name: communities[index]["name"] ?? '',
            tagline: communities[index]["tagline"] ?? '',
            membersCount: communities[index]["members"] ?? 0,
          ),
        );
      },
    );
  }
}
