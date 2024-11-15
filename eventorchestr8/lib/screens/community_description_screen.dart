import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../widgets/rounded_button.dart';

class CommunityDescriptionScreen extends StatefulWidget {
  const CommunityDescriptionScreen({super.key, required this.community});

  final Map<String, dynamic> community;

  @override
  State<CommunityDescriptionScreen> createState() =>
      _CommunityDescriptionScreenState();
}

class _CommunityDescriptionScreenState
    extends State<CommunityDescriptionScreen> {
  bool _isJoined = false; // Track if the user has joined
  late String currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId =
        FirebaseAuth.instance.currentUser!.uid; // Get the current user's UID
    _checkIfUserJoined();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkIfUserJoined(); // Recheck if the user has joined every time the screen is rebuilt
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check if the user is already a member
  void _checkIfUserJoined() async {
    try {
      QuerySnapshot communitySnapshot = await _firestore
          .collection('communities')
          .where('name',
              isEqualTo: widget.community['name']) // Fetch community by name
          .limit(1) // Assuming 'name' is unique
          .get();

      if (communitySnapshot.docs.isNotEmpty) {
        DocumentSnapshot communityDoc = communitySnapshot.docs.first;

        // Check if the user is in the 'joined_by' field
        if (communityDoc['joined_by'] != null &&
            communityDoc['joined_by'].contains(currentUserId)) {
          setState(() {
            _isJoined = true;
          });
        } else {
          setState(() {
            _isJoined = false;
          });
        }
      }
    } catch (e) {
      // Handle any errors that might occur during the query
      print("Error fetching community: $e");
    }
  }

  // Function to handle Join Community
  void _joinCommunity() async {
    setState(() {
      _isJoined = true;
    });

    try {
      QuerySnapshot communitySnapshot = await _firestore
          .collection('communities')
          .where('name', isEqualTo: widget.community['name'])
          .limit(1)
          .get();

      if (communitySnapshot.docs.isNotEmpty) {
        DocumentReference communityDoc = communitySnapshot.docs.first.reference;

        await communityDoc.update({
          'members': FieldValue.increment(1),
          'joined_by': FieldValue.arrayUnion([currentUserId]),
        });

        setState(() {
          widget.community['members']++;
        });

        // Show a snackbar confirming the user has joined
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You have joined the community!'),
            duration: Duration(seconds: 2),
          ),
        );

        // Pop the screen and refresh the Explore screen
        Navigator.pop(
            context, true); // Passing `true` to indicate that the user joined
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error joining community: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _leaveCommunity() async {
    setState(() {
      _isJoined = false;
    });

    try {
      QuerySnapshot communitySnapshot = await _firestore
          .collection('communities')
          .where('name', isEqualTo: widget.community['name'])
          .limit(1)
          .get();

      if (communitySnapshot.docs.isNotEmpty) {
        DocumentReference communityDoc = communitySnapshot.docs.first.reference;

        await communityDoc.update({
          'members': FieldValue.increment(-1),
          'joined_by': FieldValue.arrayRemove([currentUserId]),
        });

        setState(() {
          widget.community['members']--;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You have left the community!'),
            duration: Duration(seconds: 2),
          ),
        );

        // Pop the screen and refresh the Explore screen
        Navigator.pop(
            context, false); // Passing `false` to indicate that the user left
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error leaving community: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            bottom: MediaQuery.of(context).size.height * 0.4,
            child: FadeInImage.assetNetwork(
              placeholder: 'assets/images/transparent_image.png',
              image: widget.community['imageUrl'],
              fit: BoxFit.fill,
            ),
          ),
          // Back Button
          SafeArea(
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          // Draggable Scrollable Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.6,
            maxChildSize: 0.7,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            height: 5,
                            width: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          widget.community["name"],
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.community["tagline"],
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Members",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.group,
                                color: Theme.of(context).colorScheme.primary),
                            SizedBox(width: 8),
                            Text(
                              '${widget.community["members"]} People have joined',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          widget.community["description"],
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Key tags",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Wrap(
                          spacing: 8.0,
                          children: (widget.community["tags"] as List)
                              .map((tag) => Chip(
                                    label: Text(tag),
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.2),
                                  ))
                              .toList(),
                        ),
                        SizedBox(height: 80),
                        // Conditionally show Join/Leave or View Community button
                        Center(
                          child: widget.community['created_by'] == currentUserId
                              ? RoundedButton(
                                  onPressed: () {
                                    // Navigate to view community
                                  },
                                  child: Text('View Community'),
                                )
                              : _isJoined
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        RoundedButton(
                                          onPressed: () {
                                            // Navigate to view community
                                          },
                                          child: Text('View Community'),
                                        ),
                                        SizedBox(
                                          width: 25,
                                        ),
                                        RoundedButton(
                                          onPressed: _leaveCommunity,
                                          child: Text('Leave Community'),
                                        ),
                                      ],
                                    )
                                  : RoundedButton(
                                      onPressed: _joinCommunity,
                                      child: Text('Join Community'),
                                    ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
