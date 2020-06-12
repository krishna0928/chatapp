import 'package:chatapp/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class Friends extends StatefulWidget {
  final String uid;

  const Friends({Key key, this.uid}) : super(key: key);
  @override
  _FriendsState createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CustomAppBar(
          title: 'Friends',
        ),
      ],
    );
  }
}
