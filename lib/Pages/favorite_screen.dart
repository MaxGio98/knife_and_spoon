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
    return CheckConnection(
      child: SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: Text("I tuoi preferiti"),
            ),
            body: _actualUser.preferiti.length == 0
                ? buildText("Non hai preferiti. Aggiungine qualcuno!")
                : _loadedRicette
                    ? SingleChildScrollView(
                        child: ListView.builder(
                            itemCount: ricetteFav.length,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, i) {
                              return Container(
                                height: MediaQuery.of(context).size.height * .2,
                                width: MediaQuery.of(context).size.width,
                                child: Padding(
                                  padding: EdgeInsets.all(
                                      MediaQuery.of(context).size.width * (.02)),
                                  child: Material(
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (BuildContext context) =>
                                                    RicettaShow(
                                                      utente: _actualUser,
                                                      ricetta: ricetteFav[i],
                                                    ))).then((value) {
                                          loadFavFromFirebase();
                                        });
                                      },
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: Image.network(
                                              ricetteFav[i].thumbnail,
                                              fit: BoxFit.cover,
                                              loadingBuilder:
                                                  (BuildContext context,
                                                      Widget child,
                                                      ImageChunkEvent
                                                          loadingProgress) {
                                                if (loadingProgress == null)
                                                  return child;
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    value: loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            loadingProgress
                                                                .expectedTotalBytes
                                                        : null,
                                                    valueColor:
                                                        new AlwaysStoppedAnimation<
                                                                Color>(
                                                            CustomColors.red),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.1,
                                            width:
                                                MediaQuery.of(context).size.width,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              gradient: LinearGradient(
                                                begin: Alignment(0, -1),
                                                end: Alignment(0, 0.5),
                                                colors: [
                                                  const Color(0xCC000000)
                                                      .withOpacity(0.1),
                                                  const Color(0x00000000),
                                                  const Color(0x00000000),
                                                  const Color(0xCC000000)
                                                      .withOpacity(0.6),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(12.0),
                                                child: Align(
                                                    alignment:
                                                        Alignment.bottomLeft,
                                                    child: FittedBox(
                                                        fit: BoxFit.contain,
                                                        child: Text(
                                                          ricetteFav[i].title,
                                                          style: TextStyle(
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  (.05),
                                                              color: CustomColors
                                                                  .white),
                                                        ))),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            })
                        //RicettaButton(utente: _actualUser, ricette: ricetteFav))
                        )
                    : buildText("Caricamento in corso...")),
      ),
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
