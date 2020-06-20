import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/Services/Authentication.dart';
import 'package:chatapp/screens/friend_requests.dart';
import 'package:chatapp/screens/friends.dart';
import 'package:chatapp/screens/message_screen.dart';
import 'package:chatapp/screens/search.dart';
import 'package:chatapp/screens/settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

class MainPage extends StatefulWidget {
  final String uid, imageUrl, name;
  final bool darkTheme;

  const MainPage({Key key, this.uid, this.imageUrl, this.name, this.darkTheme})
      : super(key: key);
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  initPages() {
    String uid = widget.uid;
    screenList = [
      Container(),
      Search(uid: uid),
      Friends(uid: uid),
      FriendRequest(uid: uid),
      Settings(
        uid: uid,
        darkTheme: widget.darkTheme,
      )
    ];
  }

  setUpNotifications() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
  }

  Set selectedTiles = {};
  bool selectAll = false;
  bool isLongActive = false;

  CollectionReference _chatsRef;
  CollectionReference _lastMsgRef;
  CollectionReference _usersRef;
  Firestore _rootRef = Firestore.instance;

  initData() async {
    _usersRef = _rootRef.collection('Users');
    _chatsRef = _rootRef.collection(widget.uid);
    _lastMsgRef = _rootRef.collection(widget.uid);
  }

  @override
  void initState() {
    initPages();
    initData();
    setUpNotifications();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Widget> screenList = [];

  int _currentIndex = 0;
  String title = 'Chats';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: selectedTiles.length > 0
          ? AppBar(
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    selectedTiles.clear();
                    isLongActive = false;
                  });
                },
              ),
              actions: <Widget>[
                Container(
                  margin: EdgeInsets.all(9),
                  alignment: Alignment.center,
                  child: Text(
                    selectedTiles.length.toString(),
                    style: TextStyle(fontSize: 23),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.select_all),
                  onPressed: () {
                    setState(() {
                      selectAll = true;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete_forever),
                  onPressed: () {
                    setState(() {
                      deleteForEveryOne();
                      isLongActive = false;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline),
                  onPressed: () {
                    setState(() {
                      deleteForMe();
                      isLongActive = false;
                    });
                  },
                )
              ],
            )
          : AppBar(
              title: Text(
                title,
                style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0),
              ),
              elevation: 0,
              centerTitle: true,
            ),
      drawer: (selectedTiles.length > 0)
          ? null
          : Drawer(
              child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Text(
                        widget.name,
                        style: TextStyle(
                          color: Colors.deepOrangeAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                    ),
                    CircleAvatar(
                      maxRadius: 50,
                      minRadius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage: widget.imageUrl != 'null'
                          ? CachedNetworkImageProvider(
                              widget.imageUrl,
                            )
                          : Image.asset('assets/circular_avatar.png',
                              height: 117, width: 117),
                    )
                  ],
                ),
                GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentIndex = 0;
                        title = 'Chats';
                      });
                      Navigator.of(context).pop();
                    },
                    child: getListTile('Chats', Icons.chat)),
                GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentIndex = 1;
                        title = 'Search';
                      });
                      Navigator.of(context).pop();
                    },
                    child: getListTile('Search', Icons.search)),
                GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentIndex = 2;
                        title = 'Friends';
                      });
                      Navigator.of(context).pop();
                    },
                    child: getListTile('Friends', Icons.contacts)),
                GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentIndex = 3;
                        title = 'Requests';
                      });
                      Navigator.of(context).pop();
                    },
                    child: getListTile('Requests', Icons.format_line_spacing)),
                GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentIndex = 4;
                        title = 'Settings';
                      });
                      Navigator.of(context).pop();
                    },
                    child: getListTile('Settings', Icons.settings)),
                GestureDetector(
                    onTap: () async {
                      await AuthServices().logout();
                      Phoenix.rebirth(context);
                      Navigator.of(context).pop();
                    },
                    child: getListTile('Logout', Icons.all_out)),
              ],
            )),
      body: (_currentIndex == 0)
          ? Scaffold(
              backgroundColor: Theme.of(context).primaryColor,
              body: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30))),
                child: StreamBuilder<QuerySnapshot>(
                    stream: _chatsRef
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.data != null) {
                        if (selectAll) {
                          snapshot.data.documents.forEach((element) {
                            selectedTiles.add(element.documentID);
                          });
                        }
                        return ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data.documents.length,
                            itemBuilder: (_, index) {
                              return StreamBuilder<DocumentSnapshot>(
                                  stream: _usersRef
                                      .document(snapshot
                                          .data.documents[index].documentID)
                                      .snapshots(),
                                  builder: (context, usersSnap) {
                                    if (usersSnap.hasData) {
                                      return Container(
                                          margin: EdgeInsets.all(9),
                                          padding: EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                              color: selectedTiles.contains(
                                                      usersSnap.data.documentID)
                                                  ? Colors.orangeAccent
                                                      .withOpacity(0.5)
                                                  : Colors.grey.shade200,
                                              borderRadius:
                                                  BorderRadius.circular(30)),
                                          child: StreamBuilder<QuerySnapshot>(
                                              stream: _lastMsgRef
                                                  .document(snapshot
                                                      .data
                                                      .documents[index]
                                                      .documentID)
                                                  .collection('messages')
                                                  .orderBy('timestamp',
                                                      descending: true)
                                                  .limit(1)
                                                  .snapshots(),
                                              builder: (context, snapshot) {
                                                if (snapshot.data != null) {
                                                  return ListTile(
                                                    onLongPress: () {
                                                      setState(() {
                                                        selectedTiles.add(
                                                            usersSnap.data
                                                                .documentID);
                                                        isLongActive = true;
                                                      });
                                                    },
                                                    onTap: () {
                                                      if (isLongActive) {
                                                        if (selectedTiles
                                                            .contains(usersSnap
                                                                .data
                                                                .documentID)) {
                                                          setState(() {
                                                            selectedTiles.remove(
                                                                usersSnap.data
                                                                    .documentID);
                                                          });
                                                        }
                                                      } else if (selectedTiles
                                                              .length >
                                                          0) {
                                                        setState(() {
                                                          selectedTiles.add(
                                                              usersSnap.data
                                                                  .documentID);
                                                        });
                                                      } else {
                                                        Navigator.push(context,
                                                            MaterialPageRoute(
                                                                builder: (_) {
                                                          return MessagingScreeen(
                                                            myUid: widget.uid,
                                                            userName: usersSnap
                                                                .data
                                                                .data['name'],
                                                            thumbnail: usersSnap
                                                                    .data.data[
                                                                'imageUrl'],
                                                            status: usersSnap
                                                                .data
                                                                .data['status'],
                                                            uid: usersSnap.data
                                                                .documentID,
                                                          );
                                                        }));
                                                      }
                                                    },
                                                    leading: CircleAvatar(
                                                      maxRadius: 27,
                                                      minRadius: 27,
                                                      backgroundColor:
                                                          Colors.white,
                                                      backgroundImage: usersSnap
                                                                      .data
                                                                      .data[
                                                                  'imageUrl'] ==
                                                              'null'
                                                          ? AssetImage(
                                                              'assets/circular_avatar.png')
                                                          : CachedNetworkImageProvider(
                                                              usersSnap.data
                                                                      .data[
                                                                  'imageUrl'],
                                                            ),
                                                    ),
                                                    title: Text(
                                                      usersSnap
                                                          .data.data['name'],
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    subtitle: Text(
                                                      snapshot.data.documents[0]
                                                          ['message'],
                                                      style: TextStyle(
                                                        color: Colors.blueGrey,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    trailing: Text(
                                                        snapshot.data
                                                                .documents[0]
                                                            ['sentTime'],
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors
                                                              .grey.shade700,
                                                        )),
                                                  );
                                                } else
                                                  return Center(
                                                      child: Text('........'));
                                              }));
                                    } else {
                                      return Container();
                                    }
                                  });
                            });
                      } else {
                        return Container();
                      }
                    }),
              ))
          : screenList[_currentIndex],
    );
  }

  getListTile(String title, IconData iconData) {
    return Container(
      margin: EdgeInsets.all(9),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: Colors.grey.shade200, borderRadius: BorderRadius.circular(30)),
      child: ListTile(
        leading: Icon(
          iconData,
          color: Colors.deepOrangeAccent,
        ),
        title: Text(title),
      ),
    );
  }

  deleteForMe() {
    selectedTiles.forEach((element) async {
      await _chatsRef
          .document(element)
          .collection('messages')
          .getDocuments()
          .then((value) {
        for (DocumentSnapshot ds in value.documents) {
          ds.reference.delete();
        }
      });
      await _chatsRef.document(element).delete();
      setState(() {
        selectedTiles.remove(element);
      });
    });
  }

  deleteForEveryOne() {
    selectedTiles.forEach((element) async {
      await _rootRef
          .collection(element)
          .document(widget.uid)
          .collection('messages')
          .getDocuments()
          .then((value) {
        for (DocumentSnapshot ds in value.documents) {
          ds.reference.delete();
        }
      });
      await _rootRef.collection(element).document(widget.uid).delete();

      await _chatsRef
          .document(element)
          .collection('messages')
          .getDocuments()
          .then((value) {
        for (DocumentSnapshot ds in value.documents) {
          ds.reference.delete();
        }
      });
      await _chatsRef.document(element).delete();
      setState(() {
        selectedTiles.remove(element);
      });
    });
  }
}
