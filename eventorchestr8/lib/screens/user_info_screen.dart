import 'dart:io';

import 'package:eventorchestr8/models/user_credential.dart';
import 'package:eventorchestr8/models/user_details.dart';
import 'package:eventorchestr8/provider/auth_provider.dart';
import 'package:eventorchestr8/screens/home_screen.dart';
import 'package:eventorchestr8/utils/utils.dart';
import 'package:eventorchestr8/widgets/rounded_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  File? image;
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  Widget textfield(
      {required String hintText,
      required IconData icon,
      required TextInputType inputType,
      required TextEditingController controller,
      bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        obscureText: obscureText,
        decoration: InputDecoration(
          prefixIcon: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Icon(
              icon,
              size: 20,
              color: Colors.white,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.grey[300]!,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          alignLabelWithHint: true,
          border: InputBorder.none,
          fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          filled: true,
        ),
      ),
    );
  }

  void storeData() async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    UserCredentialModel userCredentialModel = UserCredentialModel(
      uid: "",
      createdAt: "",
      email: "",
      phoneNumber: "",
      password: passwordController.text.hashCode,
    );
    UserDetailModel userDetailModel = UserDetailModel(
      uid: "",
      name: nameController.text.trim(),
      profilePicture: "",
      age: int.parse(ageController.text),
    );
    if (image != null) {
      ap.saveUserCredentialDataToFirebase(
        context: context,
        userCredentialModel: userCredentialModel,
        onSuccess: () {
          //store data locally
          ap.saveUserDataToSP().then((value) => ap.setSignIn().then((value) =>
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => const HomeScreen()),
                  (route) => false)));
        },
        profilePicture: image,
        userDetailModel: userDetailModel,
      );
    }
  }

  void selectImage() async {
    image = await pickImage(context);
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    ageController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        Provider.of<AuthProvider>(context, listen: true).isLoading;
    return Scaffold(
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () => selectImage(),
                        child: image == null
                            ? CircleAvatar(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                radius: 50,
                                child: const Icon(
                                  Icons.account_circle,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              )
                            : CircleAvatar(
                                backgroundImage: FileImage(image!),
                                radius: 50,
                              ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 15),
                        margin: const EdgeInsets.only(top: 50),
                        child: Column(
                          children: [
                            textfield(
                              hintText: "Name",
                              icon: Icons.account_circle_outlined,
                              inputType: TextInputType.name,
                              controller: nameController,
                            ),
                            textfield(
                              hintText: "Age",
                              icon: Icons.calendar_month,
                              inputType: TextInputType.number,
                              controller: ageController,
                            ),
                            textfield(
                              hintText: "Password",
                              icon: Icons.password,
                              inputType: TextInputType.visiblePassword,
                              controller: passwordController,
                              obscureText: true,
                            ),
                            textfield(
                              hintText: "Confirm Password",
                              icon: Icons.password,
                              inputType: TextInputType.visiblePassword,
                              controller: confirmPasswordController,
                              obscureText: true,
                            ),
                          ],
                        ),
                      ),
                      //const SizedBox(height: 20,),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: RoundedButton(
                              onPressed: () {
                                if(nameController.text.length<3){
                                  showSnackBar(context, "Name must have atleast 3 characters");
                                }
                                else if(int.parse(ageController.text)<18){
                                  showSnackBar(context, "Must have an age of 18");
                                }
                                else if(passwordController.text.length<6){
                                  showSnackBar(context, "Password must have atlest 6 characters");
                                }
                                else if(passwordController.text!=confirmPasswordController.text){
                                  showSnackBar(context, "Confirm password is not same as Password");
                                }
                                else{
                                  storeData();
                                }
                              },
                              child: const Text("Continue")),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
