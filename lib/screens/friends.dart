import 'package:chatapp/models/users.dart';
import 'package:chatapp/screens/profile_screen.dart';
import 'package:chatapp/widgets/custom_widgets.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Friends extends StatefulWidget {
  final String uid;

  const Friends({Key key, this.uid}) : super(key: key);
  @override
  _FriendsState createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  DatabaseReference _rootRef = FirebaseDatabase.instance.reference();
  DatabaseReference _friendsRef;
  DatabaseReference _usersRef;
  List<Users> _friendsList = [];
  bool loading = true;
  CustomWidgets _customWidgets = CustomWidgets();

  initRef() {
    _friendsRef = _rootRef.child('friends').child(widget.uid);
    _usersRef = _rootRef.child('Users');
    _usersRef.keepSynced(true);
    _friendsRef.keepSynced(true);
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
        appBar: _customWidgets.getCustomAppBar('Friends'),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30), topRight: Radius.circular(30))),
          child: StreamBuilder<Event>(
              stream: _friendsRef.orderByKey().onValue,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var _list = [];
                  snapshot.data.snapshot.value
                      .forEach((k, v) => _list.add((k)));

                  return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data.snapshot.value.length,
                      itemBuilder: (_, index) {
                        return StreamBuilder<Event>(
                            stream: _usersRef.child(_list[index]).onValue,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return GestureDetector(
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (_) {
                                        return ProfileScreen(
                                          userData: _friendsList[index],
                                          myUid: widget.uid,
                                        );
                                      }));
                                    },
                                    child: _customWidgets.getDetailedCard(
                                      snapshot.data.snapshot.value['name'],
                                      snapshot.data.snapshot.value['status'],
                                      snapshot.data.snapshot.value['thumbUrl'],
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
