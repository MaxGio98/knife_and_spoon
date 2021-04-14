
import 'package:flutter/material.dart';
import 'package:knife_and_spoon/sign_in_screen.dart';
import 'package:knife_and_spoon/splashscreen.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterFire Samples',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        brightness: Brightness.dark,
      ),
      home: SplashScreen(),
    );
  }
}



