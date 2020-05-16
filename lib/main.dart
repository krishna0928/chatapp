import 'package:chatapp/screens/LoginScreen.dart';
import 'package:chatapp/screens/Signup.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: LoginPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class Chatter extends StatefulWidget {
  @override
  _ChatterState createState() => _ChatterState();
}

class _ChatterState extends State<Chatter> {
  @override
  Widget build(BuildContext context) {
    return Container(
    );
  }
}


