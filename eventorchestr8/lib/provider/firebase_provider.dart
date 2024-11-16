import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventorchestr8/utils/utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class FirebaseProvider extends ChangeNotifier {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  void updateDocument(
      BuildContext context, String uid, String name, int age) async {
    DocumentReference documentReference =
        _firebaseFirestore.collection('user_details').doc(uid);

    // Data to update
    Map<String, dynamic> data = {
      'name': name, // Field to update
      'age': age // Another field to update
    };

    try {
      await documentReference.update(data);
      showSnackBar(context, 'Successfully updated!');
    } catch (e) {
      showSnackBar(context, 'Error updating document: $e');
    }
  }

  Future<String> replaceProfileImage(
      BuildContext context, String uid, File newFile) async {
    Reference fileRef = _firebaseStorage.ref().child("profilePicture/$uid");
    try {
      await fileRef.delete();
    } catch (e) {
      print('Error deleting old file (it might not exist): $e');
    }
    UploadTask uploadTask =
        _firebaseStorage.ref().child("profilePicture/$uid").putFile(newFile);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl =
        await snapshot.ref.getDownloadURL().then((newUrl) async {
      DocumentReference documentReference =
          _firebaseFirestore.collection('user_details').doc(uid);

      Map<String, dynamic> data = {
        'profilePicture': newUrl,
      };

      try {
        await documentReference.update(data);
        showSnackBar(context, 'Successfully updated!');
      } catch (e) {
        showSnackBar(context, 'Error updating document: $e');
      }
      return newUrl;
    });

    return downloadUrl;
  }
}
