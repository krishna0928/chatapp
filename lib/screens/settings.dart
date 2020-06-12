import 'package:chatapp/Services/Authentication.dart';
import 'package:chatapp/screens/LoginScreen.dart';
import 'package:chatapp/widgets/custom_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  final String uid;

  const Settings({Key key, this.uid}) : super(key: key);
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Firestore _firestore = Firestore.instance;
  Stream userData;
  FirebaseUser _firebaseUser;
  FirebaseAuth _auth = FirebaseAuth.instance;

  initUserData() {
    userData =
        _firestore.collection('Users').document(widget.uid).get().asStream();

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
            stream: userData,
            builder: (_, snapshot) {
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
                print(snapshot.data.data['name']);
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
                    Container(
                      padding: EdgeInsets.all(10),
                      child: TextFormField(
                        onTap: () {
                          print('called');
                        },
                        enabled: true,
                        readOnly: true,
                        decoration: InputDecoration(
                          alignLabelWithHint: true,
                            labelText: snapshot.data.data['name'],
                            suffixIcon: Icon(Icons.edit),
                            hintText: 'tap to change'),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            snapshot.data.data['status'],
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 21),
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
