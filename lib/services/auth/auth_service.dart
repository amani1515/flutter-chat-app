import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class AuthService extends ChangeNotifier{
  final FirebaseAuth _firebaseAuth= FirebaseAuth.instance;
  //instance of fire store
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  // sign in
Future<UserCredential>signInWithEmailAndPassword(String email,String password) async{
  try{
    //sign in
    UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);

    // add anew document for the user in user collection if it doesn't already exists
    _fireStore.collection('Users').doc(userCredential.user!.uid).set({
      'uid' : userCredential.user!.uid,
      'email': email,
    }, SetOptions(merge: true)
    );
    return userCredential;
  }
  on FirebaseAuthException catch (e) {
    throw Exception(e.code);
  }
  }
  // create a new user
  Future<UserCredential> signUpWithEmailandPassword(String email,password) async{
  try {
      UserCredential userCredential =
      await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password);
      // after creating the user, create new document
      _fireStore.collection('Users').doc(userCredential.user!.uid).set({
        'uid' : userCredential.user!.uid,
        'email': email,
      });
      return userCredential;
  }on FirebaseAuthException catch (e){
    throw Exception(e.code);
  }
  }


  //sign out

  Future<void>signOut()async{
  return await FirebaseAuth.instance.signOut();
  }
}



