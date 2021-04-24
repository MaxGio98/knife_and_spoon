import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:knife_and_spoon/Assets/custom_colors.dart';
import 'package:knife_and_spoon/Models/ricetta.dart';
import 'package:knife_and_spoon/Models/utente.dart';
import 'package:knife_and_spoon/Pages/ricetta_show_screen.dart';
import 'package:knife_and_spoon/Utils/check_connection.dart';
import 'package:knife_and_spoon/Widgets/ricetta_button.dart';

class ApproveRicettaScreen extends StatefulWidget {
  const ApproveRicettaScreen({Key key, @required Utente utente})
      : _utente = utente;
  final Utente _utente;

  @override
  _ApproveRicettaScreenState createState() => _ApproveRicettaScreenState();
}

class _ApproveRicettaScreenState extends State<ApproveRicettaScreen> {
  Utente _actualUser;
  List<Ricetta> _foundRecepies = [];
  bool _isLoading = false;

  @override
  void initState() {
    _actualUser = widget._utente;
    searchOnFirebase();
    super.initState();
  }

  void searchOnFirebase() async {
    _foundRecepies.clear();
    setState(() {
      _isLoading = true;
    });
    await FirebaseFirestore.instance
        .collection("Ricette")
        .where("isApproved", isEqualTo: false)
        .get()
        .then((QuerySnapshot querySnapshot) async {
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        Ricetta ricetta = new Ricetta(
            querySnapshot.docs[i].id,
            querySnapshot.docs[i].get("Autore"),
            querySnapshot.docs[i].get("Thumbnail"),
            querySnapshot.docs[i].get("Titolo"),
            querySnapshot.docs[i].get("NumeroPersone"),
            querySnapshot.docs[i].get("TempoPreparazione"),
            List<Map<String, dynamic>>.from(
                querySnapshot.docs[i].get("Ingredienti")),
            List<String>.from(querySnapshot.docs[i].get("Passaggi")),
            querySnapshot.docs[i].get("isApproved"),
            querySnapshot.docs[i].get("Timestamp"),
            querySnapshot.docs[i].get("Categoria"));
        _foundRecepies.add(ricetta);
      }
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return CheckConnection(
      child: SafeArea(
          child: Scaffold(
              appBar: AppBar(
                title: Text("Approva le ricette"),
              ),
              body: SingleChildScrollView(
                child: _isLoading
                    ? buildText("Sto cercando...")
                    : _foundRecepies.length != 0
                        ? RicettaButton(utente: _actualUser, ricette: _foundRecepies,onCase:(){
                  searchOnFirebase();
                })
                        : buildText("Nessuna ricetta da approvare"),
              ))),
    );
  }

  Widget buildText(String s) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
        height: height,
        width: width,
        child: Align(
            alignment: FractionalOffset.center,
            child: Text(
              s,
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: CustomColors.gray, fontSize: width * (.05)),
            )));
  }
}
