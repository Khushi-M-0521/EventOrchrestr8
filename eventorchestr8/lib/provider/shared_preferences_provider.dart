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

  String get currentUid => _userDetails["uid"];
  
  bool _isLoading=false;
  bool get isLoading => _isLoading;
  // Map<String, String> userDetails = {
  //   'profilePicture': '',
  // };

  void updateProfilePicture(String newUrl) {
    userDetails['profilePicture'] = newUrl;
    notifyListeners();
  }

  Future<void>? getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userCredentialJson = prefs.getString('user_credential_model')!;
    String userDetailJson = prefs.getString('user_detail_model')!;
    print(userDetailJson);
    _userCredential = jsonDecode(userCredentialJson);
    _userDetails = jsonDecode(userDetailJson);
  }

  Map<String, dynamic> getUserData() {
    return {
      'profilePicture': userDetails['profilePicture'],
      'name': userDetails['name'],
      'age': userDetails['age'],
      'phoneNumber': userCredential['phoneNumber'],
      'email':userCredential['email']
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

  Future<void> createCommunity(String community_id) async {
    _isLoading=true;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<dynamic> owned_communites=_userDetails["owned_communities"]??[];
    owned_communites.add(community_id);
    _userDetails["owned_communities"]=owned_communites;
    await prefs.setString('user_detail_model', jsonEncode(userDetails));
    _isLoading=false;
    notifyListeners();
  }

  Future<void> createEvent(String event_id) async {
    _isLoading=true;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<dynamic> events=_userDetails["events"]??[];
    events.add(event_id);
    _userDetails["events"]=events;
    await prefs.setString('user_detail_model', jsonEncode(userDetails));
    _isLoading=false;
    notifyListeners();
  }
}
