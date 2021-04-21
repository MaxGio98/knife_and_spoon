import 'dart:collection';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:knife_and_spoon/Assets/custom_colors.dart';
import 'package:knife_and_spoon/Pages/home_screen.dart';
import 'package:knife_and_spoon/Widgets/custom_alert_dialog.dart';
import 'package:uuid/uuid.dart';


Future<void> checkUsername(String newUsername, BuildContext context,
    User actualUser, String imageData) async {
  if (newUsername.trim().length < 5) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return buildCustomAlertOKDialog(context, "Attenzione", "Per favore utilizza uno username con almeno 5 caratteri.");
      },
    );
  } else {
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection("Utenti");
    usersCollection
        .where("Nome", isEqualTo: newUsername.trim())
        .get()
        .then((QuerySnapshot querySnapshot) async {
      if (querySnapshot.docs.isNotEmpty) {
        return showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return buildCustomAlertOKDialog(context, "Attenzione", "Questo username è già in uso.");
          },
        );
      } else {
        var uuid=Uuid().v4();
        List<String> preferiti = [];
        Map<String, Object> user = new HashMap();
        user["Mail"] = actualUser.email;
        user["Nome"] = newUsername.trim();
        user["isAdmin"] = false;
        user["Preferiti"] = preferiti;
        File image = File(imageData);
        FirebaseStorage storage = FirebaseStorage.instance;
        Reference storageRef = storage.ref();
        Reference imageRef = storageRef.child(uuid.toString() + ".jpg");
        await imageRef.putFile(image);
        await imageRef.getDownloadURL().then((url) {
          user["Immagine"] = url;
          FirebaseFirestore.instance
              .collection("Utenti")
              .add(user)
              .then((value) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => HomeScreen()));
          }).catchError((error) {
          });
        }).catchError((error) {
        });

        //Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => HomeScreen()));

      }
    });
  }
}
