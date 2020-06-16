import 'package:chatapp/models/chat_model.dart';
import 'package:chatapp/screens/message_screen.dart';
import 'package:chatapp/widgets/custom_widgets.dart';
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
  CustomWidgets _customWidgets = CustomWidgets();
  List<ChatsModel> _chatUsers = [];
  CollectionReference _chatsRef = Firestore.instance.collection('messages');
  DatabaseReference _usersRef =
      FirebaseDatabase.instance.reference().child('Users');

  getChatsData() {
    _chatsRef.document(widget.uid).snapshots().forEach((element) {
      _chatUsers = [];

      var sortedKeys = element.data.keys.toList()
        ..sort((a, b) {
          return element.data[a].compareTo(element.data[b]);
        });

      sortedKeys.forEach((element) async {
        getUsersData(element, await getLastMessage(element));
      });
    });
  }

  Future getLastMessage(String messagePath) async {
    var lastMessage;
    await _chatsRef
        .document(widget.uid)
        .collection(messagePath)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .getDocuments()
        .then((value) {
      value.documents.forEach((element) {
        lastMessage = element.data['message'];
      });
    });
    return lastMessage;
  }

  getUsersData(String uid, String lastMessage) async {
    _usersRef.child(uid).once().then((value) {
      setState(() {
        _chatUsers.add(ChatsModel(
          name: value.value['name'],
          thumbUrl: value.value['thumbUrl'],
          lastMessage: lastMessage,
          uid: uid,
        ));
      });

      print('Length  ${_chatUsers.length}');
    });
  }

  @override
  void initState() {
    getChatsData();
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
      appBar: _customWidgets.getCustomAppBar('Chats'),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder<DocumentSnapshot>(
                  stream: _chatsRef.document(widget.uid).snapshots(),
                  builder: (context, snapshot) {
                    return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _chatUsers.length,
                      itemBuilder: (_, index) {
                        return GestureDetector(
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) {
                            dispose();
                            return MessagingScreeen(
                              myUid: widget.uid,
                              profileUser: _chatUsers[index],
                            );
                          })),
                          child: _customWidgets.getDetailedCard(
                              _chatUsers[index].name,
                              _chatUsers[index].lastMessage,
                              'null'),
                        );
                      },
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }
}
