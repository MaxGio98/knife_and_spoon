import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:knife_and_spoon/Assets/custom_colors.dart';
import 'package:knife_and_spoon/Pages/home_screen.dart';
import 'package:knife_and_spoon/Utils/authentication.dart';

class AnonymousSignInButton extends StatefulWidget {
  @override
  _AnonymousSignInButtonState createState() => _AnonymousSignInButtonState();
}

class _AnonymousSignInButtonState extends State<AnonymousSignInButton> {
  bool _isSigningIn = false;

  @override
  Widget build(BuildContext context) {
    return _isSigningIn
        ? CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(CustomColors.white),
          )
        : ElevatedButton(
            onPressed: () async {
              setState(() {
                _isSigningIn = true;
              });
              User user = await Authentication.signInAnonymously();
              setState(() {
                _isSigningIn = false;
              });
              if (user != null) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => HomeScreen()));
              }
            },
            child: Text(
              "Entra anonimamente",
              style: TextStyle(color: CustomColors.gray),
            ),
            style: ButtonStyle(
                shadowColor: MaterialStateProperty.all(Colors.transparent),
                backgroundColor:
                    MaterialStateProperty.all(Colors.transparent)));
  }
}
