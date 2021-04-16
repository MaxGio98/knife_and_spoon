import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:knife_and_spoon/custom_colors.dart';
import 'package:knife_and_spoon/utente.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  late Utente actualUser = new Utente("", "", "", [], false);
  bool userLoaded = false;

  @override
  void initState() {
    loadActualUser();
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
          userLoaded = true;
          actualUser = new Utente(
              querySnapshot.docs[0].get("Immagine"),
              querySnapshot.docs[0].get("Mail"),
              querySnapshot.docs[0].get("Nome"),
              querySnapshot.docs[0].get("Preferiti"),
              querySnapshot.docs[0].get("isAdmin"));
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userLoaded) {
      return Scaffold(
        backgroundColor: CustomColors.white,
        body: ListView.builder(
            itemCount: 1,
            itemBuilder: (context, index) {
              return Container(
                  color: CustomColors.white,
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: MediaQuery.of(context).size.height,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: MediaQuery.of(context).size.width *
                                      (0.1),
                                  height: MediaQuery.of(context).size.height *
                                      (0.1),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image:
                                        NetworkImage(actualUser.Immagine),
                                      )),
                                )
                              ],
                            ),
                          ),
                        ),
                      ])
              );
            })
      );
    } else {
      return Scaffold(
        backgroundColor: CustomColors.white,
      );
    }
  }
}
