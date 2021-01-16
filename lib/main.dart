import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:next/auth/login.dart';
import 'package:next/todo/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Widget homeScreen = HomeScreen();
  FirebaseUser user = await FirebaseAuth.instance.currentUser();
  if (user == null) {
    homeScreen = LoginScreen();
  }

  runApp(NextApp(homeScreen));
}

class NextApp extends StatelessWidget {
  final Widget home;
  static const String google_sans_family = "GoogleSans";

  const NextApp(this.home);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: google_sans_family,
        primaryColor:  Color(0xFFF4325C),
        disabledColor: Colors.grey,
        cardColor: Colors.white,
        canvasColor: Colors.grey[50],
      ),
      home: this.home,
    );
  }
}
