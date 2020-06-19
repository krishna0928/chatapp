import 'dart:async';

import 'package:chatapp/screens/message_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Chats extends StatefulWidget {
  final String uid;

  const Chats({Key key, this.uid}) : super(key: key);
  @override
  _ChatsState createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  Stream<QuerySnapshot> _chatsStream;
  CollectionReference _lastMsgRef;
  DatabaseReference _usersRef;

  initData() async {
    CollectionReference _rootRef = Firestore.instance.collection(widget.uid);
    _chatsStream = _rootRef.orderBy('timestamp', descending: true).snapshots();
    _usersRef = FirebaseDatabase.instance.reference().child('Users');
    _lastMsgRef = _rootRef;
  }

  @override
  void initState() {
    initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30), topRight: Radius.circular(30))),
          child: StreamBuilder<QuerySnapshot>(
              stream: _chatsStream,
              builder: (context, snapshot) {
                if (snapshot.data != null) {
                  return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (_, index) {
                        return StreamBuilder<Event>(
                            stream: _usersRef
                                .child(
                                    snapshot.data.documents[index].documentID)
                                .onValue,
                            builder: (context, usersSnap) {
                              if (usersSnap.hasData) {
                                return GestureDetector(
                                    onTap: () => Navigator.push(context,
                                            MaterialPageRoute(builder: (_) {
                                          return MessagingScreeen(
                                            myUid: widget.uid,
                                            userName: usersSnap
                                                .data.snapshot.value['name'],
                                            thumbnail: usersSnap.data.snapshot
                                                .value['thumbUrl'],
                                            status: usersSnap
                                                .data.snapshot.value['status'],
                                            uid: snapshot.data.documents[index]
                                                .documentID,
                                          );
                                        })),
                                    child: Padding(
                                        padding: const EdgeInsets.all(9.0),
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                              color: Colors.orange
                                                  .withOpacity(0.5),
                                              borderRadius:
                                                  BorderRadius.circular(18)),
                                          child: Row(
                                            children: <Widget>[
                                              CircleAvatar(
                                                backgroundColor: Colors.white,
                                                backgroundImage: usersSnap.data
                                                                .snapshot.value[
                                                            'thumbUrl'] ==
                                                        'null'
                                                    ? AssetImage(
                                                        'assets/circular_avatar.png')
                                                    : NetworkImage(
                                                        usersSnap.data.snapshot
                                                            .value['thumbUrl'],
                                                      ),
                                                maxRadius: 25,
                                                minRadius: 25,
                                              ),
                                              SizedBox(
                                                width: 16,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    usersSnap.data.snapshot
                                                        .value['name'],
                                                    style: TextStyle(
                                                        color: Colors.blueGrey,
                                                        fontSize: 25,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  StreamBuilder<QuerySnapshot>(
                                                      stream: _lastMsgRef
                                                          .document(snapshot
                                                              .data
                                                              .documents[index]
                                                              .documentID)
                                                          .collection(
                                                              'messages')
                                                          .orderBy('timestamp',
                                                              descending: true)
                                                          .limit(1)
                                                          .snapshots(),
                                                      builder:
                                                          (context, snapshot) {
                                                        if (snapshot.data !=
                                                            null) {
                                                          return Text(
                                                            snapshot.data
                                                                    .documents[
                                                                0]['message'],
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .blueGrey,
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          );
                                                        } else
                                                          return Text(
                                                              'fetching');
                                                      }),
                                                ],
                                              )
                                            ],
                                          ),
                                        )));
                              } else {
                                return Container();
                              }
                            });
                      });
                } else {
                  return Container();
                }
              }),
        ));
  }
}
