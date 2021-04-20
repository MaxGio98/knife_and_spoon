import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:knife_and_spoon/Assets/custom_colors.dart';
import 'package:knife_and_spoon/Models/ricetta.dart';
import 'package:knife_and_spoon/Models/utente.dart';
import 'package:knife_and_spoon/Widgets/ricetta_button.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key key, @required Utente utente}) : _utente = utente;
  final Utente _utente;

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  Utente _actualUser;
  SearchBar searchBar;
  String _searchTitle = "Trova una ricetta";
  List<Ricetta> _foundRecepies = [];
  bool _hasSearched = false;
  bool _isLoading=false;

  @override
  void initState() {
    _actualUser = widget._utente;
    super.initState();
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
        title: Text(_searchTitle),
        backgroundColor: CustomColors.red,
        actions: [searchBar.getSearchAction(context)]);
  }

  _SearchScreenState() {
    searchBar = new SearchBar(
        inBar: false,
        setState: setState,
        hintText: "Scrivi qui cosa cercare...",
        onSubmitted: updateSearch,
        buildDefaultAppBar: buildAppBar,);
  }

  void searchOnFirebase(String value) {
    _foundRecepies.clear();
    FirebaseFirestore.instance
        .collection("Ricette")
        .where("isApproved", isEqualTo: true)
        .get()
        .then((QuerySnapshot querySnapshot) async {
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        if (querySnapshot.docs[i]
            .get("Titolo")
            .toString()
            .toLowerCase()
            .contains(value)) {
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
      }
      _isLoading=false;
      _hasSearched = true;
    });
  }

  void updateSearch(String value) {
    if (value.trim().isNotEmpty) {
      searchOnFirebase(value);
      setState(() {
        _isLoading=true;
        _searchTitle = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return SafeArea(
        child: Scaffold(
            appBar: searchBar.build(context),
            body: SingleChildScrollView(
              child: _isLoading? buildText("Sto cercando..."): _foundRecepies.length != 0
                  ? RicettaButton(
                      utente: _actualUser,
                      ricette: _foundRecepies,
                    )
                  : _hasSearched
                      ? buildText("Nessun risultato")
                      : buildText("Clicca sulla lente di ingrandimento"),
            )));
  }
  
  Widget buildText(String s)
  {
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
              style: TextStyle(color: CustomColors.gray, fontSize: width*(.05)),
            )));
  }
}
