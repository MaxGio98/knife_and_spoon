import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:knife_and_spoon/Assets/custom_colors.dart';
import 'package:knife_and_spoon/Models/ricetta.dart';
import 'package:knife_and_spoon/Models/utente.dart';
import 'package:knife_and_spoon/Pages/ricetta_show_screen.dart';
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
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: Text("Approva le ricette"),
            ),
            body: SingleChildScrollView(
              child: _isLoading
                  ? buildText("Sto cercando...")
                  : _foundRecepies.length != 0
                      ? buildRicetteToApprove()
                      : buildText("Nessuna ricetta da approvare"),
            )));
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

  Widget buildRicetteToApprove() {
    return ListView.builder(
        itemCount: _foundRecepies.length,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, i) {
          return Container(
            height: MediaQuery.of(context).size.height * .2,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding:
                  EdgeInsets.all(MediaQuery.of(context).size.width * (.02)),
              child: Material(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => RicettaShow(
                                  utente: _actualUser,
                                  ricetta: _foundRecepies[i],
                                ))).then((value) => searchOnFirebase());
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          _foundRecepies[i].thumbnail,
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
                      Container(
                        height: MediaQuery.of(context).size.width * 0.1,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            begin: Alignment(0, -1),
                            end: Alignment(0, 0.5),
                            colors: [
                              const Color(0xCC000000).withOpacity(0.1),
                              const Color(0x00000000),
                              const Color(0x00000000),
                              const Color(0xCC000000).withOpacity(0.6),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Align(
                                alignment: Alignment.bottomLeft,
                                child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: Text(
                                      _foundRecepies[i].title,
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              (.05),
                                          color: CustomColors.white),
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
        });
  }
}
