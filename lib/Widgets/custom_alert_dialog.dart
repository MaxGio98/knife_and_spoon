import 'package:flutter/material.dart';
import 'package:knife_and_spoon/Assets/custom_colors.dart';
import 'package:knife_and_spoon/Pages/sign_in_screen.dart';
import 'package:knife_and_spoon/Utils/authentication.dart';

Widget buildCustomAlertOKDialog(
    BuildContext context, String topText, String message) {
  return AlertDialog(
    backgroundColor: CustomColors.white,
    title: Text(
      topText,
      style: TextStyle(color: Colors.black),
    ),
    content: SingleChildScrollView(
      child: ListBody(
        children: <Widget>[
          Text(
            message,
            style: TextStyle(color: Colors.black),
          ),
        ],
      ),
    ),
    actions: <Widget>[
      TextButton(
        child: Text(
          'OK',
          style: TextStyle(color: CustomColors.red),
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    ],
  );
}

Widget buildConnectionAlertDialog(Function onPressed) {
  return AlertDialog(
    backgroundColor: CustomColors.white,
    title: Text(
      "Attenzione",
      style: TextStyle(color: Colors.black),
    ),
    content: SingleChildScrollView(
      child: ListBody(
        children: <Widget>[
          Text(
            "Nessuna connesione internet.",
            style: TextStyle(color: Colors.black),
          ),
        ],
      ),
    ),
    actions: <Widget>[
      TextButton(
        child: Text(
          'OK',
          style: TextStyle(color: CustomColors.red),
        ),
        onPressed:onPressed,
      ),
    ],
  );
}

Widget buildAnonymousDialogRegistration(
  BuildContext context,
) {
  return AlertDialog(
    backgroundColor: CustomColors.white,
    title: Text(
      "Attenzione",
      style: TextStyle(color: Colors.black),
    ),
    content: SingleChildScrollView(
      child: ListBody(
        children: <Widget>[
          Text(
            "Questa funzionalità è riservata solo agli utenti registrati.",
            style: TextStyle(color: Colors.black),
          ),
        ],
      ),
    ),
    actions: <Widget>[
      TextButton(
        child: Text(
          'Annulla',
          style: TextStyle(color: CustomColors.red),
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      TextButton(
        child: Text(
          'Fammi registrare!',
          style: TextStyle(color: CustomColors.red),
        ),
        onPressed: () async {
          await Authentication.signOut(context: context);
          Navigator.of(context).pushAndRemoveUntil(
              _routeToSignInScreen(), (Route<dynamic> route) => false);
        },
      ),
    ],
  );
}

Route _routeToSignInScreen() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SignInScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(-1.0, 0.0);
      var end = Offset.zero;
      var curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
