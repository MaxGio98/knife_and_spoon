import 'package:flutter/material.dart';





class LoginRoute extends StatelessWidget
{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Route"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
          },
          child: Text('Sign in with Google'),
        ),
      ),
    );
  }
}