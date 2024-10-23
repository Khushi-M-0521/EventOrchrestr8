import 'package:eventorchestr8/widgets/rounded_button.dart';
import 'package:flutter/material.dart';

class CommunityDescriptionScreen extends StatefulWidget {
  const CommunityDescriptionScreen({super.key,required this.community});

  final Map<String,dynamic> community;

  @override
  State<CommunityDescriptionScreen> createState() => _CommunityDescriptionScreenState();
}

class _CommunityDescriptionScreenState extends State<CommunityDescriptionScreen> {
 
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            bottom: MediaQuery.of(context).size.height * 0.4,
            child: FadeInImage.assetNetwork(
              placeholder: 'assets/images/transparent_image.png',
              image: widget.community['imageUrl'], // Replace with your actual image URL
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
            initialChildSize: 0.6, // Minimum height
            minChildSize: 0.6,
            maxChildSize: 0.7, // Maximum height
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
                            Icon(Icons.group, color: Theme.of(context).colorScheme.primary),
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
                          children: (widget.community["tags"] as List).map((tag) => Chip(
                            label: Text(tag),
                            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          )).toList(),
                        ),
                        SizedBox(height: 16),
                        Center(
                          child: RoundedButton(
                            onPressed: () {
                              // Join action
                            },
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