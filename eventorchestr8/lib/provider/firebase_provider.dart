import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventorchestr8/provider/shared_preferences_provider.dart';
import 'package:eventorchestr8/utils/utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class FirebaseProvider extends ChangeNotifier {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  bool _isLoading=false;
  bool get isLoading => _isLoading;

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

Future<String> uploadImageToStorage(String collection, File image) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageRef = _firebaseStorage.ref().child('${collection}_images/$fileName');

    // Upload the image to Firebase Storage
    UploadTask uploadTask = storageRef.putFile(image);

    // Wait for the upload to complete
    TaskSnapshot snapshot = await uploadTask;

    // Get the image URL after upload
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
}

  Future<List<Map<String, dynamic>>> fetchEvents() async {
    try {
      // Fetch communities from Firestore
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('events').orderBy("postTime", descending: true).get();

      // Extract community data from Firestore documents
      return snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
    } catch (e) {
      print("Error fetching events: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchCommunities() async {
    try {
      // Fetch communities from Firestore
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('communities').orderBy("created_at",descending: true).get();

      // Extract community data from Firestore documents
      return snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
    } catch (e) {
      print("Error fetching communities: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchPopularEvents() async {
    try {
      // Fetch communities from Firestore
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('events').orderBy("peopleRegistered", descending: true).limit(5).get();

      // Extract community data from Firestore documents
      return snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
    } catch (e) {
      print("Error fetching events: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchPopularCommunities() async {
    try {
      // Fetch communities from Firestore
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('communities').orderBy("members",descending: true).limit(5).get();
      print(snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList());

      // Extract community data from Firestore documents
      return snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
    } catch (e) {
      print("Error fetching communities: $e");
      return [];
    }
  }

  Future<void> createCommunity(Map<String, dynamic> community) async {
    _isLoading=true;
    notifyListeners();
    String communityId='';
    await _firebaseFirestore.collection("communities").add(community).then((community){
      communityId=community.id;
      SharedPreferencesProvider sp=SharedPreferencesProvider();
      sp.createCommunity(communityId);
      print("1"+communityId);
    });
    print("2"+communityId);
    DocumentReference docRef= _firebaseFirestore.collection("user_details").doc(community["created_by"] as String);
    docRef.update({
      "owned_communities":FieldValue.arrayUnion([communityId])
    });

    _isLoading=false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> fetchCommunity(String communityId) async {
    DocumentReference docRef= await _firebaseFirestore.collection("communities").doc(communityId);
    docRef.get().then((doc){
      print(communityId);
      print(doc.data());
      return doc.data() as Map<String, dynamic>;
    });
    return {};
  }  
}
