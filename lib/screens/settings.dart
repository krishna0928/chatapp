import 'dart:io';

import 'package:chatapp/Services/Authentication.dart';
import 'package:chatapp/screens/LoginScreen.dart';
import 'package:chatapp/widgets/custom_widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  final String uid;

  const Settings({Key key, this.uid}) : super(key: key);
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  CustomWidgets _customWidgets = CustomWidgets();
  File _file;
  StorageReference _storage =
      FirebaseStorage.instance.ref().child('profile_pictures');
  FirebaseUser _firebaseUser;
  DatabaseReference _userRef =
      FirebaseDatabase.instance.reference().child('Users');
  FirebaseAuth _auth = FirebaseAuth.instance;

  initUserData() {
    _userRef.child(widget.uid).keepSynced(true);
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
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: _customWidgets.getCustomAppBar('Settings'),
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
              SizedBox(
                height: 30,
              ),
              StreamBuilder(
                stream: _userRef.onValue,
                builder: (context, snapshot) {
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
                    return Column(children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Container(
                            alignment: Alignment.center,
                            child: Column(
                              children: <Widget>[
                                CircleAvatar(
                                  backgroundColor: Colors.white,
                                  backgroundImage: (snapshot.data.snapshot
                                              .value['imageUrl'] ==
                                          'null')
                                      ? AssetImage('assets/circular_avatar.png')
                                      : NetworkImage(snapshot
                                          .data.snapshot.value['imageUrl']),
                                  minRadius: 10,
                                  maxRadius: 100,
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 115,
                            child: IconButton(
                              icon: Icon(
                                Icons.photo_camera,
                                color: Colors.deepOrangeAccent,
                                size: 50,
                              ),
                              onPressed: () async {
                                print('pressed');
                                _file = await FilePicker.getFile(
                                  type: FileType.custom,
                                  allowedExtensions: ['jpg', 'png', 'jpeg'],
                                );
                                if (_file != null) {
                                  _storage
                                      .child(widget.uid)
                                      .putFile(_file)
                                      .onComplete
                                      .then((value) {
                                    value.ref.getDownloadURL().then((value) =>
                                        _userRef.child('imageUrl').set(value));
                                  });
                                }
                              },
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
                              String updateName;
                              showBottomSheet(
                                  backgroundColor:
                                      Colors.orange.withOpacity(0.5),
                                  context: (context),
                                  builder: (_) {
                                    return Container(
                                      padding: EdgeInsets.all(18),
                                      height: 180,
                                      decoration: BoxDecoration(
                                          color: Colors.orangeAccent,
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(30),
                                              topRight: Radius.circular(30))),
                                      child: Column(
                                        children: <Widget>[
                                          Text(
                                            'Change name',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 21),
                                          ),
                                          TextField(
                                            onChanged: (value) {
                                              updateName = value;
                                            },
                                            decoration: InputDecoration(
                                                border: InputBorder.none,
                                                hintText: 'Enter your name',
                                                hintStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                )),
                                          ),
                                          SizedBox(
                                            height: 18,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              FlatButton(
                                                color: Colors.redAccent,
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text('Cancel'),
                                              ),
                                              FlatButton(
                                                color: Colors.greenAccent,
                                                onPressed: () {
                                                  _userRef
                                                      .child('name')
                                                      .set(updateName);
                                                  Navigator.pop(context);
                                                },
                                                child: Text('Update'),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    );
                                  });

                              /* showDialog(
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
                                  )); */
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
                                            if (updatedStatus.length > 0) {
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
                    ]);
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
        ),
      ),
    );
  }
}
