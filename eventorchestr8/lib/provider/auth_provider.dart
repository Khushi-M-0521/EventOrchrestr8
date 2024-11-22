import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventorchestr8/constants/config.dart';
import 'package:eventorchestr8/models/user_credential.dart';
import 'package:eventorchestr8/models/user_details.dart';
import 'package:eventorchestr8/screens/otp_screen.dart';
import 'package:eventorchestr8/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _uid;
  String get uid => _uid!;

  UserCredentialModel? _userCredentialModel;
  UserCredentialModel get userCredentialModel => _userCredentialModel!;

  UserDetailModel? _userDetailModel;
  UserDetailModel get userDetailModel => _userDetailModel!;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  AuthProvider() {
    checkSign();
  }

  void checkSign() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _isSignedIn = s.getBool("is_signedin") ?? false;
    notifyListeners();
  }

  Future setSignIn() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    s.setBool("is_signedin", true);
    _isSignedIn = true;
    notifyListeners();
  }

  void sigInWithPhone(BuildContext context, String phoneNumber) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async {
          await _firebaseAuth.signInWithCredential(phoneAuthCredential);
        },
        verificationFailed: (error) {
          showSnackBar(context, "Verification Failed");
          throw Exception(error.message);
        },
        codeSent: (verificationId, forceResendingToken) {
          print("next");
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => OTPScreen(
                    verificationId: verificationId,
                    phoneNumber: phoneNumber,
                  )));
        },
        codeAutoRetrievalTimeout: (verficationId) {},
      );
    } on FirebaseAuthException catch (e) {
      print(e.message.toString());
      showSnackBar(context, e.message.toString());
    }
    print("done");
  }

  String generateEmailOtp() {
    final random = Random();
    return (random.nextInt(900000) + 100000).toString(); // 6-digit OTP
  }

  void signInWithEmail(BuildContext context, String email) async {
    final smtpServer = gmail(smtpServerUsername, smtpServerPassword);
    final otp = generateEmailOtp();
    final message = Message()
      ..from = Address(smtpServerUsername, 'EventOrchestr8')
      ..recipients.add(email)
      ..subject = 'Verification Code'
      ..text = 'Your OTP code is $otp';
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OTPScreen(
          verificationId: otp,
          email: email,
        ),
      ),
    );
    try {
      _firebaseAuth.createUserWithEmailAndPassword(email: email, password: otp);
      await send(message, smtpServer);
      print("OTP sent to $email");
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void verifyOtp({
    required BuildContext context,
    required String verficationId,
    required String userOtp,
    required Function onSuccess,
    required String? email,
  }) async {
    _isLoading = true;
    notifyListeners();
    User? user;
    try {
      if (email == null) {
        PhoneAuthCredential creds = PhoneAuthProvider.credential(
            verificationId: verficationId, smsCode: userOtp);
        user = (await _firebaseAuth.signInWithCredential(creds)).user;
      } else {
        if (verficationId == userOtp) {
          AuthCredential creds =
              EmailAuthProvider.credential(email: email, password: userOtp);
          user = (await _firebaseAuth.signInWithCredential(creds)).user;
          onSuccess();
        } else {
          showSnackBar(context, "Incorrect verification code.");
        }
      }
      if (user != null) {
        _uid = user.uid;
        onSuccess();
      }

      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      showSnackBar(context, e.message.toString());
    }
  }

  Future<void> deleteUser({
    required String otp,
    required String? email,
  }) async {
    if (email != null) {
      AuthCredential creds =
          EmailAuthProvider.credential(email: email, password: otp);
      _firebaseAuth.signInWithCredential(creds).then((cred) {
        try{
          cred.user!.delete();
        }
        catch(e){
          print(e);
        }
      });
    }
  }

  Future<bool> checkExixtingUser() async {
    print(_uid);
    DocumentSnapshot snapshot =
        await _firebaseFirestore.collection("users").doc(_uid).get();
    print(_firebaseFirestore.collection("users"));
    print(_firebaseFirestore.collection("users").doc(_uid));
    if (snapshot.exists) {
      print("User exits");
      return true;
    } else {
      print("New User");
      return false;
    }
  }

  void saveUserCredentialDataToFirebase({
    required BuildContext context,
    required UserCredentialModel userCredentialModel,
    required UserDetailModel userDetailModel,
    required Function onSuccess,
    File? profilePicture,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (profilePicture != null) {
        await storeFileToStorage("profilePicture/$_uid", profilePicture)
            .then((value) {
          userDetailModel.profilePicture = value;
        });
      }
      userCredentialModel.createdAt =
          DateTime.now().microsecondsSinceEpoch.toString();
      userCredentialModel.uid = _firebaseAuth.currentUser!.uid;
      userDetailModel.uid = _firebaseAuth.currentUser!.uid;

      _userCredentialModel = userCredentialModel;
      _userDetailModel = userDetailModel;

      //

      // Uploading to Firestore
      await _firebaseFirestore
          .collection("users")
          .doc(_uid)
          .set(userCredentialModel.toMap());
      await _firebaseFirestore
          .collection("user_details")
          .doc(_uid)
          .set(userDetailModel.toMap())
          .then((value) {
        onSuccess();
        _isLoading = false;
        notifyListeners();
      });
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> storeFileToStorage(String ref, File file) async {
    UploadTask uploadTask = _firebaseStorage.ref().child(ref).putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  //storing data locally
  Future saveUserDataToSP() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    await s.setString(
        "user_credential_model", jsonEncode(userCredentialModel.toMap()));
    await s.setString("user_detail_model", jsonEncode(userDetailModel.toMap()));
  }

  Future<void> signInWithPhoneAndPassword({
    required BuildContext context,
    required String phoneNumber,
    required int password,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch user data using the phone number
      QuerySnapshot querySnapshot = await _firebaseFirestore
          .collection("users")
          .where("phoneNumber", isEqualTo: phoneNumber)
          .get();

      if (querySnapshot.docs.isEmpty) {
        _isLoading = false;
        notifyListeners();
        showSnackBar(context, "Phone number not found");
        return;
      }

      // Assuming there's only one document
      DocumentSnapshot userDoc = querySnapshot.docs.first;
      print(userDoc.data());
      Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
      // Verify the password stored in Firestore
      print(data);
      String? storedPassword = data?['password'];
      print(storedPassword);

      if (storedPassword == password) {
        // Successful login
        _uid = userDoc['uid'];
        _userCredentialModel =
            UserCredentialModel.fromMap(userDoc.data() as Map<String, dynamic>);
        _userDetailModel = UserDetailModel.fromMap(
          (await _firebaseFirestore.collection("user_details").doc(_uid).get())
              .data()!,
        );

        // Save user data locally
        await saveUserDataToSP();
        setSignIn();

        // Call onSuccess callback
        onSuccess();
      } else {
        _isLoading = false;
        notifyListeners();
        showSnackBar(context, "Incorrect password");
      }

      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      showSnackBar(context, e.message.toString());
    }
  }

  Future<void> signInWithEmailAndPassword({
    required BuildContext context,
    required String email,
    required int password,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      QuerySnapshot querySnapshot = await _firebaseFirestore
          .collection("users")
          .where("email", isEqualTo: email)
          .get();

      if (querySnapshot.docs.isEmpty) {
        _isLoading = false;
        notifyListeners();
        showSnackBar(context, "Email Address not found");
        return;
      }

      DocumentSnapshot userDoc = querySnapshot.docs.first;
      print(userDoc.data());
      Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
      // Verify the password stored in Firestore
      print(data);
      int storedPassword = data?['password'];
      print(storedPassword);

      if (storedPassword == password) {
        // Successful login
        _uid = userDoc['uid'];
        _userCredentialModel =
            UserCredentialModel.fromMap(userDoc.data() as Map<String, dynamic>);
        _userDetailModel = UserDetailModel.fromMap(
          (await _firebaseFirestore.collection("user_details").doc(_uid).get())
              .data()!,
        );

        // Save user data locally
        await saveUserDataToSP();
        setSignIn();

        // Call onSuccess callback
        onSuccess();
      } else {
        _isLoading = false;
        notifyListeners();
        showSnackBar(context, "Incorrect password");
      }

      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      showSnackBar(context, e.message.toString());
      notifyListeners();
    }
  }

  void signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
