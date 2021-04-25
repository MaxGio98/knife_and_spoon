import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:knife_and_spoon/Assets/custom_colors.dart';
import 'package:knife_and_spoon/Models/ricetta.dart';
import 'package:knife_and_spoon/Models/utente.dart';
import 'package:knife_and_spoon/Pages/favorite_screen.dart';
import 'package:knife_and_spoon/Pages/insert_ricetta_screen.dart';
import 'package:knife_and_spoon/Pages/ricetta_show_screen.dart';
import 'package:knife_and_spoon/Pages/search_ricetta_screen.dart';
import 'package:knife_and_spoon/Pages/settings_screen.dart';
import 'package:knife_and_spoon/Utils/check_connection.dart';
import 'package:knife_and_spoon/Widgets/custom_alert_dialog.dart';

import 'package:knife_and_spoon/Widgets/ricetta_button.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  FirebaseAuth auth = FirebaseAuth.instance;
  Utente _actualUser = new Utente("", "", "", "", [], false);
  List<Ricetta> _tenRicette = [];
  List<Ricetta> _lastTenRicette = [];
  bool _userLoaded = false;
  bool _lastTenRicetteLoaded = false;
  AnimationController rotationController;
  List<String> _categorie = [
    "Antipasto",
    "Primo",
    "Secondo",
    "Contorno",
    "Dolce"
  ];
  List<bool> _isChecked = [false, false, false, false, false];

  _HomeScreenState() {
    loadActualUser();
    loadTenRecepies();
    loadLastTenRecepies();
  }

  @override
  void initState() {
    rotationController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    super.initState();
  }

  void loadActualUser() {
    if (!auth.currentUser.isAnonymous) {
      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection("Utenti");
      usersCollection
          .where("Mail", isEqualTo: auth.currentUser.email)
          .get()
          .then((QuerySnapshot querySnapshot) async {
        //load user data
        setState(() {
          _actualUser = new Utente(
              querySnapshot.docs[0].id,
              querySnapshot.docs[0].get("Immagine"),
              querySnapshot.docs[0].get("Mail"),
              querySnapshot.docs[0].get("Nome"),
              List<String>.from(querySnapshot.docs[0].get("Preferiti")),
              querySnapshot.docs[0].get("isAdmin"));
          _userLoaded = true;
        });
      });
    } else {
      _actualUser.nome = "anon";
      _userLoaded = true;
    }
  }

  void loadTenRecepies() {
    _tenRicette.clear();
    _currentIndex = 0;
    CollectionReference recipesCollection =
        FirebaseFirestore.instance.collection("Ricette");
    recipesCollection
        .limit(10)
        .where("isApproved", isEqualTo: true)
        .get()
        .then((QuerySnapshot querySnapshot) async {
      //load user data
      setState(() {
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
          _tenRicette.add(ricetta);
        }
      });
    });
  }

  void loadFilteredRicette(String categoria) {
    _tenRicette.clear();
    _currentIndex = 0;
    CollectionReference recipesCollection =
        FirebaseFirestore.instance.collection("Ricette");
    recipesCollection
        .limit(10)
        .where("isApproved", isEqualTo: true)
        .where("Categoria", isEqualTo: categoria)
        .get()
        .then((QuerySnapshot querySnapshot) async {
      setState(() {
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
          _tenRicette.add(ricetta);
        }
      });
    });
  }

  void loadLastTenRecepies() {
    _lastTenRicette.clear();
    CollectionReference recipesCollection =
        FirebaseFirestore.instance.collection("Ricette");
    recipesCollection
        .orderBy("Timestamp", descending: true)
        .where("isApproved", isEqualTo: true)
        .limit(10)
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
        _lastTenRicette.add(ricetta);
      }
      setState(() {
        _lastTenRicetteLoaded = true;
      });
    });
  }

  int _currentIndex = 0;

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return CheckConnection(
      onCase: () {
        setState(() {
          _userLoaded = false;
          _lastTenRicetteLoaded = false;
          _currentIndex = 0;
          for (int i = 0; i < _isChecked.length; i++) {
            _isChecked[i] = false;
          }
        });
        loadActualUser();
        loadTenRecepies();
        loadLastTenRecepies();
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          floatingActionButton: SpeedDial(
            heroTag: "btnMenu",
            marginEnd: width * (0.0275),
            marginBottom: width * (0.0275),
            icon: Icons.menu,
            activeIcon: Icons.close,
            buttonSize: width * (0.15),
            visible: true,
            closeManually: false,
            renderOverlay: false,
            curve: Curves.bounceIn,
            overlayColor: Colors.black,
            overlayOpacity: 0.5,
            tooltip: 'Menu',
            backgroundColor: CustomColors.red,
            foregroundColor: Colors.white,
            elevation: 8.0,
            shape: CircleBorder(),
            children: [
              !auth.currentUser.isAnonymous
                  ? SpeedDialChild(
                      child: Icon(
                        Icons.edit,
                        color: CustomColors.white,
                      ),
                      backgroundColor: CustomColors.red,
                      label: 'Aggiungi una ricetta',
                      labelStyle:
                          TextStyle(fontSize: 18.0, color: CustomColors.white),
                      labelBackgroundColor: CustomColors.red,
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    InsertRicettaScreen(
                                      utente: _actualUser,
                                    )));
                      },
                    )
                  : SpeedDialChild(
                      child: Icon(
                        Icons.edit,
                        color: CustomColors.white,
                      ),
                      backgroundColor: CustomColors.silver,
                      label: 'Aggiungi una ricetta',
                      labelStyle:
                          TextStyle(fontSize: 18.0, color: CustomColors.white),
                      labelBackgroundColor: CustomColors.red,
                      onTap: () {
                        return showDialog<void>(
                          context: context,
                          barrierDismissible: true,
                          builder: (BuildContext context) {
                            return buildAnonymousDialogRegistration(
                              context,
                            );
                          },
                        );
                      },
                    ),
              SpeedDialChild(
                child: Icon(
                  Icons.search,
                  color: CustomColors.white,
                ),
                backgroundColor: CustomColors.red,
                label: 'Ricerca',
                labelStyle:
                    TextStyle(fontSize: 18.0, color: CustomColors.white),
                labelBackgroundColor: CustomColors.red,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => SearchScreen(
                                utente: _actualUser,
                              )));
                },
              ),
              !auth.currentUser.isAnonymous
                  ? SpeedDialChild(
                      child: Icon(
                        Icons.favorite,
                        color: CustomColors.white,
                      ),
                      backgroundColor: CustomColors.red,
                      label: 'Preferiti',
                      labelStyle:
                          TextStyle(fontSize: 18.0, color: CustomColors.white),
                      labelBackgroundColor: CustomColors.red,
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    FavoriteScreen(
                                      utente: _actualUser,
                                    )));
                      },
                    )
                  : SpeedDialChild(
                      child: Icon(
                        Icons.favorite,
                        color: CustomColors.white,
                      ),
                      backgroundColor: CustomColors.silver,
                      label: 'Preferiti',
                      labelStyle:
                          TextStyle(fontSize: 18.0, color: CustomColors.white),
                      labelBackgroundColor: CustomColors.red,
                      onTap: () {
                        return showDialog<void>(
                          context: context,
                          barrierDismissible: true, // user must tap button!
                          builder: (BuildContext context) {
                            return buildAnonymousDialogRegistration(
                              context,
                            );
                          },
                        );
                      },
                    ),
              SpeedDialChild(
                child: Icon(
                  Icons.settings,
                  color: CustomColors.white,
                ),
                backgroundColor: CustomColors.red,
                labelBackgroundColor: CustomColors.red,
                label: 'Impostazioni',
                labelStyle:
                    TextStyle(fontSize: 18.0, color: CustomColors.white),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => SettingsScreen(
                                utente: _actualUser,
                              )));
                },
              ),
            ],
          ),
          body: DoubleBackToCloseApp(
            child: Stack(
              children: [
                RefreshIndicator(
                  color: CustomColors.red,
                  onRefresh: () {
                    setState(() {
                      _userLoaded = false;
                      _lastTenRicetteLoaded = false;
                      _currentIndex = 0;
                      for (int i = 0; i < _isChecked.length; i++) {
                        _isChecked[i] = false;
                      }
                    });
                    loadActualUser();
                    loadTenRecepies();
                    loadLastTenRecepies();
                    return Future.value(true);
                  },
                  child: SingleChildScrollView(
                    child: Column(children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(width * (.02)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            buildImage(context),
                            SizedBox(
                              width: width * (0.01),
                            ),
                            !auth.currentUser.isAnonymous
                                ? Text(
                                    "Ciao " +
                                        _actualUser.nome +
                                        "!\nBenvenuto su Knife&Spoon.",
                                    style: TextStyle(fontSize: width * (.055)),
                                  )
                                : Text(
                                    "Ciao cuoco misterioso!\nBenvenuto su Knife&Spoon.",
                                    style: TextStyle(fontSize: width * (.055)),
                                  )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: height * .01, bottom: height * .01),
                        child: Container(
                            width: width,
                            height: height * (0.15),
                            child: ListView.builder(
                                itemCount: _categorie.length,
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemBuilder: (context, i) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        left: width * 0.01, right: width * .01),
                                    child: Container(
                                      width: width * (.425),
                                      height: height * (0.15),
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: Image.asset(
                                            "assets/" +
                                                _categorie[i].toLowerCase() +
                                                "main.jpg",
                                            fit: BoxFit.cover,
                                          ).image,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                            MediaQuery.of(context).size.width *
                                                (0.04)),
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  (0.04)),
                                          onTap: () {
                                            if (!_isChecked[i]) {
                                              for (int j = 0;
                                                  j < _isChecked.length;
                                                  j++) {
                                                _isChecked[j] = false;
                                              }
                                              loadFilteredRicette(
                                                  _categorie[i]);
                                              setState(() {
                                                _isChecked[i] = true;
                                              });
                                            } else {
                                              loadTenRecepies();
                                              setState(() {
                                                _isChecked[i] = false;
                                              });
                                            }
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                bottom: height * (0.01),
                                                left: height * .02,
                                                right: height * .02),
                                            child: Align(
                                                alignment: Alignment.bottomLeft,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    FittedBox(
                                                        fit: BoxFit.contain,
                                                        child: Text(
                                                          _categorie[i],
                                                          style: TextStyle(
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  (.055),
                                                              color:
                                                                  CustomColors
                                                                      .white),
                                                        )),
                                                    _isChecked[i]
                                                        ? Icon(
                                                            Icons.check,
                                                            color: CustomColors
                                                                .white,
                                                          )
                                                        : SizedBox()
                                                  ],
                                                )),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                })),
                      ),
                      _tenRicette.length != 0
                          ? Container(
                              height: height * (.3),
                              width: width,
                              child: CarouselSlider(
                                options: CarouselOptions(
                                  height: height * (.3),
                                  autoPlay: true,
                                  autoPlayInterval: Duration(seconds: 10),
                                  autoPlayAnimationDuration:
                                      Duration(milliseconds: 800),
                                  autoPlayCurve: Curves.fastOutSlowIn,
                                  pauseAutoPlayOnTouch: true,
                                  aspectRatio: 2.0,
                                  onPageChanged: (index, reason) {
                                    setState(() {
                                      _currentIndex = index;
                                    });
                                  },
                                ),
                                items: _tenRicette.map((card) {
                                  return Builder(
                                      builder: (BuildContext context) {
                                    return Padding(
                                      padding: EdgeInsets.all(width * .01),
                                      child: Container(
                                        height: height * (0.30),
                                        width: width,
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        RicettaShow(
                                                          utente: _actualUser,
                                                          ricetta: card,
                                                        )));
                                          },
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                child: Image.network(
                                                  card.thumbnail,
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
                                                                CustomColors
                                                                    .red),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              Container(
                                                height: width * 0.1,
                                                width: width,
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
                                                        const EdgeInsets.all(
                                                            12.0),
                                                    child: Align(
                                                        alignment: Alignment
                                                            .bottomLeft,
                                                        child: FittedBox(
                                                            fit: BoxFit.contain,
                                                            child: Text(
                                                              card.title,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      width *
                                                                          (.05),
                                                                  color:
                                                                      CustomColors
                                                                          .white),
                                                            ))),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  });
                                }).toList(),
                              ),
                            )
                          : Container(
                              height: height * (.3),
                              width: width,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Caricamento in corso...",
                                    style: TextStyle(fontSize: width * (.05)),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(top: height * (.01)),
                                    child: Container(
                                      width: width * (.1),
                                      height: width * (.1),
                                      child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  CustomColors.red)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: map<Widget>(_tenRicette, (index, url) {
                          return Container(
                            width: width * (0.035),
                            height: width * (0.035),
                            margin: EdgeInsets.symmetric(
                                vertical: height * (0.01),
                                horizontal: width * (0.0075)),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentIndex == index
                                  ? CustomColors.red
                                  : Colors.grey,
                            ),
                          );
                        }),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: height * (0.02)),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Le ultime ricette pubblicate",
                            style: TextStyle(fontSize: width * (.05)),
                          ),
                        ),
                      ),
                      _userLoaded && _lastTenRicetteLoaded
                          ? RicettaButton(
                              utente: _actualUser, ricette: _lastTenRicette)
                          : Column(
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      CustomColors.red),
                                )
                              ],
                            )
                    ]),
                  ),
                ),
              ],
            ),
            snackBar: SnackBar(
              content: Text("Esegui di nuovo l'azione per uscire"),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildImage(BuildContext context) {
    if (_userLoaded) {
      return Container(
        width: MediaQuery.of(context).size.width * (.2),
        height: MediaQuery.of(context).size.width * (.2),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(
                MediaQuery.of(context).size.width * (0.2)),
            child: auth.currentUser.isAnonymous
                ? Image.asset(
                    "assets/pizza.png",
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    _actualUser.immagine,
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes
                              : null,
                          valueColor: new AlwaysStoppedAnimation<Color>(
                              CustomColors.red),
                        ),
                      );
                    },
                  )),
      );
    } else {
      return Container(
        width: MediaQuery.of(context).size.width * (.2),
        height: MediaQuery.of(context).size.width * (.2),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * (.1),
            height: MediaQuery.of(context).size.width * (.1),
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(CustomColors.red)),
          ),
        ),
      );
    }
  }
}
