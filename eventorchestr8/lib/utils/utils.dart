import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

void showSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(content),
  ));
}

Future<File?> pickImage(BuildContext context) async {
  File? image;
  try {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      image = File(pickedImage.path);
    }
  } catch (e) {
    showSnackBar(context, e.toString());
    print(e.toString());
  }

  return image;
}

String formattedDate(int dateTime) => DateFormat('d MMM, yyyy')
    .format(DateTime.fromMicrosecondsSinceEpoch(dateTime));
String formattedTime(int dateTime) =>
    DateFormat('h:mm a').format(DateTime.fromMicrosecondsSinceEpoch(dateTime));
// String formattedDay(int dateTime) =>
//     DateFormat('d').format(DateTime.fromMicrosecondsSinceEpoch(dateTime));
// String formattedMonth(int dateTime) =>
//     DateFormat('MMM').format(DateTime.fromMicrosecondsSinceEpoch(dateTime));
// String formattedYear(int dateTime) =>
//     DateTime.now().year != DateTime.fromMicrosecondsSinceEpoch(dateTime).year
//         ? ', ${DateTime.fromMicrosecondsSinceEpoch(dateTime).year}'
//         : '';
// Function to format the day
String formattedDay(Timestamp dateTime) =>
    DateFormat('d').format(dateTime.toDate());

// Function to format the month
String formattedMonth(Timestamp dateTime) =>
    DateFormat('MMM').format(dateTime.toDate());

// Function to format the year (optional display for different years)
String formattedYear(Timestamp dateTime) {
  DateTime date = dateTime.toDate();
  return DateTime.now().year != date.year ? ', ${date.year}' : '';
}

String formatDuration(Map<String, int> duration) {
  int days = duration['days'] ?? 0;
  int hours = duration['hours'] ?? 0;
  int minutes = duration['minutes'] ?? 0;
  return '${days > 0 ? '${days}d' : ''} ${hours > 0 ? '${hours}h ' : ''} ${minutes > 0 ? '${minutes}m' : ''}';
}

Map<String, int> _castToIntMap(dynamic duration) {
  if (duration is Map) {
    return duration.map(
        (key, value) => MapEntry(key, int.tryParse(value.toString()) ?? 0));
  }
  return {};
}

String formattedDate2(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate(); // Convert to DateTime
  return DateFormat('MMMM dd, yyyy')
      .format(dateTime); // Format as "November 30, 2024"
}

String formattedTime2(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate(); // Convert to DateTime
  return DateFormat('hh:mm a').format(dateTime); // Format as "11:30 AM"
}

String formatDuration2(Map<String, int> duration) {
  int days = duration['days'] ?? 0;
  int hours = duration['hours'] ?? 0; // Extract hours
  int minutes = duration['minutes'] ?? 0; // Extract minutes (if applicable)
  return '${days}d ${hours}h ${minutes}m'; // e.g., "1h 30m"
}
