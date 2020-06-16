import 'package:flutter/material.dart';

class ChatBuble extends StatelessWidget {
  final message;

  const ChatBuble({Key key, this.message}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: (2 % 2 == 0) ? Alignment.topRight : Alignment.topLeft,
        child: Container(
            margin: EdgeInsets.only(top: 10, left: 70, right: 9),
            padding: EdgeInsets.all(18),
            decoration: BoxDecoration(
                color: Colors.deepOrangeAccent,
                borderRadius: BorderRadius.circular(18)),
            child: Text(
              message,
              style: TextStyle(color: Colors.white, fontSize: 14),
            )));
  }
}
