import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/Services/Authentication.dart';
import 'package:chatapp/screens/fullscreen_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

class Settings extends StatefulWidget {
  final String uid;
  final bool darkTheme;

  const Settings({Key key, this.uid, this.darkTheme}) : super(key: key);
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  File _file;
  StorageReference _storage =
      FirebaseStorage.instance.ref().child('profile_pictures');
  FirebaseUser _firebaseUser;
  DocumentReference _usersRef;
  FirebaseAuth _auth = FirebaseAuth.instance;
  StreamingSharedPreferences _pref;

  initUserData() async {
    _usersRef = Firestore.instance.collection('Users').document(widget.uid);
    await _auth.currentUser().then((value) => _firebaseUser = value);
    _pref = await StreamingSharedPreferences.instance;
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
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30), topRight: Radius.circular(30))),
          child: StreamBuilder<DocumentSnapshot>(
            stream: _usersRef.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return SingleChildScrollView(
                  child: Column(children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Stack(
                          overflow: Overflow.visible,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(top: 18, left: 10),
                              alignment: Alignment.topLeft,
                              child: GestureDetector(
                                onTap: () async {
                                  if (snapshot.data.data['imageUrl'] !=
                                      'null') {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (_) {
                                      return FullScreenImageView(
                                        url: snapshot.data.data['imageUrl'],
                                      );
                                    }));
                                  }
                                },
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  backgroundImage: (snapshot
                                              .data.data['imageUrl'] ==
                                          'null')
                                      ? AssetImage('assets/circular_avatar.png')
                                      : CachedNetworkImageProvider(
                                          snapshot.data.data['imageUrl']),
                                  minRadius: 50,
                                  maxRadius: 50,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -10,
                              left: 70,
                              child: IconButton(
                                icon: Icon(
                                  Icons.camera_alt,
                                  color: Colors.blueGrey,
                                  size: 36,
                                ),
                                onPressed: () {
                                  changeProfilePicture();
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 18,
                    ),
                    GestureDetector(
                        onTap: () {
                          getDymamicSheet('name');
                        },
                        child: getApproprateTile(snapshot.data.data['name'])),
                    GestureDetector(
                        onTap: () {
                          getDymamicSheet('status');
                        },
                        child: getApproprateTile(snapshot.data.data['status'])),
                    GestureDetector(
                        onTap: () {
                          getEmailSheet();
                        },
                        child: getApproprateTile(_firebaseUser.email)),
                    GestureDetector(
                        onTap: () async {
                          await AuthServices()
                              .resetPassword(_firebaseUser.email);
                          Scaffold.of(context).showSnackBar(SnackBar(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(18),
                              topRight: Radius.circular(18),
                            )),
                            backgroundColor: Colors.deepOrangeAccent,
                            content: Text(
                              'A reset link has sent to your email',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ));
                        },
                        child: getApproprateTile('Change Password')),
                    Container(
                      margin: EdgeInsets.all(9),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(30)),
                      child: ListTile(
                        title: Text('Dark theme'),
                        trailing: Switch(
                          onChanged: (bool value) {
                            _pref.setBool('DARKTHEME', value);
                            Phoenix.rebirth(context);
                          },
                          value: widget.darkTheme,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(9),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(30)),
                      child: ListTile(
                        title: Text('Show Online'),
                        trailing: Switch(
                          onChanged: (bool value) {
                            _usersRef.setData({'online': value}, merge: true);
                          },
                          value: snapshot.data.data['online'],
                        ),
                      ),
                    ),
                  ]),
                );
              }
            },
          ),
        ));
  }

  getApproprateTile(String title) {
    return Container(
      margin: EdgeInsets.all(9),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: Colors.grey.shade200, borderRadius: BorderRadius.circular(30)),
      child: ListTile(
          title: Text(
            title,
          ),
          trailing: Icon(
            Icons.edit,
            color: Colors.deepOrange,
            size: 18,
          )),
    );
  }

  changeProfilePicture() async {
    _file = await FilePicker.getFile(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg'],
    );
    if (_file != null) {
      try {
        _storage.child(widget.uid).putFile(_file).onComplete.then((value) {
          value.ref.getDownloadURL().then((value) async {
            await _usersRef.setData({'imageUrl': value}, merge: true);
            await _pref.setString('IMAGE', value);
            print(_pref.getString('IMAGE', defaultValue: '').getValue());
            Phoenix.rebirth(context);
          });
        });
      } catch (e) {
        print(e);
      }
    }
  }

  getEmailSheet() {
    String email;
    String password;

    showBottomSheet(
        context: (context),
        builder: (_) {
          return Container(
            height: 360,
            padding: EdgeInsets.all(9),
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30))),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Text(
                    'Change Email',
                    style: TextStyle(
                      color: Colors.deepOrangeAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 21,
                    ),
                  ),
                ),
                TextField(
                  onChanged: (value) {
                    email = value;
                  },
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(left: 18),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Colors.grey,
                          )),
                      border: InputBorder.none,
                      hintText: 'Enter your new email',
                      hintStyle: TextStyle(
                        color: Colors.deepOrangeAccent,
                        fontSize: 18,
                      )),
                ),
                SizedBox(
                  height: 18,
                ),
                TextField(
                  onChanged: (value) {
                    password = value;
                  },
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(left: 18),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Colors.grey,
                          )),
                      border: InputBorder.none,
                      hintText: 'Enter your password',
                      hintStyle: TextStyle(
                        color: Colors.deepOrangeAccent,
                        fontSize: 18,
                      )),
                ),
                SizedBox(
                  height: 18,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FlatButton(
                      color: Colors.red.withOpacity(0.7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    FlatButton(
                      color: Colors.green.withOpacity(0.7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      onPressed: () async {
                        await AuthServices().changeEmail(email, password);
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Update',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 18,
                ),
              ],
            ),
          );
        });
  }

  getDymamicSheet(which) {
    String text;
    showBottomSheet(
        context: (context),
        builder: (_) {
          return Container(
            height: 270,
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                )),
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(vertical: 18),
                  child: Text(
                    'Update $which',
                    style: TextStyle(
                        color: Colors.deepOrangeAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 21),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    onChanged: (value) {
                      text = value;
                    },
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(left: 9),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(color: Colors.grey.shade900),
                        ),
                        border: InputBorder.none,
                        hintText: 'Enter your $which',
                        hintStyle: TextStyle(
                          color: Colors.deepOrangeAccent,
                          fontSize: 18,
                        )),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      color: Colors.redAccent.withOpacity(0.7),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Cancel'),
                    ),
                    FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      color: Colors.greenAccent.withOpacity(0.7),
                      onPressed: () {
                        _usersRef.setData({'$which': text}, merge: true);
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
  }
}
