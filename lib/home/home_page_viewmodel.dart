import 'package:flutter/material.dart';
import 'package:no_chat/home/home_page.dart';
import 'package:no_chat/login/authentication.dart';

/// model of the home page
abstract class HomePageViewModel extends State<HomePage> {
  /// constructor
  HomePageViewModel() {
    _loadUID();
  }

  final BaseAuth _auth = Auth();

  /// current user uid
  String currentUserId = '';

  Future<void> _loadUID() async {
    currentUserId = (await _auth.getCurrentUser()).uid;
    setState(() {
    });
  }
  /// handle loggin out
  void logout() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

}