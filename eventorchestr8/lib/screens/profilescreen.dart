import 'dart:async';
import 'dart:io';

import 'package:eventorchestr8/provider/auth_provider.dart';
import 'package:eventorchestr8/provider/shared_preferences_provider.dart';
import 'package:eventorchestr8/screens/login_screen.dart';
import 'package:eventorchestr8/utils/utils.dart';
import 'package:flutter/material.dart';
import '../widgets/rounded_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEditMode = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  File? image = null;

  void selectImage() async {
    image = await pickImage(context);
    if (image != null) {
      SharedPreferencesProvider sp = SharedPreferencesProvider();
      await sp.updateUserData(context, image: image).then((_) {
        setState(() {});
      });
    }
  }

  Future<void> signOut(BuildContext context) async {
    AuthProvider ap = AuthProvider();
    ap.signOut();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    SharedPreferencesProvider sp = SharedPreferencesProvider();
    Map<String, dynamic> userData = sp.getUserData();
    String profileImage = userData['profilePicture'] ?? '';
    String name = userData['name'];
    int age = userData['age'];
    String? phoneNumber =
        userData['phoneNumber'] == '' ? null : userData['phoneNumber'];
    String? email = userData['email'];

    // Set initial values for editing
    nameController.text = name;
    ageController.text = age.toString();
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
              if (nameController.text.length < 3) {
                showSnackBar(context, "Name must have atleast 3 characters");
              } else if (int.parse(ageController.text) < 18) {
                showSnackBar(context, "Must have an age of 18");
              } else if (isEditMode) {
                // Save the updated data
                sp.updateUserData(context,
                    name: nameController.text,
                    age: int.tryParse(ageController.text)!,
                    image: image);
              }
              setState(() {
                isEditMode = !isEditMode;
              });
            },
          ),
        ],
      ),
      body: Column(
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
                      : const AssetImage('assets/images/default_profile.jpg')
                          as ImageProvider,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () {
                      selectImage();
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
          // Phone Number (Display-only, not editable)
          if (phoneNumber != null) ...[
            const SizedBox(height: 8),
            Text(
              "Phone Number: $phoneNumber",
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
          // Email (Display-only, not editable)
          if (email != null) ...[
            const SizedBox(height: 8),
            Text(
              "Email: $email",
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: SizedBox(
              width: double.infinity,
              child: RoundedButton(
                onPressed: () {
                  signOut(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text("SIGN OUT"),
                    SizedBox(
                      width: 10,
                    ),
                    Icon(Icons.logout),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}