import 'package:flutter/material.dart';

class CommunityListTile extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String tagline;
  final int membersCount;

  const CommunityListTile({super.key, 
    required this.imageUrl,
    required this.name,
    required this.tagline,
    required this.membersCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: FadeInImage.assetNetwork(
            placeholder: 'assets/images/transparent_image.png',
            image: imageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          tagline,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.group,
              color: Colors.grey[600],
              size: 20,
            ),
            SizedBox(height: 4.0),
            Text(
              '$membersCount',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
