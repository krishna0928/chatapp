import 'package:chatapp/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class Chats extends StatefulWidget {
  final String uid;

  const Chats({Key key, this.uid}) : super(key: key);
  @override
  _ChatsState createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CustomAppBar(
          title: 'Chats',
        ),
      ],
    );
  }
}
