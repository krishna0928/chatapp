import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthServices {
  FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseReference _usersData =
      FirebaseDatabase.instance.reference().child('Users');

  String userID;

  Future registerWithEmailAndPass(
      String email, String password, String name) async {
    try {
      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) async {
        await _usersData.child(value.user.uid).set({
          'name': name,
          'status': 'Hey there , I\'m using Chatter',
          'thumbUrl': 'null',
          'imageUrl': 'null'
        });
        userID = value.user.uid;
      });
      return userID;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future signInWithEmailAndPass(String email, String password) async {
    try {
      await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) {
        if (value.user != null) {
          userID = value.user.uid;
        }
      });

      return userID;
    } catch (e) {
      print(e);
      return null;
    }
  }

  logout() {
    _auth.signOut();
  }
}
