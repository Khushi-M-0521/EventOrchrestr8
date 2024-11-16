import 'package:flutter/material.dart';

class PopularCommunityCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String tagline;
  final int membersCount;

  const PopularCommunityCard({super.key, 
    required this.imageUrl,
    required this.name,
    required this.tagline,
    required this.membersCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      width: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: FadeInImage(
              placeholder: AssetImage("./assets/images/transparent_image.png"),
              image: NetworkImage(imageUrl),
              fit: BoxFit.fill,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    backgroundColor: Colors.black45,
                  ),
                ),
                Text(
                  tagline,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    backgroundColor: Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: Row(
              children: [
                Icon(Icons.group,color: Colors.white,size: 20,),
                Text(
                  '$membersCount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    backgroundColor: Colors.black45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

