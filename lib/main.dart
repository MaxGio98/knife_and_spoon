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
      systemNavigationBarColor: CustomColors.red,
      statusBarColor: CustomColors.red,
    ));
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        cursorColor: Colors.red,
        primarySwatch: MaterialColor(
          0xFFB10000,
          const <int, Color>{
            50: const Color(0xFFB10000),
            100: const Color(0xFFB10000),
            200: const Color(0xFFB10000),
            300: const Color(0xFFB10000),
            400: const Color(0xFFB10000),
            500: const Color(0xFFB10000),
            600: const Color(0xFFB10000),
            700: const Color(0xFFB10000),
            800: const Color(0xFFB10000),
            900: const Color(0xFFB10000),
          },
        ),
        brightness: Brightness.light,
        accentColor: CustomColors.red,
        accentColorBrightness: Brightness.light,
      ),
      home: SplashScreen(),
    );
  }
}
