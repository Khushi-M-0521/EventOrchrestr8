import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventorchestr8/utils/utils.dart';
import 'package:flutter/material.dart';

class EventListTile extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String location;
  final int peopleRegistered;
  final dynamic dateTime;

  const EventListTile({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.peopleRegistered,
    required this.dateTime,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: FadeInImage(
            placeholder: AssetImage('assets/images/transparent_image.png'),
            image: imageUrl != "" 
                ? NetworkImage(imageUrl)
                : AssetImage('assets/images/transparent_image.png'),
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              location,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            Row(
              children: [
                Icon(
                  Icons.group,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 4),
                Text(
                  '$peopleRegistered',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.all(5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                dateTime.runtimeType == Timestamp
                    ? formattedDay2(dateTime)
                    : formattedDay(dateTime),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Text(
                (dateTime.runtimeType == Timestamp
                        ? formattedMonth2(dateTime)
                        : formattedMonth(dateTime)) +
                    (dateTime.runtimeType == Timestamp
                        ? formattedYear2(dateTime)
                        : formattedYear(dateTime)),
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
