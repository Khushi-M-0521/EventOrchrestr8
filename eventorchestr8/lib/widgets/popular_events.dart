import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventorchestr8/utils/utils.dart';
import 'package:flutter/material.dart';

class PopularEventCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String location;
  final int peopleRegistered;
  final dynamic dateTime;

  const PopularEventCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.peopleRegistered,
    required this.dateTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      width: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.fill,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    dateTime.runtimeType ==Timestamp?
                                        formattedDate2(
                                            dateTime):formattedDate(
                                            dateTime),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    dateTime.runtimeType ==Timestamp?
                                        formattedTime2(
                                            dateTime):formattedTime(
                                            dateTime),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    backgroundColor: Colors.black45,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      location,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        backgroundColor: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: Row(
              children: [
                Icon(
                  Icons.group,
                  color: Colors.white,
                  size: 16,
                ),
                SizedBox(width: 4),
                Text(
                  '$peopleRegistered',
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
