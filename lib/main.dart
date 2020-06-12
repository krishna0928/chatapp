import 'package:chatapp/screens/wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
    debugShowCheckedModeBanner: false,
  ));
  SystemChrome.setEnabledSystemUIOverlays([]);
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<FirebaseUser>.value(
      value: FirebaseAuth.instance.currentUser().asStream(),
      child: Wrapper(),
    );
  }
}
