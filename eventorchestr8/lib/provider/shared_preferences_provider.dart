import 'dart:convert';
import 'dart:io';
import 'package:eventorchestr8/provider/firebase_provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesProvider extends ChangeNotifier {
  static Map<String, dynamic> _userCredential = {};
  Map<String, dynamic> get userCredential => _userCredential;

  static Map<String, dynamic> _userDetails = {};
  Map<String, dynamic> get userDetails => _userDetails;

  Future<void>? getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userCredentialJson = prefs.getString('user_credential_model')!;
    String userDetailJson = prefs.getString('user_detail_model')!;

    _userCredential = jsonDecode(userCredentialJson);
    _userDetails = jsonDecode(userDetailJson);
  }

  Map<String, dynamic> getUserData() {
    return {
      'profilePicture': userDetails['profilePicture'],
      'name': userDetails['name'],
      'age': userDetails['age'],
      'phoneNumber': userCredential['phoneNumber']
    };
  }

  Future<void> updateUserData(BuildContext context,
      {String? name, int? age, File? image}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    FirebaseProvider fp = FirebaseProvider();
    if (name != null && age != null) {
      _userDetails["name"] = name;
      _userDetails['age'] = age;
      await prefs.setString('user_detail_model', jsonEncode(userDetails));
      fp.updateDocument(context, _userDetails['uid'], name, age);
    }
    image != null
        ? await fp
            .replaceProfileImage(context, _userDetails['uid'], image)
            .then((newUrl) async {
            _userDetails['profilePicture'] = newUrl;
            await prefs.setString('user_detail_model', jsonEncode(userDetails));
            print(_userDetails['profilePicture']);
          })
        : null;
    notifyListeners();
  }
}
