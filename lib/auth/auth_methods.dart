import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mentor_mind/auth/storage_methods.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //signup
  Future<String> signupUser({
    required String email,
    required String password,
    required String name,
    required String phone,
    required Uint8List image,
  }) async {
    String result = "some error occured";
    try {
      if (phone.length == 10 &&
          image != null &&
          name.isNotEmpty &&
          name.isNotEmpty &&
          password.isNotEmpty) {
        //register
        UserCredential credential = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        String photourl = await StorageMethods()
            .uploadImageStorage('profilepics', image, false);

        //add college to database
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'name': name,
          'email': email,
          'uid': credential.user!.uid,
          'rating': 0,
          'ratingCount': 0,
          'img': photourl,
        });
        result = "success";
      }
    } catch (err) {
      result = err.toString();
    }
    return result;
  }

  //login user
  Future<String> loginUser(
      {required String email, required String password}) async {
    String res = "some error occured";

    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = "success";
      } else {
        res = "Please enter all fields";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> signOut() async {
    final user = FirebaseAuth.instance.currentUser!;
    await _auth.signOut();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({"status": "offline"});
  }

  Future<void> likePost(String postId, String uid, List likes) async {
    try {
      final value = await FirebaseFirestore.instance
          .collection("events")
          .doc(postId)
          .get();

      likes = value.data()!["likes"];

      if (likes.contains(uid)) {
        await _firestore.collection('events').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore.collection('events').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {}
  }

  Future<void> addSubEventToList(String mainEventId, String subEventId) async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await _firestore
          .collection('participations')
          .doc(user.uid)
          .collection('conducted')
          .doc(mainEventId)
          .update({
        'subEventList': FieldValue.arrayUnion([subEventId]),
      });
    } catch (e) {}
  }

  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {}
  }
}
