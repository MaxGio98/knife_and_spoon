import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:knife_and_spoon/Assets/custom_colors.dart';
import 'package:knife_and_spoon/Models/ricetta.dart';
import 'package:knife_and_spoon/Models/utente.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  Utente _actualUser = new Utente("", "", "", [], false);
  List<Ricetta> _ricette = [];
  bool _userLoaded = false;
  bool _tenRicipesLoaded = false;

  @override
  void initState() {
    loadActualUser();
    loadTenRecepies();
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
          _userLoaded = true;
          _actualUser = new Utente(
              querySnapshot.docs[0].get("Immagine"),
              querySnapshot.docs[0].get("Mail"),
              querySnapshot.docs[0].get("Nome"),
              List<String>.from(querySnapshot.docs[0].get("Preferiti")),
              querySnapshot.docs[0].get("isAdmin"));
        });
      });
    }
  }

  void loadTenRecepies() {
    CollectionReference recipesCollection =
        FirebaseFirestore.instance.collection("Ricette");
    recipesCollection.limit(10).get().then((QuerySnapshot querySnapshot) async {
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
          _ricette.add(ricetta);
          _tenRicipesLoaded=true;
        }
      });
    });
  }

  int _currentIndex=0;
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
    return SafeArea(
      child: Scaffold(
          backgroundColor: CustomColors.white,
          body: SingleChildScrollView(
            child: Column(children: <Widget>[
              Container(
                padding: EdgeInsets.all(width*(.02)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    buildImage(context),
                    SizedBox(
                      width: width * (0.01),
                    ),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Ciao " +
                                _actualUser.Nome +
                                "!\nBenvenuto su Knife&Spoon.",
                            style: TextStyle(fontSize: width * (.055)),
                          ),
                        ])
                  ],
                ),
              ),
              CarouselSlider(
                options: CarouselOptions(
                  height: height*(.3),
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 10),
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  pauseAutoPlayOnTouch: true,
                  aspectRatio: 2.0,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
                items: _ricette.map((card){
                  return Builder(
                      builder:(BuildContext context){
                        return Container(
                          height: height*(0.30),
                          width: width,
                          child: Card(
                            color: CustomColors.white,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(card.thumbnail,fit: BoxFit.cover,loadingBuilder: (BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null ?
                                  loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                      : null,valueColor: new AlwaysStoppedAnimation<Color>(CustomColors.red),
                                ),
                              );
                            },
                            ),
                            )
                          ),
                        );
                      }
                  );
                }).toList(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: map<Widget>(_ricette, (index, url) {
                  return Container(
                    width: width*(0.035),
                    height: width*(0.035),
                    margin: EdgeInsets.symmetric(vertical: height*(0.01), horizontal: width*(0.0075)),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == index ? CustomColors.red : Colors.grey,
                    ),
                  );
                }),
              ),

            ]
            ),
          )),
    );
  }

  Widget buildImage(BuildContext context) {
    if (_userLoaded) {
      return CircleAvatar(
        radius: MediaQuery.of(context).size.width * (.1),
        backgroundImage: NetworkImage(_actualUser.Immagine),
        backgroundColor: CustomColors.white,
      );
    } else {
      return Container(
        child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(CustomColors.red)),
      );
    }
  }
}
