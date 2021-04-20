import 'dart:io';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' show get;
import 'package:knife_and_spoon/Assets/custom_colors.dart';
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

  _asyncImgLoad() async {
    //comment out the next two lines to prevent the device from getting
    // the image from the web in order to prove that the picture is
    // coming from the device instead of the web.
    var authority = _user.photoURL.split("//")[1].split("/")[0];
    var path = _user.photoURL.split(".com")[1];
    var uri = new Uri.https(authority, path);
    var response = await get(uri); // <--2
    var documentDirectory = await getApplicationDocumentsDirectory();
    var firstPath = documentDirectory.path + "/images";
    var filePathAndName = documentDirectory.path + '/images/pic.jpg';
    //comment out the next three lines to prevent the image from being saved
    //to the device to show that it's coming from the internet
    await Directory(firstPath).create(recursive: true); // <-- 1
    File file2 = new File(filePathAndName); // <-- 2
    file2.writeAsBytesSync(response.bodyBytes); // <-- 3
    setState(() {
      imageData = filePathAndName;
      dataLoaded = true;
    });
  }

  String imageData;
  bool dataLoaded = false;
  bool check=false;

  final usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.red,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints.tightFor(height: MediaQueryData.fromWindow(window).size.height),
          child: InkWell(
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
                          padding: const EdgeInsets.only(
                            left: 16.0,
                            right: 16.0,
                            bottom: 20.0,
                          ),
                          child: Column(
                            children: <Widget>[
                              Text(
                                'Ciao ' + '${_user.displayName}!',
                                style: TextStyle(
                                  color: CustomColors.white,
                                  fontSize: 26,
                                ),
                              ),
                              SizedBox(height: 16.0),
                              TextField(
                                cursorColor: CustomColors.white,
                                decoration: InputDecoration(
                                    counterStyle:
                                        TextStyle(color: CustomColors.gray),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: CustomColors.gray),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.white),
                                    ),
                                    hintText: "Inserisci qui il tuo username",
                                    hintStyle: TextStyle(color: CustomColors.gray)),
                                controller: usernameController,
                                maxLength: 20,
                                style: TextStyle(color: CustomColors.white),
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              AnimatedSwitcher(
                                duration: Duration(milliseconds: 250),
                                child:check?CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white),): ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      CustomColors.red,
                                    ),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                  onPressed: () async {
                                    setState(() {
                                      check=true;
                                    });
                                    await checkUsername(usernameController.text, context,
                                        _user, imageData);
                                    setState(() {
                                      check=false;
                                    });
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                                    child: Text(
                                      'Registrami!',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 2,
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
}
