import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

/// authentication interface
abstract class BaseAuth {
  /// sign in with username and password
  Future<String> signIn(String email, String password);

  /// sign up with username and password
  Future<String> signUp(String email, String password);

  /// get current signedin user
  Future<FirebaseUser> getCurrentUser();

  /// send verification mail
  Future<void> sendEmailVerification();

  /// sign out current user
  Future<void> signOut();

  /// check if email verified
  Future<bool> isEmailVerified();
}

/// auth implementation
class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  
  @override
  Future<String> signIn(String email, String password) async {
    final FirebaseUser user = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    return user.uid;
  }

  @override
  Future<String> signUp(String email, String password) async {
    final FirebaseUser user = 
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password
      );
    return user.uid;
  }

  @override
  Future<FirebaseUser> getCurrentUser() async {
    final FirebaseUser user = await _firebaseAuth.currentUser();
    return user;
  }

  @override
  Future<void> signOut() async => _firebaseAuth.signOut();

  @override
  Future<void> sendEmailVerification() async {
    final FirebaseUser user = await _firebaseAuth.currentUser();
    await user.sendEmailVerification();
  }

  @override
  Future<bool> isEmailVerified() async {
    final FirebaseUser user = await _firebaseAuth.currentUser();
    return user.isEmailVerified;
  }

}