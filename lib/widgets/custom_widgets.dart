import 'package:flutter/material.dart';

class CustomWidgets {
  Widget getCustomAppBar(String title) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
            fontSize: 27, fontWeight: FontWeight.bold, letterSpacing: 1.0),
      ),
      elevation: 0,
      centerTitle: true,
    );
  }

  Widget getDetailedCard(String name, String status, String url) {
    return Padding(
        padding: const EdgeInsets.all(9.0),
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.5),
              borderRadius: BorderRadius.circular(18)),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: url == 'null'
                    ? AssetImage('assets/circular_avatar.png')
                    : NetworkImage(url),
                maxRadius: 25,
                minRadius: 25,
              ),
              SizedBox(
                width: 16,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    name,
                    style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    status,
                    style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              )
            ],
          ),
        ));
  }
}
