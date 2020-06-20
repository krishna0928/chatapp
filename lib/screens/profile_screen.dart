import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/screens/fullscreen_image.dart';
import 'package:chatapp/screens/message_screen.dart';
import 'package:chatapp/widgets/custom_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final name, uid, status, thumbUrl;
  final myUid;

  const ProfileScreen(
      {Key key, this.myUid, this.name, this.uid, this.status, this.thumbUrl})
      : super(key: key);
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String currentState;
  CollectionReference _firendsRef;
  CollectionReference _friendReqRef;
  CollectionReference _userFriendReqRef;
  CollectionReference _userFriendRef;

  bool loading = true;

  Future initData() async {
    setState(() {
      loading = true;
    });
    await _firendsRef.document(widget.uid).get().then((value) {
      if (value.data != null) {
        setState(() {
          currentState = 'friends';
        });
      } else {
        _friendReqRef.document(widget.uid).get().then((value) {
          if (value.data != null) {
            setState(() {
              currentState = value.data['reqType'];
            });
          } else {
            setState(() {
              currentState = 'notFriends';
            });
          }
        });
      }
    });

    setState(() {
      loading = false;
    });
  }

  setUpRef() {
    CollectionReference _rootRef = Firestore.instance.collection('Users');
    _firendsRef = _rootRef.document(widget.myUid).collection('friends');
    _friendReqRef = _rootRef.document(widget.myUid).collection('requests');
    _userFriendRef = _rootRef.document(widget.uid).collection('friends');
    _userFriendReqRef = _rootRef.document(widget.uid).collection('requests');
  }

  @override
  void initState() {
    setUpRef();
    initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomWidgets().getCustomAppBar('Profile'),
        backgroundColor: Theme.of(context).primaryColor,
        body: Container(
          height: double.infinity,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              )),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: GestureDetector(
                    onTap: () {
                      if (widget.thumbUrl != 'null') {
                        Navigator.push(context, MaterialPageRoute(builder: (_) {
                          return FullScreenImageView(
                            url: widget.thumbUrl,
                          );
                        }));
                      }
                    },
                    child: CircleAvatar(
                      minRadius: 90,
                      maxRadius: 90,
                      backgroundColor: Colors.white,
                      backgroundImage: (widget.thumbUrl == 'null')
                          ? AssetImage('assets/circular_avatar.png')
                          : CachedNetworkImageProvider(widget.thumbUrl),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ListTile(
                    title: Text(
                      widget.name,
                      style:
                          TextStyle(color: Colors.grey.shade900, fontSize: 25),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ListTile(
                    title: Text(
                      widget.status,
                      style:
                          TextStyle(color: Colors.grey.shade900, fontSize: 18),
                    ),
                  ),
                ),
                (loading)
                    ? Center(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : getWidgetAccordingToState(currentState),
              ],
            ),
          ),
        ));
  }

  Widget getWidgetAccordingToState(String state) {
    switch (state) {
      case 'notFriends':
        return Container(
          margin: EdgeInsets.only(top: 36),
          alignment: Alignment.center,
          child: RaisedButton(
            padding: EdgeInsets.all(12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            onPressed: () {
              sendFriendRq();
            },
            child: Text(
              'Send Request',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            color: Colors.deepOrangeAccent,
          ),
        );

      case 'received':
        return Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: 36),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RaisedButton(
                padding: EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
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
                padding: EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
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
          ),
        );

      case 'sent':
        return Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: 36),
          child: RaisedButton(
            padding: EdgeInsets.all(12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            onPressed: () async {
              await cancelRq();
              setState(() {
                currentState = 'notFriends';
              });
            },
            child: Text(
              'Cancel Request',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            color: Colors.deepOrangeAccent,
          ),
        );

      case 'friends':
        return Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: 36),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RaisedButton(
                padding: EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
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
                padding: EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                onPressed: () async {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) {
                    return MessagingScreeen(
                      myUid: widget.myUid,
                      userName: widget.name,
                      thumbnail: widget.thumbUrl,
                      uid: widget.uid,
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
          ),
        );

      default:
        return Container();
    }
  }

  void unFriend() async {
    await _firendsRef.document(widget.uid).delete();
    await _userFriendRef.document(widget.myUid).delete();
    setState(() {
      currentState = 'notFriends';
    });
  }

  void acceptRq() async {
    await _firendsRef
        .document(widget.uid)
        .setData({'timestamp': DateTime.now().microsecondsSinceEpoch});

    await _userFriendRef
        .document(widget.myUid)
        .setData({'timestamp': DateTime.now().microsecondsSinceEpoch});

    cancelRq();

    setState(() {
      currentState = 'friends';
    });
  }

  Future cancelRq() async {
    await _friendReqRef.document(widget.uid).delete();
    await _userFriendReqRef.document(widget.myUid).delete();
  }

  void sendFriendRq() async {
    await _friendReqRef.document(widget.uid).setData({'reqType': 'sent'});

    await _userFriendReqRef
        .document(widget.myUid)
        .setData({'reqType': 'received'});

    setState(() {
      currentState = 'sent';
    });
  }
}
