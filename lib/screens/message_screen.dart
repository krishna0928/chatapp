import 'package:chatapp/widgets/convers_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MessagingScreeen extends StatefulWidget {
  final myUid;
  final userName, thumbnail, uid;

  const MessagingScreeen(
      {Key key, this.myUid, this.thumbnail, this.uid, this.userName})
      : super(key: key);
  @override
  _MessagingScreeenState createState() => _MessagingScreeenState();
}

class _MessagingScreeenState extends State<MessagingScreeen> {
  String _enteredMessage;
  DocumentReference _myMessageReference;
  DocumentReference _userMessageReference;
  Stream _messageStream;

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
          name: widget.userName,
          thumbUrl: 'null',
          onlineStatus: null,
        ),
        body: Column(
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
                      return ListView.builder(
                          reverse: true,
                          padding: EdgeInsets.only(top: 10),
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (_, index) {
                            return ClipRRect(
                                child: Align(
                                    alignment: snapshot.data.documents[index]
                                                ['uid'] ==
                                            widget.myUid
                                        ? Alignment.topRight
                                        : Alignment.topLeft,
                                    child: Container(
                                        margin: snapshot.data.documents[index]
                                                    ['uid'] ==
                                                widget.myUid
                                            ? EdgeInsets.only(
                                                top: 5,
                                                left: 70,
                                                right: 5,
                                                bottom: 5,
                                              )
                                            : EdgeInsets.only(
                                                top: 5,
                                                left: 5,
                                                right: 70,
                                                bottom: 5,
                                              ),
                                        padding: EdgeInsets.all(9),
                                        decoration: BoxDecoration(
                                            color: Colors.deepOrangeAccent,
                                            borderRadius:
                                                BorderRadius.circular(18)),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Text(
                                              snapshot.data.documents[index]
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
                                              snapshot.data.documents[index]
                                                  .data['sentTime'],
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ))));
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
      'sentTime': sentTime
    }).whenComplete(() {
      _myMessageReference.setData({
        'timestamp': timestamp,
      }, merge: true);
    });

    _userMessageReference
        .collection(widget.myUid)
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
}
