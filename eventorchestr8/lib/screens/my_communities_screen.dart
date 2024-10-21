import 'package:eventorchestr8/constants/example_communites.dart';
import 'package:eventorchestr8/widgets/community_list_card.dart';
import 'package:flutter/material.dart';

class MyCommunitiesScreen extends StatefulWidget {
  const MyCommunitiesScreen({super.key});

  @override
  State<MyCommunitiesScreen> createState() => _MyCommunitiesScreenState();
}

class _MyCommunitiesScreenState extends State<MyCommunitiesScreen> {
  bool isJoined = true;

  @override
  Widget build(BuildContext context) {
    List<Map<String,Object>> list=[];
    if(!isJoined){
      list=exampleCommunities.sublist(0,4);
    }else{
      list=exampleCommunities.sublist(4);
    }

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
                    isJoined = true;
                  });
                },
                child: Text(
                  "Joined Communities",
                  style: TextStyle(
                      color: isJoined
                          ? null
                          : Theme.of(context).colorScheme.secondaryContainer),
                ),
              ),
              TextButton(
                  onPressed: () {
                    setState(() {
                      isJoined = false;
                    });
                  },
                  child: Text(
                    "Owned Communities",
                    style: TextStyle(
                      color: !isJoined
                          ? null
                          : Theme.of(context).colorScheme.secondaryContainer,
                    ),
                  )),
            ],
          ),
        ),
        toolbarHeight: 40,
      ),
      floatingActionButton: isJoined
          ? null
          : FloatingActionButton(
              onPressed: () {},
              child: Icon(Icons.add),
            ),
      floatingActionButtonLocation: isJoined?null:FloatingActionButtonLocation.endFloat,
      body: ListView.builder(
              itemCount:
                  list.length, // Replace with the actual number of communities or events
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: (){},
                  child: CommunityListTile(
                          imageUrl: list[index]["imageUrl"] as String,
                          name: list[index]["name"] as String,
                          tagline: list[index]["tagline"] as String,
                          membersCount: list[index]["members"] as int,
                        ),
                );
              },
            ),
    );
  }
}
