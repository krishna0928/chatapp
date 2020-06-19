import 'package:chatapp/screens/profile_screen.dart';
import 'package:chatapp/widgets/custom_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FriendRequest extends StatefulWidget {
  final uid;

  const FriendRequest({Key key, this.uid}) : super(key: key);

  @override
  _FriendRequestState createState() => _FriendRequestState();
}

class _FriendRequestState extends State<FriendRequest> {
  CustomWidgets _customWidgets = CustomWidgets();
  CollectionReference _usersRef;
  CollectionReference _friendReqRef;

  initRef() {
    _usersRef = Firestore.instance.collection('Users');
    _friendReqRef = _usersRef.document(widget.uid).collection('requests');
  }

  @override
  void initState() {
    initRef();
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
              stream: _friendReqRef.snapshots(),
              builder: (context, reqSnap) {
                if (reqSnap.hasData) {
                  return ListView.builder(
                      shrinkWrap: true,
                      itemCount: reqSnap.data.documents.length,
                      itemBuilder: (_, index) {
                        return StreamBuilder<DocumentSnapshot>(
                            stream: _usersRef
                                .document(
                                    reqSnap.data.documents[index].documentID)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return GestureDetector(
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (_) {
                                        return ProfileScreen(
                                          name: snapshot.data.data['name'],
                                          status: snapshot.data.data['status'],
                                          thumbUrl:
                                              snapshot.data.data['thumbUrl'],
                                          uid: snapshot.data.documentID,
                                          myUid: widget.uid,
                                        );
                                      }));
                                    },
                                    child: _customWidgets.getDetailedCard(
                                      snapshot.data.data['name'],
                                      'Request ${reqSnap.data.documents[index].data['reqType']}',
                                      snapshot.data.data['thumbUrl'],
                                    ));
                              } else {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            });
                      });
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
        ));
  }
}
