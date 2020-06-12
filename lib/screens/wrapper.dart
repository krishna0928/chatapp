import 'package:chatapp/screens/LoginScreen.dart';
import 'package:chatapp/screens/main_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final FirebaseUser _firebaseUser = Provider.of(context);

    if (_firebaseUser == null) {
      return LoginPage();
    } else {
      return MainPage(
        uid: _firebaseUser.uid,
      );
    }
  }
}
