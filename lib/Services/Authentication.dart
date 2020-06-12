import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  FirebaseAuth _auth = FirebaseAuth.instance;
  Firestore _firestore = Firestore.instance;

  Future registerWithEmailAndPass(
      String email, String password, String name) async {
    try {
      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) async {
        await _firestore.collection('Users').document(value.user.uid).setData({
          'name': name,
          'status': 'Hey there , I\'m using Chatter',
          'thumbUrl': 'null',
          'imageUrl': 'null'
        });
      });
      return true;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future signInWithEmailAndPass(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      return true;
    } catch (e) {
      print(e);
      return null;
    }
  }

  logout() {
    _auth.signOut();
  }
}
