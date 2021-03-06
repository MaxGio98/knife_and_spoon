import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:knife_and_spoon/Assets/custom_colors.dart';
import 'package:knife_and_spoon/Models/ricetta.dart';
import 'package:knife_and_spoon/Models/utente.dart';
import 'package:knife_and_spoon/Pages/ricetta_show_screen.dart';
import 'package:knife_and_spoon/Utils/check_connection.dart';
import 'package:knife_and_spoon/Widgets/ricetta_button.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({Key key, @required Utente utente})
      : _utente = utente,
        super(key: key);
  final Utente _utente;

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  Utente _actualUser;
  List<Ricetta> ricetteFav = [];
  bool _loadedRicette = false;

  @override
  void initState() {
    _actualUser = widget._utente;
    loadFavFromFirebase();
    super.initState();
  }

  void loadFavFromFirebase() async {
    ricetteFav.clear();
    if (_actualUser.preferiti.length > 0) {
      for (int i = 0; i < _actualUser.preferiti.length; i++) {
        await FirebaseFirestore.instance
            .collection("Ricette")
            .doc(_actualUser.preferiti[i])
            .get()
            .then((DocumentSnapshot documentSnapshot) async {
          Ricetta ricetta = new Ricetta(
              documentSnapshot.id,
              documentSnapshot.get("Autore"),
              documentSnapshot.get("Thumbnail"),
              documentSnapshot.get("Titolo"),
              documentSnapshot.get("NumeroPersone"),
              documentSnapshot.get("TempoPreparazione"),
              List<Map<String, dynamic>>.from(
                  documentSnapshot.get("Ingredienti")),
              List<String>.from(documentSnapshot.get("Passaggi")),
              documentSnapshot.get("isApproved"),
              documentSnapshot.get("Timestamp"),
              documentSnapshot.get("Categoria"));
          ricetteFav.add(ricetta);
        });
      }
      _loadedRicette = true;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: Text("I tuoi preferiti"),
          ),
          body: _actualUser.preferiti.length == 0
              ? buildText("Non hai preferiti. Aggiungine qualcuno!")
              : _loadedRicette
                  ? SingleChildScrollView(
                      child: RicettaButton(
                        utente: _actualUser,
                        ricette: ricetteFav,
                        onCase: () {
                          loadFavFromFirebase();
                        },
                      ),
                    )
                  : buildText("Caricamento in corso...")),
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
