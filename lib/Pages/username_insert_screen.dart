import 'dart:io';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' show get;
import 'package:knife_and_spoon/Assets/custom_colors.dart';
import 'package:knife_and_spoon/Utils/check_connection.dart';
import 'package:knife_and_spoon/Utils/username_check.dart';
import 'package:path_provider/path_provider.dart';

class InsertUsernameScreen extends StatefulWidget {
  const InsertUsernameScreen({Key key, @required User user})
      : _user = user,
        super(key: key);
  final User _user;

  @override
  _InsertUsernameScreenState createState() => _InsertUsernameScreenState();
}

class _InsertUsernameScreenState extends State<InsertUsernameScreen> {
  User _user;

  @override
  void initState() {
    _user = widget._user;
    _asyncImgLoad();
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  _asyncImgLoad() async {
    var authority = _user.photoURL.split("//")[1].split("/")[0];
    var path = _user.photoURL.split(".com")[1];
    var uri = new Uri.https(authority, path);
    var response = await get(uri);
    var documentDirectory = await getApplicationDocumentsDirectory();
    var firstPath = documentDirectory.path + "/images";
    var filePathAndName = documentDirectory.path + '/images/pic.jpg';
    await Directory(firstPath).create(recursive: true);
    File file2 = new File(filePathAndName);
    file2.writeAsBytesSync(response.bodyBytes);
    setState(() {
      imageData = filePathAndName;
      dataLoaded = true;
    });
  }

  String imageData;
  bool dataLoaded = false;
  bool check = false;

  final usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return CheckConnection(
      child: Scaffold(
        backgroundColor: CustomColors.red,
        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints.tightFor(
                height: MediaQueryData.fromWindow(window).size.height),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 7,
                      child: Container(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[buildImage(context)],
                      )),
                    ),
                    Expanded(
                        flex: 6,
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: width * (0.05),
                              left: width * (0.05),
                              right: width * (0.05)),
                          child: Column(
                            children: <Widget>[
                              Text(
                                'Ciao ' + '${_user.displayName}!',
                                style: TextStyle(
                                  color: CustomColors.white,
                                  fontSize: 26,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: width * (0.05)),
                                child: TextField(
                                  cursorColor: CustomColors.white,
                                  decoration: InputDecoration(
                                      counterStyle:
                                          TextStyle(color: CustomColors.silver),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: CustomColors.silver),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                      hintText: "Inserisci qui il tuo username",
                                      hintStyle:
                                          TextStyle(color: CustomColors.silver)),
                                  controller: usernameController,
                                  maxLength: 20,
                                  style: TextStyle(color: CustomColors.white),
                                  onSubmitted: (value) {
                                    checkValue();
                                  },
                                ),
                              ),
                              AnimatedSwitcher(
                                duration: Duration(milliseconds: 250),
                                child: check
                                    ? CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.white),
                                      )
                                    : SizedBox(
                                        width: width * (0.75),
                                        height: height * (0.075),
                                        child: OutlinedButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    CustomColors.white),
                                            shape: MaterialStateProperty.all(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(40),
                                              ),
                                            ),
                                          ),
                                          onPressed: () async {
                                            checkValue();
                                          },
                                          child: Text(
                                            'Registrami!',
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildImage(BuildContext context) {
    if (dataLoaded) {
      return CircleAvatar(
          radius: MediaQuery.of(context).size.width * (.2),
          backgroundImage: FileImage(
            File(imageData),
          ));
    } else {
      return Container(
        child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(CustomColors.white)),
      );
    }
  }

  void checkValue() async {
    setState(() {
      check = true;
    });
    await checkUsername(usernameController.text, context, _user, imageData);
    setState(() {
      check = false;
    });
  }
}
