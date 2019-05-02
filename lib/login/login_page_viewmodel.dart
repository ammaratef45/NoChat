import 'package:flutter/material.dart';
import 'package:no_chat/login/authentication.dart';
import 'package:no_chat/login/login_page.dart';

/// model of the login page
abstract class LoginPageViewModel extends State<LoginPage> {
  final BaseAuth _auth = Auth();
  /// user's email
  final String email = 'test@test.com';
  /// user's password
  final String password = '12345678';
  /// perform login
  Future<void> login() async {
    final String userId = await _auth.signIn(email, password);
    print('Signed in: $userId');
    await Navigator.of(context).pushReplacementNamed('/home');
  }
}