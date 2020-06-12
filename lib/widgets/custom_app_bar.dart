import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final String title;

  const CustomAppBar({Key key, this.title}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      height: 70,
      decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30))),
      child: Text(
        title,
        style: TextStyle(
            color: Colors.white, fontSize: 27, fontWeight: FontWeight.bold),
      ),
    );
  }
}
