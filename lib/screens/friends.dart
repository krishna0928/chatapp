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

  intiFriendsData() async {
    await _friendsRef.once().then((value) {
      if (value.value != null) {
        value.value.forEach((key, value) {
          userDataFromKey(key);
        });
      }
    });
    setState(() {
      loading = false;
    });
  }

  userDataFromKey(String key) async {
    await _usersRef.child(key).once().then((value) {
      setState(() {
        _friendsList.add(Users(
            name: value.value['name'],
            imageUrl: value.value['imageUrl'],
            thumbUrl: value.value['thumbUrl'],
            status: value.value['status'],
            uid: key));
      });
    });
  }

  initRef() {
    _friendsRef = _rootRef.child('friends').child(widget.uid);
    _usersRef = _rootRef.child('Users');
  }

  @override
  void initState() {
    initRef();
    intiFriendsData();
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
          child: loading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _friendsList.length,
                  itemBuilder: (_, index) {
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
                            _friendsList[index].name,
                            _friendsList[index].status,
                            _friendsList[index].thumbUrl));
                  }),
        ));
  }
}
