import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:knife_and_spoon/Assets/custom_colors.dart';
import 'package:permission_handler/permission_handler.dart';

Widget buildWarningPermissions(BuildContext context)
{
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
            "Per favore autorizza tutto.",
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
          _closePopup(context);
        },
      ),
      TextButton(
        child: Text(
          'Impostazioni',
          style: TextStyle(color: CustomColors.red),
        ),
        onPressed: () {
          _openPermissionSettings(context);
        },
      ),


    ],
  );
}

_openPermissionSettings(BuildContext context) async {
  await openAppSettings();
  _closePopup(context);
}

_closePopup(BuildContext context) {
  Navigator.of(context).pop();
}