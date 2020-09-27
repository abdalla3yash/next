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

  const NextApp(this.home);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.amber,
      accentColor: Colors.amber,
        ),
      home: this.home,
    );
  }
}
