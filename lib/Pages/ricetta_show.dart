import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    _actualUser = widget._utente;
    _ricetta = widget._ricetta;
    loadFavorite();
  }

  void loadFavorite() {
    if (_actualUser.preferiti.contains(_ricetta.id)) {
      setState(() {
        isFav = true;
        favIcon = Icon(Icons.favorite);
      });
    }
  }

  void favoriteManagement() {
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            favoriteManagement();
            snackBarMessage();
          },
          backgroundColor: CustomColors.red,
          child: favIcon,
        ),
        body: Stack(
          children: [Text(_ricetta.id),
          ElevatedButton(onPressed:() =>Navigator.of(context).pop(), child: Text("Back"))],
        ),
      ),
    );
  }

  void snackBarMessage() {
    if(isFav)
      {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Rimosso dai preferiti")));
      }
    else
      {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Aggiunto ai preferiti")));
      }

  }
}
