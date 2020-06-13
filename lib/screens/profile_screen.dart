import 'package:chatapp/widgets/custom_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final Map userMap;
  final String userID;
  final String myUid;

  const ProfileScreen({Key key, this.userMap, this.userID, this.myUid})
      : super(key: key);
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Stream _friendStream;
  DocumentReference _friendsRef;
  DocumentReference _firendsData;

  getFriendsRef() {
    _friendsRef =
        Firestore.instance.collection('Friends').document(widget.myUid);

   

    _friendStream = _firendsData.get().asStream();
  }

  @override
  void initState() {
    getFriendsRef();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: <Widget>[
        CustomAppBar(
          title: widget.userMap['name'],
        ),
        SizedBox(
          height: 30,
        ),
        CircleAvatar(
          minRadius: 90,
          maxRadius: 90,
        ),
        SizedBox(
          height: 15,
        ),
        Text(
          widget.userMap['name'],
          style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 25,
              fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 15,
        ),
        Text(
          widget.userMap['status'],
          style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 25,
              fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 30,
        ),
        StreamBuilder(
          stream: _friendStream,
          builder: (_, snap) {
            if (snap.hasData) {
              if (!snap.data.exists) {
                return Column(
                  children: <Widget>[
                    RaisedButton(
                      color: Colors.greenAccent,
                      onPressed: () {
                        _firendsData.setData({'type': 'sent'});
                      },
                      child: Text('Send Request'),
                    ),
                  ],
                );
              }
            } else {
              getFriendsRef();
              return Padding(
                padding: const EdgeInsets.all(18.0),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
        ),
      ],
    ));
  }
}
