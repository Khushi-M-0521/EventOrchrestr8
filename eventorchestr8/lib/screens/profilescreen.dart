import 'dart:convert';
import 'package:eventorchestr8/screens/login_screen.dart';
import 'package:flutter/material.dart';
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

  Future<Map<String, dynamic>> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userCredentialJson = prefs.getString('user_credential_model');
    String? userDetailJson = prefs.getString('user_detail_model');

    if (userCredentialJson != null && userDetailJson != null) {
      Map<String, dynamic> userCredential = jsonDecode(userCredentialJson);
      Map<String, dynamic> userDetails = jsonDecode(userDetailJson);

      return {
        'profilePicture': userDetails['profilePicture'],
        'name': userDetails['name'],
        'age': userDetails['age'],
        'phoneNumber': userCredential['phoneNumber']
      };
    } else {
      return {
        'profilePicture': '',
        'name': 'No Name',
        'age': 0,
        'phoneNumber': 'No Phone Number'
      };
    }
  }

  Future<void> signOut(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> saveUserData(String name, int age) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> userDetails = {
      'profilePicture': '', // Update this if profile picture is updated
      'name': name,
      'age': age,
    };
    await prefs.setString('user_detail_model', jsonEncode(userDetails));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Profile",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(isEditMode ? Icons.check : Icons.edit),
            onPressed: () {
              if (isEditMode) {
                // Save the updated data
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
        builder: (BuildContext context,
            AsyncSnapshot<Map<String, dynamic>> snapshot) {
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
          print(userData);
          String profileImage = userData['profilePicture'] ?? '';
          String name = userData['name'] ?? 'No Name';
          int age = userData['age'] ?? 0;
          String phoneNumber = userData['phoneNumber'] ?? 'No Phone Number';

          // Set initial values for editing
          nameController.text = name;
          ageController.text = age.toString();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              // Stack for Profile Image and Edit Icon
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 80,
                      backgroundImage: profileImage.isNotEmpty
                          ? NetworkImage(profileImage)
                          : const AssetImage(
                                  'assets/images/default_profile.jpg')
                              as ImageProvider,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () {
                          // Handle profile picture edit (optional)
                          print("Edit profile picture tapped");
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 20,
                          child: Icon(
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
              // Name
              isEditMode
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                        ),
                      ),
                    )
                  : Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              const SizedBox(height: 8),
              // Age
              isEditMode
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        controller: ageController,
                        decoration: const InputDecoration(
                          labelText: 'Age',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    )
                  : Text(
                      "Age: $age",
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
              const SizedBox(height: 8),
              // Phone Number (Display-only, not editable)
              Text(
                "Phone Number: $phoneNumber",
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: RoundedButton(
                  onPressed: () {
                    signOut(context);
                  },
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
