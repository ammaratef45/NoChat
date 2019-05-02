import 'package:flutter/material.dart';
import 'package:no_chat/login/login_page_viewmodel.dart';

/// view of login page
class LoginPageView extends LoginPageViewModel {
  static final TextStyle _style =
    TextStyle(fontFamily: 'Montserrat', fontSize: 20);

  TextField _emailField() => TextField(
    obscureText: true,
    style: _style,
    decoration: InputDecoration(
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: 'Email',
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(32))),
  );

  TextField _passwordField() => TextField(
    obscureText: true,
    style: _style,
    decoration: InputDecoration(
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: 'Password',
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(32))),
  );

  Material _loginButon() => Material(
    elevation: 5,
    borderRadius: BorderRadius.circular(30),
    color: const Color(0xff01A0C7),
    child: MaterialButton(
      minWidth: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
      onPressed: login,
      child: Text('Login',
          textAlign: TextAlign.center,
          style: _style.copyWith(
              color: Colors.white, fontWeight: FontWeight.bold)),
    ),
  );

  @override
  Widget build(BuildContext context) =>
    Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 155,
                  child: Image.asset(
                    'assets/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 45),
                _emailField(),
                const SizedBox(height: 25),
                _passwordField(),
                const SizedBox(
                  height: 35,
                ),
                _loginButon(),
                const SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
        ),
      ),
    );

}