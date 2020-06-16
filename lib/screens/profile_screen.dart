import 'package:chatapp/models/users.dart';
import 'package:chatapp/screens/message_screen.dart';
import 'package:chatapp/widgets/custom_widgets.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final Users userData;
  final String myUid;

  const ProfileScreen({Key key, this.userData, this.myUid}) : super(key: key);
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String currentState;
  DatabaseReference _rootRef;
  DatabaseReference _friendsRef;
  DatabaseReference _friendRqRef;
  bool loading = true;

  Future getFriendsRef() async {
    await _friendsRef
        .child(widget.myUid)
        .child(widget.userData.uid)
        .once()
        .then((value) {
      if (value.value == null) {
        _friendRqRef
            .child(widget.myUid)
            .child(widget.userData.uid)
            .once()
            .then((value) {
          if (value.value != null) {
            setState(() {
              currentState = value.value['reqType'];
              print(currentState);
            });
          } else {
            setState(() {
              currentState = 'Not Friends';
            });
          }
        });
      } else {
        setState(() {
          currentState = 'friends';
        });
      }
    });

    setState(() {
      loading = false;
    });
  }

  setUpRef() {
    _rootRef = FirebaseDatabase.instance.reference();
    _friendsRef = _rootRef.child('friends');

    _friendRqRef = _rootRef.child('friendReq');
  }

  @override
  void initState() {
    setUpRef();
    getFriendsRef();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
        children: <Widget>[
          CustomWidgets().getCustomAppBar('Profile'),
          SizedBox(
            height: 30,
          ),
          CircleAvatar(
            minRadius: 90,
            maxRadius: 90,
            backgroundColor: Colors.white,
            backgroundImage: (widget.userData.thumbUrl == 'null')
                ? AssetImage('assets/circular_avatar.png')
                : NetworkImage(widget.userData.imageUrl),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            widget.userData.name,
            style: TextStyle(
                color: Colors.blueGrey,
                fontSize: 25,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            widget.userData.status,
            style: TextStyle(
                color: Colors.blueGrey,
                fontSize: 25,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 30,
          ),
          (loading)
              ? SizedBox(
                  height: 100,
                  width: 100,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : getWidgetAccordingToState(currentState),
        ],
      ),
    ));
  }

  Widget getWidgetAccordingToState(String state) {
    switch (state) {
      case 'Not Friends':
        return RaisedButton(
          onPressed: () {
            sendFriendRq();
          },
          child: Text(
            'Send Request',
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          color: Colors.deepOrangeAccent,
        );

      case 'received':
        return Column(
          children: <Widget>[
            RaisedButton(
              onPressed: () {
                acceptRq();
              },
              child: Text(
                'Accept Request',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              color: Colors.deepOrangeAccent,
            ),
            RaisedButton(
              onPressed: () {
                cancelRq();
              },
              child: Text(
                'Decline Request',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              color: Colors.deepOrangeAccent,
            ),
          ],
        );

      case 'sent':
        return RaisedButton(
          onPressed: () {
            cancelRq();
          },
          child: Text(
            'Cancel Request',
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          color: Colors.deepOrangeAccent,
        );

      case 'friends':
        return Column(
          children: <Widget>[
            RaisedButton(
              onPressed: () {
                unFriend();
              },
              child: Text(
                'Un-Friend',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              color: Colors.deepOrangeAccent,
            ),
            RaisedButton(
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) {
                  return MessagingScreeen(
                    myUid: widget.myUid,
                    profileUser: widget.userData,
                  );
                }));
              },
              child: Text(
                'Message',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              color: Colors.deepOrangeAccent,
            ),
          ],
        );

      default:
        return Text('');
    }
  }

  void unFriend() async {
    await _friendsRef.child(widget.myUid).child(widget.userData.uid).remove();
    await _friendsRef.child(widget.userData.uid).child(widget.myUid).remove();
    setState(() {
      currentState = 'Not Friends';
    });
  }

  void acceptRq() async {
    await _friendsRef.child(widget.myUid).child(widget.userData.uid).set({
      'timeStamp': ServerValue.timestamp,
    });
    await _friendsRef.child(widget.userData.uid).child(widget.myUid).set({
      'timeStamp': ServerValue.timestamp,
    });

    await _friendRqRef.child(widget.myUid).child(widget.userData.uid).remove();
    await _friendRqRef.child(widget.userData.uid).child(widget.myUid).remove();

    setState(() {
      currentState = 'friends';
    });
  }

  void cancelRq() async {
    await _friendRqRef.child(widget.myUid).child(widget.userData.uid).remove();
    await _friendRqRef.child(widget.userData.uid).child(widget.myUid).remove();

    setState(() {
      currentState = 'Not Friends';
    });
  }

  void sendFriendRq() async {
    await _friendRqRef
        .child(widget.myUid)
        .child(widget.userData.uid)
        .set({'reqType': 'sent'});
    await _friendRqRef
        .child(widget.userData.uid)
        .child(widget.myUid)
        .set({'reqType': 'received'});

    setState(() {
      currentState = 'sent';
    });
  }
}
