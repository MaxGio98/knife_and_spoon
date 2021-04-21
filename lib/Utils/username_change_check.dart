import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:knife_and_spoon/Models/utente.dart';
import 'package:knife_and_spoon/Widgets/custom_alert_dialog.dart';

Future<void> checkChangeUsername(
    String newUsername, BuildContext context, Utente actualUser) async {
  if (newUsername.length < 5) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return buildCustomAlertOKDialog(context, "Attenzione",
            "Per favore utilizza uno username con almeno 5 caratteri.");
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
            barrierDismissible: false,
            builder: (BuildContext context) {
              return buildCustomAlertOKDialog(
                  context, "Attenzione", "Questo username è già in uso.");
            });
      } else {
        FirebaseFirestore.instance
            .collection("Utenti")
            .doc(actualUser.id)
            .update({'Nome': newUsername}).then((value) async {
          actualUser.nome = newUsername;
          Navigator.pop(context);
          return showDialog<void>(
              context: context,
              barrierDismissible: false, // user must tap button!
              builder: (BuildContext context) {
                return buildCustomAlertOKDialog(
                    context, "", "Username cambiato con successo");
              });
        });
      }
    });
  }
}
