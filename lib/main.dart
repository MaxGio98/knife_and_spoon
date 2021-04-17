import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:knife_and_spoon/Assets/custom_colors.dart';
import 'package:knife_and_spoon/Pages/splashscreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(StartingPoint());
}

class StartingPoint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: CustomColors.red, // navigation bar color
      statusBarColor: CustomColors.red,
    ));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        brightness: Brightness.light,
      ),
      home: SplashScreen(),
    );
  }
}
