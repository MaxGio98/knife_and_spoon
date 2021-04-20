import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:knife_and_spoon/Assets/custom_colors.dart';
import 'package:knife_and_spoon/Models/ricetta.dart';
import 'package:knife_and_spoon/Models/utente.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key key, @required Utente utente}) : _utente = utente;
  final Utente _utente;

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  Utente _actualUser;
  SearchBar searchBar;
  String _searchTitle="Trova una ricetta";
  List<Ricetta> _foundRecepies=[];

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
        hintText: "Scrivi qui...",
        onSubmitted: updateSearch,
        buildDefaultAppBar: buildAppBar);
  }

  void searchOnFirebase(String value)
  {
    _foundRecepies.clear();
      FirebaseFirestore.instance.collection("Ricette").where("Titolo",isEqualTo: value).get().then((QuerySnapshot querySnapshot) async{
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
      });
  }
  void updateSearch(String value)
  {
    if(value.trim().isNotEmpty)
    {
      searchOnFirebase(value);
      setState(() {
        _searchTitle=value;
      });
    }
    
    



  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return SafeArea(child:
    Scaffold(appBar: searchBar.build(context),
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [Text("CIAO")],
    ),));
  }


}
