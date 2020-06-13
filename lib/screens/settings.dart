import 'package:chatapp/Services/Authentication.dart';
import 'package:chatapp/screens/LoginScreen.dart';
import 'package:chatapp/widgets/custom_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  final String uid;

  const Settings({Key key, this.uid}) : super(key: key);
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  FirebaseUser _firebaseUser;
  DatabaseReference _userRef =
      FirebaseDatabase.instance.reference().child('Users');
  FirebaseAuth _auth = FirebaseAuth.instance;

  initUserData() {
    _userRef = _userRef.child(widget.uid);
    _auth.currentUser().then((value) => _firebaseUser = value);
  }

  @override
  void initState() {
    initUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          CustomAppBar(
            title: 'Settings',
          ),
          SizedBox(
            height: 30,
          ),
          StreamBuilder(
            stream: _userRef.onValue,
            builder: (_, AsyncSnapshot<Event> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 300,
                      ),
                      CircularProgressIndicator(),
                      SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                );
              } else {
                return Column(
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(),
                          alignment: Alignment.center,
                          child: CircleAvatar(
                            minRadius: 100,
                            maxRadius: 100,
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          right: 100,
                          child: IconButton(
                            icon: Icon(
                              Icons.photo_camera,
                              size: 50,
                            ),
                            onPressed: () {},
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            snapshot.data.snapshot.value['name'],
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 21),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            String updatedName;
                            showDialog(
                                context: context,
                                child: CupertinoAlertDialog(
                                  title: Text('Change Name'),
                                  content: Card(
                                    child: TextField(
                                      onChanged: (value) {
                                        updatedName = value;
                                      },
                                      decoration: InputDecoration(),
                                    ),
                                  ),
                                  actions: <Widget>[
                                    CupertinoDialogAction(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text('Cancel')),
                                    CupertinoDialogAction(
                                        onPressed: () async {
                                          if (updatedName.length > 3) {
                                            await _userRef
                                                .update({'name': updatedName});
                                            Navigator.pop(context);
                                          }
                                        },
                                        child: Text('Change')),
                                  ],
                                ));
                          },
                          icon: Icon(Icons.edit),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            snapshot.data.snapshot.value['status'],
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 21),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            String updatedStatus;
                            showDialog(
                                context: context,
                                child: CupertinoAlertDialog(
                                  title: Text('Change Status'),
                                  content: Card(
                                    child: TextField(
                                      onChanged: (value) {
                                        updatedStatus = value;
                                      },
                                      decoration: InputDecoration(),
                                    ),
                                  ),
                                  actions: <Widget>[
                                    CupertinoDialogAction(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text('Cancel')),
                                    CupertinoDialogAction(
                                        onPressed: () async {
                                          if (updatedStatus.length > 6) {
                                            await _userRef.update(
                                                {'status': updatedStatus});
                                            Navigator.pop(context);
                                          }
                                        },
                                        child: Text('Change')),
                                  ],
                                ));
                          },
                          icon: Icon(Icons.edit),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            _firebaseUser.email,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.edit),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            'xxxxxxxx',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.edit),
                        )
                      ],
                    ),
                  ],
                );
              }
            },
          ),
          RaisedButton(
            onPressed: () {
              AuthServices().logout();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) {
                return LoginPage();
              }));
            },
            child: Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
            color: Colors.redAccent,
          )
        ],
      ),
    );
  }
}
