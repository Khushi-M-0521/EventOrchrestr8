import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventorchestr8/provider/firebase_provider.dart';
import 'package:eventorchestr8/provider/shared_preferences_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:eventorchestr8/widgets/community_list_card.dart';
import 'package:eventorchestr8/screens/create_community.dart';
import 'package:eventorchestr8/screens/specific_community_screen.dart';

class MyCommunitiesScreen extends StatefulWidget {
  const MyCommunitiesScreen({super.key});

  @override
  State<MyCommunitiesScreen> createState() => _MyCommunitiesScreenState();
}

class _MyCommunitiesScreenState extends State<MyCommunitiesScreen> {
  List<Map<String, dynamic>> ownedCommunities = [];
  List<Map<String, dynamic>> joinedCommunities = [];
  final PageController _pageController = PageController(initialPage: 0);
  int _selectedPage = 0;

  @override
  void initState() {
    super.initState();
    _fetchJoinedCommunities();
    _fetchOwnedCommunities();
  }

  Future<void> _fetchJoinedCommunities() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;

      try {
        // Query Firestore to find communities joined by the user
        final QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('communities')
            .where('joined_by', arrayContains: userId)
            .get();

        setState(() {
          joinedCommunities = snapshot.docs.map((doc) {
            return doc.data() as Map<String, dynamic>;
          }).toList();
        });
      } catch (e) {
        print("Error fetching joined communities: $e");
      }
    }
  }

  Future<void> _fetchOwnedCommunities() async {
    SharedPreferencesProvider sp = SharedPreferencesProvider();
    FirebaseProvider fp = FirebaseProvider();
    print(sp.userDetails);
    print("really "+sp.userDetails["owned_communities"].toString());
    if (sp.userDetails["owned_communities"] != null) {
      await fp.fetchOwnedCommunities(sp.userDetails["owned_communities"] as List<dynamic>).then((communities)=> setState(() {
            ownedCommunities = communities;
          }));// Print each community after it is fetched (for debugging) 
      
    }

    // User? user = FirebaseAuth.instance.currentUser;
    // if (user != null) {
    //   String userId = user.uid;
    //   print(userId);

    //   final QuerySnapshot snapshot = await FirebaseFirestore.instance
    //       .collection('communities')
    //       .where('created_by', isEqualTo: userId)
    //       .get();

    //   setState(() {
    //     ownedCommunities = snapshot.docs.map((doc) {
    //       return doc.data() as Map<String, dynamic>;
    //     }).toList();
    //     print(ownedCommunities);
    //   });
    // }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _fetchOwnedCommunities();
          });
        },
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedPage = index;
            });
          },
          children: [
            _buildCommunityList(joinedCommunities, false),
            _buildCommunityList(ownedCommunities, true),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityList(
      List<Map<String, dynamic>> communities, bool isOwner) {
    return ListView.builder(
      itemCount: communities.length,
      itemBuilder: (context, index) {
        print(communities[index]);
        print(
          communities[index]["imageUrl"] ?? '',
        );
        return InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => CommunityScreen(
                      community: communities[index],
                      isOwner: isOwner,
                    )));
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
