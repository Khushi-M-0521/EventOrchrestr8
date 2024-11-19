import 'package:country_picker/country_picker.dart';
import 'package:email_validator/email_validator.dart';
import 'package:eventorchestr8/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/auth_provider.dart';
import '../widgets/rounded_button.dart';
import '../widgets/subtitle_text.dart';
import '../widgets/title_text.dart';
import 'home_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool switched = false;
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  final passwordController = TextEditingController();

  Country selectedCountry = Country(
    phoneCode: "91",
    countryCode: "IN",
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: "India",
    example: "9010102030",
    displayName: "India",
    displayNameNoCountryCode: "IN",
    e164Key: "",
  );

  void swap() {
    setState(() {
      switched = !switched;
    });
  }

  Widget textButton(String text) {
    return TextButton(
      onPressed: swap,
      child: Text(text),
    );
  }

  Widget filledButton(String text) {
    return RoundedButton(
      onPressed: swap,
      child: Text(text),
    );
  }

  void sendPhoneNumber() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String phoneNumber = phoneController.text.trim();
    authProvider.sigInWithPhone(
        context, "+${selectedCountry.phoneCode}$phoneNumber");
  }

  void signIn() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!switched) {
      // Email mode
      String email = emailController.text.trim();
      int password = passwordController.text.trim().hashCode;

      if (EmailValidator.validate(email) &&
          passwordController.text.isNotEmpty) {
        try {
          // Await email sign-in method from AuthProvider
          await authProvider.signInWithEmailAndPassword(
            context: context,
            email: email,
            password: password,
            onSuccess: () {
              // Navigate to HomeScreen if successful
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (Route<dynamic> route) =>
                    false, // This removes all previous routes
              );
            },
          );
        } catch (error) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString())),
          );
        }
      } else {
        // Show an error message if email or password is invalid
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Please enter a valid email and password")),
        );
      }
    } else {
      // Phone mode
      String phoneNumber = phoneController.text.trim();
      int password = passwordController.text.trim().hashCode;
      print(password);

      if (phoneNumber.isNotEmpty && passwordController.text.isNotEmpty) {
        try {
          // Await phone sign-in method from AuthProvider
          await authProvider.signInWithPhoneAndPassword(
            context: context,
            phoneNumber: "+${selectedCountry.phoneCode}$phoneNumber",
            password: password,
            onSuccess: () {
              print(phoneNumber);
              // Navigate to HomeScreen if successful
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (Route<dynamic> route) =>
                    false, // This removes all previous routes
              );
            },
          );
        } catch (error) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString())),
          );
        }
      } else {
        // Show an error message if phone number or password is invalid
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Please enter a valid phone number and password")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    phoneController.selection = TextSelection.fromPosition(
        TextPosition(offset: phoneController.text.length));

    Widget correctIcon = Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 20,
        width: 20,
        //padding: const EdgeInsets.symmetric(horizontal: 10.0),
        margin: const EdgeInsets.all(10),
        decoration:
            const BoxDecoration(shape: BoxShape.circle, color: Colors.green),
        child: const Icon(
          Icons.done,
          color: Colors.white,
          size: 15,
        ),
      ),
    );
    TextField passField = TextField(
      controller: passwordController,
      keyboardType: TextInputType.text,
      obscureText: true,
      onChanged: (value) {
        setState(() {
          passwordController.text = value;
        });
      },
      style: const TextStyle(
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: "Password",
        hintStyle: TextStyle(color: Colors.grey[400]),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: const BorderSide(color: Colors.black12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        prefixIcon: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Icon(Icons.password_outlined),
        ),
      ),
    );

    TextField emailField = TextField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      onChanged: (value) {
        setState(() {
          emailController.text = value;
        });
      },
      style: const TextStyle(
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: "abc@gmail.com",
        hintStyle: TextStyle(color: Colors.grey[400]),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: const BorderSide(color: Colors.black12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        prefixIcon: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Icon(Icons.email_outlined),
        ),
        suffixIcon:
            EmailValidator.validate(emailController.text) ? correctIcon : null,
      ),
    );

    TextFormField phoneField = TextFormField(
      controller: phoneController,
      keyboardType: const TextInputType.numberWithOptions(),
      onChanged: (value) {
        setState(() {
          phoneController.text = value;
        });
      },
      style: const TextStyle(
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: selectedCountry.example,
        hintStyle: TextStyle(color: Colors.grey[400]),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: const BorderSide(color: Colors.black12)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.primary)),
        prefixIcon: Container(
          padding: const EdgeInsets.all(15.0),
          child: InkWell(
            onTap: () {
              showCountryPicker(
                context: context,
                countryListTheme: const CountryListThemeData(
                  bottomSheetHeight: 500,
                ),
                onSelect: (country) {
                  setState(() {
                    selectedCountry = country;
                  });
                },
              );
            },
            child: Text(
              "${selectedCountry.flagEmoji} +${selectedCountry.phoneCode}",
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        suffixIcon:
            phoneController.text.length == selectedCountry.example.length
                ? correctIcon
                : null,
      ),
    );
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TitleText(text: "Signin Account"),
                      const SubtitleText(
                          text: "Hello, Welcome to EventOrchetr8"),
                      const SizedBox(height: 30),
                      Container(
                        width: double.infinity,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.grey[200],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            children: [
                              switched
                                  ? textButton("EMAIL ID")
                                  : filledButton("EMAIL ID"),
                              const Spacer(),
                              !switched
                                  ? textButton("PHONE NUMBER")
                                  : filledButton("PHONE NUMBER"),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: !switched
                            ? const Text("Email Address")
                            : const Text("Phone Number"),
                      ),
                      !switched ? emailField : phoneField,
                      const SizedBox(height: 20),
                      Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text("Password")),
                      passField,
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: RoundedButton(
                          onPressed: () {
                            print("typed");
                            signIn();
                          },
                          child: const Text("SIGN IN"),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SubtitleText(text: "Do not have an Account?"),
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => LoginScreen()));
                          },
                          child: const Text("Sign Up"))
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
