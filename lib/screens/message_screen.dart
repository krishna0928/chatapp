import 'package:chatapp/screens/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MessagingScreeen extends StatefulWidget {
  final myUid;
  final userName, thumbnail, uid, status;

  const MessagingScreeen(
      {Key key,
      this.myUid,
      this.thumbnail,
      this.uid,
      this.userName,
      this.status})
      : super(key: key);
  @override
  _MessagingScreeenState createState() => _MessagingScreeenState();
}

class _MessagingScreeenState extends State<MessagingScreeen> {
  String _enteredMessage;
  DocumentReference _myMessageReference;
  DocumentReference _userMessageReference;
  Stream _messageStream;
  Set selectedItems = {};
  bool onLongTapActive = false;

  final _messageController = TextEditingController();

  initData() {
    Firestore _rootReference = Firestore.instance;

    _myMessageReference =
        _rootReference.collection(widget.myUid).document(widget.uid);

    _userMessageReference =
        _rootReference.collection(widget.uid).document(widget.myUid);

    _messageStream = _myMessageReference
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  void initState() {
    initData();
    super.initState();
  }

  GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _globalKey,
        backgroundColor: Theme.of(context).primaryColor,
        appBar: selectedItems.length > 0
            ? AppBar(
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      onLongTapActive = true;
                      selectedItems.clear();
                    });
                  },
                ),
                actions: <Widget>[
                  Container(
                    margin: EdgeInsets.all(9),
                    alignment: Alignment.center,
                    child: Text(
                      selectedItems.length.toString(),
                      style: TextStyle(fontSize: 23),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_forever),
                    onPressed: () {
                      setState(() {
                        deleteForEveryOneSingle();
                        onLongTapActive = true;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline),
                    onPressed: () {
                      setState(() {
                        deleteForMeSingle();
                        onLongTapActive = false;
                      });
                    },
                  )
                ],
              )
            : AppBar(
                title: Text(
                  widget.userName,
                  style: TextStyle(fontSize: 25),
                ),
                centerTitle: true,
                elevation: 0,
                actions: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.more_horiz,
                    ),
                    onPressed: () {
                      getBottomSheet();
                    },
                  )
                ],
              ),
        body: Column(
          children: <Widget>[
            Expanded(
                child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30)),
                color: Colors.white,
              ),
              child: StreamBuilder<QuerySnapshot>(
                  stream: _messageStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                          reverse: true,
                          padding: EdgeInsets.only(top: 10),
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (_, index) {
                            if (snapshot.data.documents[index]['uid'] ==
                                widget.uid) {
                              setSeen(
                                  snapshot.data.documents[index].documentID);
                            }
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (onLongTapActive) {
                                    if (selectedItems.contains(snapshot
                                        .data.documents[index].documentID)) {
                                      selectedItems.remove(snapshot
                                          .data.documents[index].documentID);
                                    } else {
                                      selectedItems.add(snapshot
                                          .data.documents[index].documentID);
                                    }
                                  }
                                });
                              },
                              onLongPress: () {
                                setState(() {
                                  selectedItems.add(snapshot
                                      .data.documents[index].documentID);
                                  setState(() {
                                    onLongTapActive = true;
                                  });
                                });
                              },
                              child: Container(
                                color: (selectedItems.contains(snapshot
                                        .data.documents[index].documentID))
                                    ? Colors.deepOrange.withOpacity(0.5)
                                    : null,
                                child: ClipRRect(
                                    child: (snapshot.data.documents[index]
                                                ['uid'] ==
                                            widget.myUid)
                                        ? Align(
                                            alignment: Alignment.topRight,
                                            child: Container(
                                                margin: EdgeInsets.only(
                                                  top: 5,
                                                  left: 70,
                                                  right: 5,
                                                  bottom: 5,
                                                ),
                                                padding: EdgeInsets.all(14),
                                                decoration: BoxDecoration(
                                                    color: Colors.grey.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            18)),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: <Widget>[
                                                    Text(
                                                      snapshot
                                                          .data
                                                          .documents[index]
                                                          .data['message'],
                                                      style: TextStyle(
                                                        color: Colors
                                                            .grey.shade900,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 9,
                                                    ),
                                                    Text(
                                                      snapshot
                                                          .data
                                                          .documents[index]
                                                          .data['sentTime'],
                                                      style: TextStyle(
                                                        color: Colors
                                                            .grey.shade700,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      snapshot
                                                          .data
                                                          .documents[index]
                                                          .data['state']
                                                          .toString(),
                                                      style: TextStyle(
                                                          color: Colors
                                                              .deepOrange),
                                                    ),
                                                  ],
                                                )))
                                        : Align(
                                            alignment: Alignment.topRight,
                                            child: Container(
                                                margin: EdgeInsets.only(
                                                  top: 5,
                                                  left: 5,
                                                  right: 70,
                                                  bottom: 5,
                                                ),
                                                padding: EdgeInsets.all(14),
                                                decoration: BoxDecoration(
                                                  color:
                                                      Colors.deepOrangeAccent,
                                                  borderRadius:
                                                      BorderRadius.circular(18),
                                                ),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: <Widget>[
                                                    Text(
                                                      snapshot
                                                          .data
                                                          .documents[index]
                                                          .data['message'],
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 9,
                                                    ),
                                                    Text(
                                                      snapshot
                                                          .data
                                                          .documents[index]
                                                          .data['sentTime'],
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                )))),
                              ),
                            );
                          });
                    } else
                      return Text('');
                  }),
            )),
            Container(
              padding: EdgeInsets.all(5),
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      onChanged: (value) {
                        _enteredMessage = value;
                      },
                      decoration: InputDecoration(
                          focusColor: Colors.grey.shade100,
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade500)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade500)),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.all(9),
                          border: InputBorder.none,
                          prefixIcon: IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.perm_media),
                          ),
                          hintText: 'Type here...'),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.deepOrangeAccent,
                        borderRadius: BorderRadius.circular(30)),
                    child: IconButton(
                      color: Colors.white,
                      onPressed: () {
                        sendMessage();
                        _messageController.clear();
                      },
                      icon: Icon(
                        Icons.send,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }

  getBottomSheet() {
    _globalKey.currentState.showBottomSheet((context) {
      return Container(
        height: 306,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            )),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 18,
            ),
            ListTile(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return ProfileScreen(
                    myUid: widget.myUid,
                    name: widget.userName,
                    uid: widget.uid,
                    thumbUrl: widget.thumbnail,
                    status: widget.status,
                  );
                }));
              },
              leading: Icon(
                Icons.person,
                color: Colors.red,
                size: 30,
              ),
              title: Text(
                'Show Profile',
              ),
            ),
            ListTile(
              onTap: () {},
              leading: Icon(
                Icons.image,
                color: Colors.red,
                size: 30,
              ),
              title: Text('Change Background'),
            ),
            ListTile(
              onTap: () {
                deleteForMe().whenComplete(() {
                  Navigator.pop(context);
                }).whenComplete(() => Navigator.pop(context));
              },
              leading: Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 30,
              ),
              title: Text(
                'Delete for me',
              ),
            ),
            ListTile(
              onTap: () {
                deleteForEveryOne().whenComplete(() {
                  Navigator.pop(context);
                }).whenComplete(() => Navigator.pop(context));
              },
              leading: Icon(
                Icons.delete_forever,
                color: Colors.red,
                size: 30,
              ),
              title: Text(
                'Delete for everyone',
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.block,
                color: Colors.red,
                size: 30,
              ),
              title: Text(
                'Block',
              ),
            ),
          ],
        ),
      );
    });
  }

  setSeen(String id) {
    _userMessageReference
        .collection('messages')
        .document(id)
        .setData({'state': 3}, merge: true);
  }

  void sendMessage() async {
    var timestamp = DateTime.now().microsecondsSinceEpoch;
    var sentTime = TimeOfDay.now().format(context);

    _myMessageReference
        .collection('messages')
        .document(timestamp.toString())
        .setData({
      'message': _enteredMessage,
      'timestamp': timestamp,
      'seen': true,
      'uid': widget.myUid,
      'sentTime': sentTime,
      'state': 0,
    }).whenComplete(() {
      _myMessageReference.setData({
        'timestamp': timestamp,
      }, merge: true);
    });

    _userMessageReference
        .collection('messages')
        .document(timestamp.toString())
        .setData({
      'message': _enteredMessage,
      'timestamp': timestamp,
      'seen': false,
      'uid': widget.uid,
      'sentTime': sentTime
    }).whenComplete(() {
      _userMessageReference.setData({
        'timestamp': timestamp,
      }, merge: true);
    });
  }

  Future deleteForMe() async {
    _myMessageReference.collection('messages').getDocuments().then((value) {
      for (DocumentSnapshot doc in value.documents) {
        doc.reference.delete();
      }
    }).whenComplete(() => _myMessageReference.delete());
  }

  Future deleteForEveryOne() async {
    deleteForMe().whenComplete(() => _userMessageReference
            .collection('messages')
            .getDocuments()
            .then((value) {
          for (DocumentSnapshot doc in value.documents) {
            doc.reference.delete();
          }
        }).whenComplete(() => _userMessageReference.delete()));
  }

  getMessageTile(bool isMe) {
    return Container();
  }

  void deleteForEveryOneSingle() {}

  void deleteForMeSingle() {
    selectedItems.forEach((element) async {
      await _myMessageReference
          .collection('messages')
          .document(element)
          .delete();
      setState(() {
        selectedItems.remove(element);
      });
    });
  }
}
