import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

void showSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(content),
  ));
}

Future<File?> pickImage(BuildContext context) async{
  File? image;
  try{
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if(pickedImage != null){
      image = File(pickedImage.path);
    }
  }catch(e) {
    showSnackBar(context, e.toString());
    print(e.toString());
  }

  return image;
}

String formattedDate(int dateTime) => DateFormat('d MMM, yyyy').format(DateTime.fromMicrosecondsSinceEpoch(dateTime));
String formattedTime(int dateTime) => DateFormat('h:mm a').format(DateTime.fromMicrosecondsSinceEpoch(dateTime));
String formattedDay(int dateTime) => DateFormat('d').format(DateTime.fromMicrosecondsSinceEpoch(dateTime));
String formattedMonth(int dateTime) => DateFormat('MMM').format(DateTime.fromMicrosecondsSinceEpoch(dateTime));
String formattedYear(int dateTime) => DateTime.now().year != DateTime.fromMicrosecondsSinceEpoch(dateTime).year
        ? ', ${DateTime.fromMicrosecondsSinceEpoch(dateTime).year}'
        : '';