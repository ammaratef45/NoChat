import 'package:flutter/material.dart';
import 'package:no_chat/home/home_page.dart';
import 'package:no_chat/login/login_page.dart';

void main() => runApp(MyApp());
/// running app
class MyApp extends StatelessWidget {
  final Widget _myHome = LoginPage();

  @override
  Widget build(BuildContext context) =>
    MaterialApp(
      title: 'NoChat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _myHome,
      routes: <String, WidgetBuilder>{
        '/login': (BuildContext context) => LoginPage(),
        '/home': (BuildContext context) => HomePage(),
      },
    );
}