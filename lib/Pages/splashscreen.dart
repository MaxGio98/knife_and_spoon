import 'dart:math';
import 'package:flutter/material.dart';
import 'package:knife_and_spoon/Assets/custom_colors.dart';
import 'package:knife_and_spoon/Pages/sign_in_screen.dart';
import 'package:knife_and_spoon/Utils/authentication.dart';
import 'package:knife_and_spoon/Utils/check_connection.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final splashDelay = 5;

  @override
  void initState() {
    super.initState();
    _setPhrase();
  }

  void navigationPage() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => SignInScreen()));
  }

  List<String> phrases = [
    "Affetto il ciauscolo...",
    "Scaldo l'acqua per la pasta...",
    "A tavola!",
    "Carbonara oggi?",
    "Si mangia!"
  ];
  String _phrase = "ciao";

  void _setPhrase() {
    final _random = new Random();
    setState(() {
      _phrase = phrases[_random.nextInt(phrases.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    Authentication.initializeFirebase(context: context);
    return CheckConnection(
      child: Scaffold(
        backgroundColor: CustomColors.red,
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 7,
                  child: Container(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/app_logo.png',
                        height: MediaQuery.of(context).size.height * (0.75),
                        width: MediaQuery.of(context).size.width * (0.75),
                      ),
                    ],
                  )),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: <Widget>[
                      CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(CustomColors.white)),
                      SizedBox(
                        height: 35,
                      ),
                      Text(
                        '$_phrase',
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * (.06),
                            color: CustomColors.white),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
