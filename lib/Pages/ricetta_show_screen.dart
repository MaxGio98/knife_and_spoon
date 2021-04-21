import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:knife_and_spoon/Assets/custom_colors.dart';
import 'package:knife_and_spoon/Models/ricetta.dart';
import 'package:knife_and_spoon/Models/utente.dart';

class RicettaShow extends StatefulWidget {
  const RicettaShow(
      {Key key, @required Utente utente, @required Ricetta ricetta})
      : _utente = utente,
        _ricetta = ricetta,
        super(key: key);
  final Utente _utente;
  final Ricetta _ricetta;

  @override
  _RicettaShowState createState() => _RicettaShowState();
}

class _RicettaShowState extends State<RicettaShow> {
  Utente _actualUser;
  Ricetta _ricetta;
  var favIcon = Icon(Icons.favorite_border);
  bool isFav = false;
  String publisherImageURL =
      "https://firebasestorage.googleapis.com/v0/b/knifeandspoon-3ac35.appspot.com/o/pic.png?alt=media&token=522b1b24-2f4f-4d16-bb9c-521cc422f1c2";
  String publisherName = "";
  String svgPath = "/assets/secondo.svg";

  @override
  void initState() {
    _actualUser = widget._utente;
    _ricetta = widget._ricetta;
    setSvg();
    loadFavorite();
    _loadPublisher();
  }

  void setSvg() {
    if (_ricetta.categoria == "Primo") {
      setState(() {
        svgPath = "assets/primo.svg";
      });
    } else if (_ricetta.categoria == "Secondo") {
      setState(() {
        svgPath = "assets/secondo.svg";
      });
    } else if (_ricetta.categoria == "Antipasto") {
      setState(() {
        svgPath = "assets/antipasto.svg";
      });
    } else if (_ricetta.categoria == "Contorno") {
      setState(() {
        svgPath = "assets/contorno.svg";
      });
    } else {
      setState(() {
        svgPath = "assets/dolce.svg";
      });
    }
  }

  void loadFavorite() {
    if (_actualUser.preferiti.contains(_ricetta.id)) {
      setState(() {
        isFav = true;
        favIcon = Icon(Icons.favorite);
      });
    }
  }

  void _favoriteManagement() {
    DocumentReference actualUserFav =
        FirebaseFirestore.instance.collection("Utenti").doc(_actualUser.id);
    if (!isFav) {
      _actualUser.preferiti.add(_ricetta.id);
      actualUserFav.update({'Preferiti': _actualUser.preferiti}).then((value) {
        setState(() {
          favIcon = Icon(Icons.favorite);
          isFav = !isFav;
        });
      });
    } else {
      _actualUser.preferiti.remove(_ricetta.id);
      actualUserFav.update({'Preferiti': _actualUser.preferiti}).then((value) {
        setState(() {
          favIcon = Icon(Icons.favorite_border);
          isFav = !isFav;
        });
      });
    }
  }

  void _loadPublisher() {
    DocumentReference publisherData =
        FirebaseFirestore.instance.collection("Utenti").doc(_ricetta.authorId);
    publisherData.get().then((value) {
      setState(() {
        publisherImageURL = value.get("Immagine");
        publisherName = value.get("Nome");
      });
    });
  }

  String _returnCorrectMinute() {
    if (_ricetta.tempo == 1) {
      return "o";
    }
    return "i";
  }

  String _returnCorrectPersone() {
    if (_ricetta.persone == 1) {
      return "a";
    }
    return "e";
  }

  String _returnCorrectQuant(int i) {
    if (_ricetta.ingredienti[i]["Unità misura"] == "q.b.") {
      return "";
    }
    return _ricetta.ingredienti[i]["Quantità"].toString();
  }

