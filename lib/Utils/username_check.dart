import 'dart:collection';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:knife_and_spoon/Assets/custom_colors.dart';
import 'package:knife_and_spoon/Pages/home.dart';


Future<void> checkUsername(String newUsername, BuildContext context,
    User actualUser, String imageData) async {
  if (newUsername.length < 5) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: CustomColors.white,
          title: Text(
            'Attenzione',
            style: TextStyle(color: Colors.black),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Per favore utilizza uno username con almeno 5 caratteri',
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
      },
    );
  } else {
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection("Utenti");
    usersCollection
        .where("Nome", isEqualTo: newUsername)
        .get()
        .then((QuerySnapshot querySnapshot) async {
      if (querySnapshot.docs.isNotEmpty) {
        return showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: CustomColors.white,
              title: Text(
                'Attenzione',
                style: TextStyle(color: Colors.black),
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(
                      'Questo username è già in uso.',
                      style: TextStyle(color: Colors.black),
                    ),
                    Text(
                      'Per favore usane un altro.',
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
          },
        );
      } else {
        List<String> preferiti = [];
        Map<String, Object> user = new HashMap();
        user["Mail"] = actualUser.email;
        user["Nome"] = newUsername;
        user["isAdmin"] = false;
        user["Preferiti"] = preferiti;
        File image = File(imageData);
        FirebaseStorage storage = FirebaseStorage.instance;
        Reference storageRef = storage.ref();
        Reference imageRef = storageRef.child(newUsername + ".jpg");
        imageRef.putFile(image);
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
            //da inserire alert errore
          });
        }).catchError((error) {
          //da inserire alert errore
        });

        //Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => HomeScreen()));

      }
    });
  }
}
