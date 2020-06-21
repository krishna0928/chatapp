import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

class AuthServices {
  FirebaseAuth _auth = FirebaseAuth.instance;
  CollectionReference _usersRef = Firestore.instance.collection('Users');
  StreamingSharedPreferences _sharedPreferences;

  Future registerWithEmailAndPass(
      String email, String password, String name) async {
    AuthResult result;

    try {
      result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      await _usersRef.document(result.user.uid).setData({
        'name': name,
        'status': 'Hey there , I\'m using Chatter',
        'thumbUrl': 'null',
        'imageUrl': 'null',
        'online': true,
      });

      _sharedPreferences = await StreamingSharedPreferences.instance;
      await _sharedPreferences.setString('UID', result.user.uid);
      _sharedPreferences.setString('NAME', name);

      return true;
    } catch (error) {
      return error.toString();
    }
  }

  Future signInWithEmailAndPass(String email, String password) async {
    AuthResult result;

    try {
      result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      _sharedPreferences = await StreamingSharedPreferences.instance;
      await _sharedPreferences.setString('UID', result.user.uid);
      await _usersRef.document(result.user.uid).get().then((value) {
        _sharedPreferences.setString('IMAGE', value.data['imageUrl']);
        _sharedPreferences.setString('NAME', value.data['name']);
      });

      return true;
    } catch (error) {
      return error.toString();
    }
  }

  Future changeEmail(String email, String password) async {
    dynamic result = false;

    result = await _auth.currentUser().then((value) async {
      try {
        var result = await signInWithEmailAndPass(value.email, password);
        if (result == true) {
          await value.updateEmail(email);
          return true;
        } else {
          return false;
        }
      } catch (e) {
        return false;
      }
    });

    return result;
  }

  Future resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
    return true;
  }

  logout() async {
    _sharedPreferences = await StreamingSharedPreferences.instance;
    _sharedPreferences.clear();
    _auth.signOut();
  }
}