  String _returnCorrectUM(int i) {
    double quant = double.parse(_ricetta.ingredienti[i]["Quantità"].toString());
    String correctForm = "";
    String uM = _ricetta.ingredienti[i]["Unità misura"].toString();
    if (quant == 1) {
      if (uM == ("grammi")) {
        correctForm = "grammo";
      } else if (uM == ("litri")) {
        correctForm = "litro";
      } else if (uM == ("millilitri")) {
        correctForm = "millilitro";
      } else {
        correctForm = uM;
      }
    } else {
      if (uM == ("bicchiere")) {
        if (quant >= 2) {
          correctForm = "bicchieri";
        } else {
          correctForm = uM;
        }
      } else if (uM == ("cucchiaio")) {
        correctForm = "cucchiai";
      } else if (uM == ("cucchiaino")) {
        correctForm = "cucchiaini";
      } else {
        correctForm = uM;
      }
    }
    return correctForm;
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return SafeArea(
        child: Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _favoriteManagement();
          snackBarMessage();
        },
        backgroundColor: CustomColors.red,
        child: favIcon,
      ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: height * (0.3),
              floating: false,
              pinned: true,
              backgroundColor: CustomColors.red,
              flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  title: Text(_ricetta.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * .05,
                      )),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        _ricetta.thumbnail,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        height: width * 0.1,
                        width: width,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(0, -1),
                            end: Alignment(0, 0.5),
                            colors: [
                              const Color(0xCC000000).withOpacity(0.6),
                              const Color(0x00000000),
                              const Color(0x00000000),
                              const Color(0xCC000000).withOpacity(0.6),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
          ];
        },
        body: ListView(
          children: [
            Padding(
              padding: EdgeInsets.all(width * (0.04)),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        height: width * (0.175),
                        width: width * (0.175),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(width * 0.175),
                          child: Image.network(
                            publisherImageURL,
                            fit: BoxFit.cover,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes
                                      : null,
                                  valueColor: new AlwaysStoppedAnimation<Color>(
                                      CustomColors.red),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: width * (0.02)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Autore",
                              style: TextStyle(fontSize: width * (0.045)),
                            ),
                            Text(
                              publisherName,
                              style: TextStyle(fontSize: width * (0.06)),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: height * (0.02)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          svgPath,
                          height: width * (0.125),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: width * (0.02)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Categoria",
                                style: TextStyle(fontSize: width * (0.045)),
                              ),
                              Text(
                                _ricetta.categoria,
                                style: TextStyle(fontSize: width * (0.06)),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: height * (0.02)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          "assets/clock.svg",
                          height: width * (0.125),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: width * (0.02)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _ricetta.tempo +
                                    " minut" +
                                    _returnCorrectMinute(),
                                style: TextStyle(fontSize: width * (0.06)),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: height * (0.02)),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          "assets/group.svg",
                          height: width * (0.125),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: width * (0.02)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _ricetta.persone +
                                    " person" +
                                    _returnCorrectPersone(),
                                style: TextStyle(fontSize: width * (0.06)),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: height * (0.035)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: height * (0.02)),
                              child: Text(
                                "Ingredienti",
                                style: TextStyle(fontSize: width * (0.06)),
                              ),
                            ),
                            Container(
                              width: width * .92,
                              child: ListView.builder(
                                  itemCount: _ricetta.ingredienti.length,
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemBuilder: (context, i) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                          top: height * (0.007)),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "\u2022 ",
                                            style: TextStyle(
                                                color: CustomColors.red,
                                                fontSize: width * (0.1)),
                                          ),
                                          Expanded(
                                            child: Text(
                                              _ricetta.ingredienti[i]["Nome"]
                                                      .toString() +
                                                  " " +
                                                  _returnCorrectQuant(i) +
                                                  " " +
                                                  _returnCorrectUM(i),
                                              style: TextStyle(
                                                  fontSize: width * (0.06)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: height * (0.035)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: height * (0.01)),
                              child: Text(
                                "Passaggi",
                                style: TextStyle(fontSize: width * (0.06)),
                              ),
                            ),
                            Container(
                              width: width * .92,
                              alignment: Alignment.topLeft,
                              child: ListView.builder(
                                  itemCount: _ricetta.steps.length,
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemBuilder: (context, i) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                          bottom: height * (0.01)),
                                      child: Row(
                                        children: [
                                          Text(
                                            "\u2022 ",
                                            style: TextStyle(
                                                color: CustomColors.red,
                                                fontSize: width * (0.2)),
                                          ),
                                          Expanded(
                                            child: Text(
                                              _ricetta.steps[i].toString(),
                                              style: TextStyle(
                                                  fontSize: width * (0.06)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                            )
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  void snackBarMessage() {
    if (isFav) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Rimosso dai preferiti")));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Aggiunto ai preferiti")));
    }
  }
}
