import 'package:flutter/material.dart';
import 'package:knife_and_spoon/Assets/custom_colors.dart';

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
