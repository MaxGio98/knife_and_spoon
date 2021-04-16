import 'package:flutter/material.dart';
import 'package:knife_and_spoon/splashscreen.dart';

void main() {
  runApp(StartingPoint());
}

class StartingPoint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        brightness: Brightness.dark,
      ),
      home: SplashScreen(),
    );
  }
}
