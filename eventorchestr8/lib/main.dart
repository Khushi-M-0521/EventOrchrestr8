import 'package:eventorchestr8/constants/color_scheme.dart';
import 'package:eventorchestr8/provider/auth_provider.dart';
import 'package:eventorchestr8/screens/splash_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseAppCheck firebaseAppCheck=FirebaseAppCheck.instance;
  firebaseAppCheck.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData.light().copyWith(
          colorScheme: lightColorScheme,  
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: AppBarTheme.of(context).copyWith(
            backgroundColor: Colors.white,
            elevation: 2,
          )
        ),
        darkTheme: ThemeData.dark().copyWith(
          colorScheme: darkColorScheme,  
        ),
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}

