import 'dart:async';
import 'package:eventorchestr8/provider/auth_provider.dart';
import 'package:eventorchestr8/screens/signin.dart';
import 'package:eventorchestr8/screens/user_info_screen.dart';
import 'package:eventorchestr8/utils/utils.dart';
import 'package:eventorchestr8/widgets/rounded_button.dart';
import 'package:eventorchestr8/widgets/subtitle_text.dart';
import 'package:eventorchestr8/widgets/title_text.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen(
      {super.key, required this.verificationId, this.phoneNumber, this.email});
  final String verificationId;
  final String? phoneNumber;
  final String? email;
  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  String? otpCode;
  int forTime = 120;
  bool verifying = false;

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (forTime > 0) {
        setState(() {
          forTime--;
        });
      } else {
        mounted && !verifying ? Navigator.of(context).pop() : null;
      }
    });
  }

  void verifyOtp(BuildContext context, String userOtp) {
    final ap = Provider.of<AuthProvider>(context, listen: false);

    void onSuccess() {
      ap.checkExixtingUser().then((value) async {
        if (value) {
          //user exits in our app
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User Already exists")),
          );
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const SignInScreen()),
              (route) => false);
        } else {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => widget.phoneNumber != null
                      ? UserInfoScreen(phoneNumber: widget.phoneNumber)
                      : UserInfoScreen(email: widget.email)),
              (route) => false);
        }
      });
    }

    widget.phoneNumber != null
        ? ap.verifyOtp(
            context: context,
            verficationId: widget.verificationId,
            userOtp: userOtp,
            onSuccess: onSuccess,
            email: null,
          )
        : ap.verifyOtp(
            context: context,
            verficationId: widget.verificationId,
            userOtp: userOtp,
            onSuccess: onSuccess,
            email: widget.email,
          );
    // print(widget.verificationId!=userOtp);
    // widget.email!=null? ( onSuccess() :null) :null;
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        Provider.of<AuthProvider>(context, listen: true).isLoading;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const TitleText(text: "Verification"),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FadeInImage(
                      placeholder:
                          AssetImage('./assets/images/transparent_image.png'),
                      image: AssetImage(widget.phoneNumber != null
                          ? './assets/images/phone_verification.png'
                          : './assets/images/email_verification.png'),
                      fit: BoxFit.cover,
                      height: 200,
                      width: 200,
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    TitleText(
                        text: widget.phoneNumber != null
                            ? "Verify Your Mobile Number"
                            : "Verify Your Email Address"),
                    SubtitleText(
                      text: widget.phoneNumber != null
                          ? 'We have sent a Verification Code to (${widget.phoneNumber!.substring(0, 3)})${widget.phoneNumber!.substring(3)}'
                          : "We have sent a Verification Code to ${widget.email!}",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Pinput(
                      length: 6,
                      showCursor: true,
                      defaultPinTheme: PinTheme(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.5),
                          ),
                          boxShadow: [BoxShadow(color: Colors.grey[300]!)],
                        ),
                        textStyle: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      focusedPinTheme: PinTheme(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        textStyle: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      onCompleted: (value) {
                        setState(() {
                          otpCode = value;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Text.rich(
                      TextSpan(children: [
                        TextSpan(
                          text: "OTP valid until ",
                          style:
                              Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    color: Colors.grey,
                                  ),
                        ),
                        TextSpan(
                          text: "$forTime seconds",
                          style:
                              Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    color: Colors.blue,
                                  ),
                        )
                      ]),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: RoundedButton(
                        onPressed: () {
                          if (otpCode != null) {
                            setState(() {
                              forTime = 2;
                              verifying = true;
                            });
                            verifyOtp(context, otpCode!);
                          } else {
                            showSnackBar(context, "Enter 6-digit code");
                          }
                        },
                        child: const Text("VERIFY"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
