import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/screens/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Friends extends StatefulWidget {
  final String uid;

  const Friends({Key key, this.uid}) : super(key: key);
  @override
  _FriendsState createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  CollectionReference _usersRef;
  CollectionReference _friendReqRef;

  initRef() {
    _usersRef = Firestore.instance.collection('Users');
    _friendReqRef = _usersRef.document(widget.uid).collection('friends');
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
              builder: (context, friendSnap) {
                if (friendSnap.hasData) {
                  return ListView.builder(
                      shrinkWrap: true,
                      itemCount: friendSnap.data.documents.length,
                      itemBuilder: (_, index) {
                        return StreamBuilder<DocumentSnapshot>(
                            stream: _usersRef
                                .document(
                                    friendSnap.data.documents[index].documentID)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Container(
                                    margin: EdgeInsets.all(9),
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    child: ListTile(
                                        onTap: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(builder: (_) {
                                            return ProfileScreen(
                                              name: snapshot.data.data['name'],
                                              status:
                                                  snapshot.data.data['status'],
                                              thumbUrl: snapshot
                                                  .data.data['imageUrl'],
                                              uid: snapshot.data.documentID,
                                              myUid: widget.uid,
                                            );
                                          }));
                                        },
                                        title: Text(
                                          snapshot.data.data['name'],
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(
                                            'Since ${DateTime.fromMicrosecondsSinceEpoch(friendSnap.data.documents[index].data['timestamp']).day}/${DateTime.fromMicrosecondsSinceEpoch(friendSnap.data.documents[index].data['timestamp']).month}/${DateTime.fromMicrosecondsSinceEpoch(friendSnap.data.documents[index].data['timestamp']).year}'),
                                        leading: CircleAvatar(
                                          maxRadius: 27,
                                          minRadius: 27,
                                          backgroundColor: Colors.white,
                                          backgroundImage: snapshot
                                                      .data.data['imageUrl'] ==
                                                  'null'
                                              ? AssetImage(
                                                  'assets/circular_avatar.png')
                                              : CachedNetworkImageProvider(
                                                  snapshot
                                                      .data.data['imageUrl']),
                                        )));
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
