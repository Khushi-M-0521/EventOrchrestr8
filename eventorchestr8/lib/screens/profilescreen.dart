import 'dart:convert';
import 'dart:io';
import 'package:eventorchestr8/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/rounded_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEditMode = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  String profileImagePath = '';

  Future<Map<String, dynamic>> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userCredentialJson = prefs.getString('user_credential_model');
    String? userDetailJson = prefs.getString('user_detail_model');

    if (userCredentialJson != null && userDetailJson != null) {
      Map<String, dynamic> userCredential = jsonDecode(userCredentialJson);
      Map<String, dynamic> userDetails = jsonDecode(userDetailJson);

      String loginMethod =
          userCredential.containsKey('email') ? 'email' : 'phone';

      return {
        'profilePicture': userDetails['profilePicture'],
        'name': userDetails['name'],
        'age': userDetails['age'],
        'loginMethod': loginMethod,
        'loginValue': loginMethod == 'email'
            ? userCredential['email']
            : userCredential['phoneNumber']
      };
    } else {
      return {
        'profilePicture': '',
        'name': 'No Name',
        'age': 0,
        'loginMethod': 'none',
        'loginValue': 'No Login Information'
      };
    }
  }

  Future<void> _pickProfileImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        profileImagePath = image.path;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      Map<String, dynamic> userDetails =
          jsonDecode(prefs.getString('user_detail_model') ?? '{}');
      userDetails['profilePicture'] = image.path;
      await prefs.setString('user_detail_model', jsonEncode(userDetails));
    }
  }

  Future<void> signOut(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_credential_model');
    await prefs.remove('user_detail_model');

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> saveUserData(String name, int age) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> userDetails =
        jsonDecode(prefs.getString('user_detail_model') ?? '{}');

    userDetails['name'] = name;
    userDetails['age'] = age;

    await prefs.setString('user_detail_model', jsonEncode(userDetails));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Profile",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(isEditMode ? Icons.check : Icons.edit),
            onPressed: () {
              if (isEditMode) {
                saveUserData(
                  nameController.text,
                  int.tryParse(ageController.text) ?? 0,
                );
              }
              setState(() {
                isEditMode = !isEditMode;
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error fetching profile data"));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("Profile data not found"));
          }

          Map<String, dynamic> userData = snapshot.data!;
          String profileImage = profileImagePath.isNotEmpty
              ? profileImagePath
              : (userData['profilePicture'] ?? '');
          String name = userData['name'] ?? 'No Name';
          int age = userData['age'] ?? 0;
          String loginMethod = userData['loginMethod'] ?? 'none';
          String loginValue = userData['loginValue'] ?? 'No Login Information';

          nameController.text = name;
          ageController.text = age.toString();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 80,
                      backgroundImage: profileImage.isNotEmpty
                          ? FileImage(File(profileImage))
                          : const AssetImage(
                                  'assets/images/default_profile.jpg')
                              as ImageProvider,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: _pickProfileImage,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 20,
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              isEditMode
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Name'),
                      ),
                    )
                  : Text(
                      name,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
              const SizedBox(height: 8),
              isEditMode
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        controller: ageController,
                        decoration: const InputDecoration(labelText: 'Age'),
                        keyboardType: TextInputType.number,
                      ),
                    )
                  : Text("Age: $age", style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text(
                "${loginMethod == 'email' ? 'Email' : 'Phone Number'}: $loginValue",
                style: const TextStyle(fontSize: 16),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: RoundedButton(
                  onPressed: () => signOut(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [Text("SIGN OUT"), Icon(Icons.logout)],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
