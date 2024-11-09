import 'package:country_picker/country_picker.dart';
import 'package:email_validator/email_validator.dart';
import 'package:eventorchestr8/provider/auth_provider.dart';
import 'package:eventorchestr8/screens/signin.dart';
import 'package:eventorchestr8/widgets/rounded_button.dart';
import 'package:eventorchestr8/widgets/subtitle_text.dart';
import 'package:eventorchestr8/widgets/title_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool switched = false;
  bool correctInput =false;
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
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

  @override
  void dispose(){
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

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

  void sendEmail(){
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String email = emailController.text.trim();
    authProvider.signInWithEmail(context, email);
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

    TextField emailField = TextField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      onEditingComplete: () {
        setState(() {
          correctInput=EmailValidator.validate(emailController.text);
        });
      },
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
      onEditingComplete: (){
        setState(() {
          correctInput=phoneController.text.trim().length == selectedCountry.example.length;
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
            phoneController.text.trim().length == selectedCountry.example.length
                ? correctIcon
                : null,
      ),
    );

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TitleText(text: "Login Account"),
                  const SubtitleText(text: "Hello, Welcome to EventOrchetr8"),
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
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: !switched
                        ? const Text("Email Address")
                        : const Text("Phone Number"),
                  ),
                  !switched ? emailField : phoneField,
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: RoundedButton(
                      onPressed: () {
                        print("typing");
                        switched?sendPhoneNumber():sendEmail();
                      },
                      child: const Text("VERIFY"),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SubtitleText(text: "Already have an Account?"),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => SignInScreen()));
                    },
                    child: const Text("Sign in"))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
