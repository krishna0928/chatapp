import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/screens/fullscreen_image.dart';
import 'package:chatapp/screens/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

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
  bool showEmoji = false;
  StorageReference _storage = FirebaseStorage.instance.ref().child('media');

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
                        onLongTapActive = false;
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
                                    widget.uid &&
                                snapshot.data.documents[index].data['state'] ==
                                    1) {
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
                                        if (selectedItems.length == 0) {
                                          onLongTapActive = false;
                                        }
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
                                                padding: EdgeInsets.all(9),
                                                decoration: BoxDecoration(
                                                    color: Colors.grey.shade100,
                                                    borderRadius: BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(18),
                                                        bottomRight:
                                                            Radius.circular(9),
                                                        bottomLeft:
                                                            Radius.circular(
                                                                18))),
                                                child: (snapshot
                                                            .data
                                                            .documents[index]
                                                            .data['type'] ==
                                                        'text')
                                                    ? Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: <Widget>[
                                                          Text(
                                                            snapshot
                                                                    .data
                                                                    .documents[
                                                                        index]
                                                                    .data[
                                                                'message'],
                                                            style: TextStyle(
                                                              color: Colors.grey
                                                                  .shade900,
                                                              fontSize: 18,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 9,
                                                          ),
                                                          Text(
                                                            snapshot
                                                                    .data
                                                                    .documents[
                                                                        index]
                                                                    .data[
                                                                'sentTime'],
                                                            style: TextStyle(
                                                              color: Colors.grey
                                                                  .shade700,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                          getIcon(snapshot
                                                              .data
                                                              .documents[index]
                                                              .data['state']),
                                                        ],
                                                      )
                                                    : Column(
                                                        children: <Widget>[
                                                          GestureDetector(
                                                            onTap: () {
                                                              if (!onLongTapActive) {
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (_) {
                                                                  return FullScreenImageView(
                                                                    url: snapshot
                                                                        .data
                                                                        .documents[
                                                                            index]
                                                                        .data['message'],
                                                                  );
                                                                }));
                                                              }
                                                            },
                                                            child:
                                                                CachedNetworkImage(
                                                              imageUrl: snapshot
                                                                      .data
                                                                      .documents[
                                                                          index]
                                                                      .data[
                                                                  'message'],
                                                              height: 100,
                                                              width: 100,
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 5),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: <
                                                                  Widget>[
                                                                Text(snapshot
                                                                        .data
                                                                        .documents[
                                                                            index]
                                                                        .data[
                                                                    'sentTime']),
                                                                SizedBox(
                                                                    width: 3),
                                                                getIcon(snapshot
                                                                    .data
                                                                    .documents[
                                                                        index]
                                                                    .data['state'])
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      )))
                                        : Align(
                                            alignment: Alignment.topLeft,
                                            child: Container(
                                                margin: EdgeInsets.only(
                                                  top: 5,
                                                  left: 5,
                                                  right: 70,
                                                  bottom: 5,
                                                ),
                                                padding: EdgeInsets.all(9),
                                                decoration: BoxDecoration(
                                                  color:
                                                      Colors.deepOrangeAccent,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topRight:
                                                              Radius.circular(
                                                                  18),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  9),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  18)),
                                                ),
                                                child: (snapshot
                                                            .data
                                                            .documents[index]
                                                            .data['type'] ==
                                                        'text')
                                                    ? Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: <Widget>[
                                                          Text(
                                                            snapshot
                                                                    .data
                                                                    .documents[
                                                                        index]
                                                                    .data[
                                                                'message'],
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 18,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 9,
                                                          ),
                                                          Text(
                                                            snapshot
                                                                    .data
                                                                    .documents[
                                                                        index]
                                                                    .data[
                                                                'sentTime'],
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    : GestureDetector(
                                                        onTap: () {
                                                          if (!onLongTapActive) {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (_) {
                                                              return FullScreenImageView(
                                                                url: snapshot
                                                                    .data
                                                                    .documents[
                                                                        index]
                                                                    .data['message'],
                                                              );
                                                            }));
                                                          }
                                                        },
                                                        child: Column(
                                                          children: <Widget>[
                                                            CachedNetworkImage(
                                                              imageUrl: snapshot
                                                                      .data
                                                                      .documents[
                                                                          index]
                                                                      .data[
                                                                  'message'],
                                                              height: 100,
                                                              width: 100,
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 5),
                                                              child: Text(
                                                                snapshot
                                                                        .data
                                                                        .documents[
                                                                            index]
                                                                        .data[
                                                                    'sentTime'],
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ))),
                                  ),
                                ));
                          });
                    } else
                      return Text('');
                  }),
            )),
            Container(
              padding: EdgeInsets.all(3),
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
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300)),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.all(9),
                          border: InputBorder.none,
                          prefixIcon: IconButton(
                            onPressed: () {},
                            icon: Icon(MdiIcons.emoticonOutline),
                          ),
                          suffixIcon: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.all(5),
                                child: GestureDetector(
                                  onTap: () async {
                                    File _file = await FilePicker.getFile(
                                      type: FileType.custom,
                                      allowedExtensions: ['jpg', 'png', 'jpeg'],
                                    );
                                    if (_file != null) {
                                      try {
                                        _storage
                                            .child(widget.uid)
                                            .putFile(_file)
                                            .onComplete
                                            .then((value) {
                                          value.ref
                                              .getDownloadURL()
                                              .then((value) async {
                                            sendMessage(
                                                type: 'image', url: value);
                                          });
                                        });
                                      } catch (e) {
                                        print(e);
                                      }
                                    }
                                  },
                                  child: Icon(MdiIcons.cameraOutline),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.all(5),
                                child: GestureDetector(
                                  child: Icon(MdiIcons.fileOutline),
                                ),
                              ),
                            ],
                          ),
                          hintText: 'Start Typing here...'),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      sendMessage(type: 'text');
                      _messageController.clear();
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: 9),
                      padding: EdgeInsets.all(9),
                      decoration: BoxDecoration(
                          color: Colors.deepOrangeAccent,
                          borderRadius: BorderRadius.circular(30)),
                      child: Icon(
                        MdiIcons.sendOutline,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }

  getIcon(int state) {
    switch (state) {
      case 0:
        return Icon(
          MdiIcons.clockOutline,
          size: 18,
          color: Colors.deepOrangeAccent,
        );
        break;
      case 1:
        return Icon(MdiIcons.check, size: 18, color: Colors.deepOrangeAccent);
        break;
      case 2:
        return Icon(MdiIcons.checkAll,
            size: 18, color: Colors.deepOrangeAccent);
        break;

      default:
        return Icon(MdiIcons.alert, size: 18, color: Colors.deepOrangeAccent);
        break;
    }
  }

  getBottomSheet() {
    _globalKey.currentState.showBottomSheet((context) {
      return Container(
        height: 252,
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
          ],
        ),
      );
    });
  }

  setSeen(String id) async {
    await _userMessageReference
        .collection('messages')
        .document(id)
        .setData({'state': 2}, merge: true);

    _myMessageReference.setData({'seen': true}, merge: true);
  }

  void sendMessage({String type, String url}) async {
    var timestamp = DateTime.now().microsecondsSinceEpoch;
    var sentTime = TimeOfDay.now().format(context);
    var messageMap;

    if (type == 'text') {
      messageMap = {
        'message': _enteredMessage,
        'timestamp': timestamp,
        'uid': widget.myUid,
        'sentTime': sentTime,
        'state': 0,
        'type': 'text'
      };
    } else if (type == 'image') {
      messageMap = {
        'message': url,
        'timestamp': timestamp,
        'uid': widget.myUid,
        'sentTime': sentTime,
        'state': 0,
        'type': 'image'
      };
    }

    _myMessageReference
        .collection('messages')
        .document(timestamp.toString())
        .setData(messageMap)
        .whenComplete(() {
      _myMessageReference
          .setData({'timestamp': timestamp, 'seen': true}, merge: true);
    });

    _userMessageReference
        .collection('messages')
        .document(timestamp.toString())
        .setData(messageMap)
        .whenComplete(() {
      _userMessageReference
          .setData({'timestamp': timestamp, 'seen': false}, merge: true);
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

  void deleteForEveryOneSingle() {
    selectedItems.forEach((element) async {
      await _userMessageReference
          .collection('messages')
          .document(element)
          .delete();
      await _myMessageReference
          .collection('messages')
          .document(element)
          .delete();

      setState(() {
        selectedItems.remove(element);
      });
    });
  }

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
