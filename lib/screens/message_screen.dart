import 'package:chatapp/models/message.dart';
import 'package:chatapp/screens/chats.dart';
import 'package:chatapp/widgets/chat_bubble.dart';
import 'package:chatapp/widgets/convers_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MessagingScreeen extends StatefulWidget {
  final String myUid;
  final dynamic profileUser;

  const MessagingScreeen({Key key, this.myUid, this.profileUser})
      : super(key: key);
  @override
  _MessagingScreeenState createState() => _MessagingScreeenState();
}

class _MessagingScreeenState extends State<MessagingScreeen> {
  String _enteredMessage;
  Firestore _rootReference = Firestore.instance;
  DocumentReference _myMessageReference;
  DocumentReference _userMessageReference;
  CollectionReference _messageRef;
  Stream _messageStream;

  final _messageController = TextEditingController();

  Future<void> initData() async {
    _messageRef = _rootReference.collection('messages');

    _myMessageReference = _messageRef.document(widget.myUid);

    _userMessageReference = _messageRef.document(widget.profileUser.uid);

    _messageStream = _myMessageReference
        .collection(widget.profileUser.uid)
        .orderBy('timestamp', descending: true)
        .limit(25)
        .snapshots();
  }

  @override
  void initState() {
    initData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: ConversAppBar(
          name: widget.profileUser.name,
          thumbUrl: widget.profileUser.thumbUrl,
          onlineStatus: null,
        ),
        body: WillPopScope(
          onWillPop: () async {
            pushReplacement();
            return true;
          },
          child: Column(
            children: <Widget>[
              Expanded(
                  child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30)),
                    color: Colors.white),
                child: StreamBuilder<QuerySnapshot>(
                    stream: _messageStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.waiting) {
                        if (snapshot.data.documents != null) {
                          List<Messages> _messageList = [];

                          snapshot.data.documents.every((element) {
                            _messageList.add(Messages(
                                pushId: element.documentID,
                                message: element['message'],
                                time: element['timestamp'].toString(),
                                seen: element['seen'],
                                uid: element['uid']));
                            return true;
                          });

                          return ListView.builder(
                              reverse: true,
                              padding: EdgeInsets.only(top: 10),
                              itemCount: _messageList.length,
                              itemBuilder: (_, index) {
                                return ClipRRect(
                                  child: ChatBuble(
                                    message: _messageList[index].message,
                                  ),
                                );
                              });
                        } else {
                          return Text('');
                        }
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
          ),
        ));
  }

  void sendMessage() async {
    var pushID = _myMessageReference
        .collection(widget.profileUser.uid)
        .document()
        .documentID;

    _myMessageReference
        .collection(widget.profileUser.uid)
        .document(pushID)
        .setData({
      'message': _enteredMessage,
      'timestamp': DateTime.now().microsecondsSinceEpoch,
      'seen': true,
      'uid': widget.myUid
    }).then((value) {
      _myMessageReference.setData({
        widget.profileUser.uid: DateTime.now().microsecondsSinceEpoch,
      });
    });

    _userMessageReference.collection(widget.myUid).document(pushID).setData({
      'message': _enteredMessage,
      'timestamp': DateTime.now().microsecondsSinceEpoch,
      'seen': false,
      'uid': widget.profileUser.uid
    }).then((value) {
      _userMessageReference.setData({
        widget.myUid: DateTime.now().microsecondsSinceEpoch,
      });
    });
  }

  void pushReplacement() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) {
      dispose();
      return Chats(
        uid: widget.myUid,
      );
    }));
  }
}
