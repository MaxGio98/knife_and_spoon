import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:knife_and_spoon/custom_colors.dart';
import 'package:knife_and_spoon/ricetta.dart';
import 'package:knife_and_spoon/utente.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  late Utente _actualUser = new Utente("", "", "", [], false);
  List<Ricetta>_ricette=[];
  bool _userLoaded = false;
  bool _tenRicipesLoaded=false;


  @override
  void initState() {
    loadActualUser();
    loadTenRecepies();
    super.initState();
  }

  void loadActualUser() {
    if (!auth.currentUser!.isAnonymous) {
      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection("Utenti");
      usersCollection
          .where("Mail", isEqualTo: auth.currentUser!.email)
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

  void loadTenRecepies()
  {
    CollectionReference recipesCollection =
    FirebaseFirestore.instance.collection("Ricette");
    recipesCollection.limit(10).get()
        .then((QuerySnapshot querySnapshot) async {
      //load user data
      setState(() {
        for(int i=0;i<querySnapshot.docs.length;i++)
          {
            /*Ricetta ricetta=new Ricetta(querySnapshot.docs[i].id,
                querySnapshot.docs[i].get("Autore"),
                querySnapshot.docs[i].get("Thumbnail"),
                querySnapshot.docs[i].get("Titolo"),
                querySnapshot.docs[i].get("NumeroPersone"),
                querySnapshot.docs[i].get("TempoPreparazione"),
                List<Map<String,Object>>.from(Map<String,Object>.from(querySnapshot.docs[i].get("Ingredienti"))),
                List<String>.from(querySnapshot.docs[i].get("Passaggi")),
                querySnapshot.docs[i].get("isApproved"),
                querySnapshot.docs[i].get("Timestamp"),
                querySnapshot.docs[i].get("Categoria"));
            _ricette.add(ricetta);*/
          }

      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var height=MediaQuery.of(context).size.height;
    var width=MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: CustomColors.white,
        body: ListView.builder(
            itemCount: 1,
            itemBuilder: (context, index) {
              return Container(
                  height: height,
                  child: Column(
                      children: <Widget>[
                        Padding(padding: EdgeInsets.only(top: height*(.01))),
                           Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Padding(padding: EdgeInsets.only(
                                    left: width*(.005),right: width*(.005),)
                                ),
                                buildImage(context),
                                SizedBox(width:width*(0.01),),
                                Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Text("Ciao "+_actualUser.Nome+"!\nBenvenuto su Knife&Spoon.",
                                        style: TextStyle(fontSize: width*(.055)),
                                      ),
                                    ]
                                )
                              ],
                            ),
                          ),
                      ]
                  )
              );
            })
      );

  }

  Widget buildImage(BuildContext context)
  {
    if(_userLoaded)
      {
        return  CircleAvatar(
            radius: MediaQuery.of(context).size.width*(.1),

            backgroundImage: NetworkImage(_actualUser.Immagine),
            backgroundColor: CustomColors.white,
        );
      }
    else
      {
        return Container(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  CustomColors.red)),
        );
      }

  }
}
