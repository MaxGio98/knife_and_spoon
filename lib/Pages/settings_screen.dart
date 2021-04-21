import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_permission_validator/easy_permission_validator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:knife_and_spoon/Assets/custom_colors.dart';
import 'package:knife_and_spoon/Models/utente.dart';
import 'package:knife_and_spoon/Pages/sign_in_screen.dart';
import 'package:knife_and_spoon/Pages/username_change_screen.dart';
import 'package:knife_and_spoon/Utils/authentication.dart';
import 'package:knife_and_spoon/Utils/get_image.dart';
import 'package:knife_and_spoon/Widgets/permission_warning.dart';
import 'package:uuid/uuid.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key key, @required Utente utente}) : _utente = utente;
  final Utente _utente;

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Utente _actualUser;
  String _actualUserActualImg;

  @override
  void initState() {
    _actualUser = widget._utente;
    _actualUserActualImg = _actualUser.immagine;
    super.initState();
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Galleria'),
                      onTap: () async {
                        File f = await getImageGallery();
                        loadImageToFirebase(f);
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () async {
                      File f = await getImageCamera();
                      loadImageToFirebase(f);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  void loadImageToFirebase(File image) async {
    var uuid = Uuid().v4();
    if (image != null) {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference storageRef = storage.ref();
      Reference imageRef = storageRef.child(uuid.toString() + ".jpg");
      await imageRef.putFile(image);
      await imageRef.getDownloadURL().then((url) async {
        await FirebaseFirestore.instance
            .collection("Utenti")
            .doc(_actualUser.id)
            .update({"Immagine": url}).then((value) {
          FirebaseStorage.instance.refFromURL(_actualUser.immagine).delete();
          setState(() {
            _actualUser.immagine = url;
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: CustomColors.red,
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Center(
                child: SizedBox(
                  height: width * (0.7),
                  width: width * (0.7),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(width * (0.7)),
                      child: Image.network(
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
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: height * 0.10),
                child: Center(
                  child: SizedBox(
                    width: width * (0.75),
                    height: height * (0.075),
                    child: OutlinedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(CustomColors.red),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                      ),
                      onPressed: () async {
                        EasyPermissionValidator permissionValidatorStorage =
                            EasyPermissionValidator(
                          context: context,
                          customDialog: buildWarningPermissions(context),
                        );
                        var resultStorage =
                            await permissionValidatorStorage.storage();
                        if (resultStorage) {
                          EasyPermissionValidator permissionValidatorCamera =
                              EasyPermissionValidator(
                            context: context,
                            customDialog: buildWarningPermissions(context),
                          );
                          var resultCamera =
                              await permissionValidatorCamera.camera();
                          if (resultCamera) {
                            _showPicker(context);
                          }
                        }
                      },
                      child: Text(
                        'Cambia immagine profilo',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: height * 0.015),
                child: Center(
                  child: SizedBox(
                    width: width * (0.75),
                    height: height * (0.075),
                    child: OutlinedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(CustomColors.red),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    ChangeUsernameScreen(
                                      utente: _actualUser,
                                    )));
                      },
                      child: Text(
                        'Cambia username',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(bottom: height * (0.01)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Center(
                  child: SizedBox(
                    width: width * (0.75),
                    height: height * (0.075),
                    child: OutlinedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(CustomColors.red),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                      ),
                      onPressed: () async {
                        await Authentication.signOut(context: context);
                        Navigator.of(context).pushAndRemoveUntil(
                            _routeToSignInScreen(),
                            (Route<dynamic> route) => false);
                      },
                      child: Text(
                        'Log out',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Route _routeToSignInScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => SignInScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(-1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
