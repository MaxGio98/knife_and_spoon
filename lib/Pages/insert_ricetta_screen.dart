import 'dart:collection';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_permission_validator/easy_permission_validator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knife_and_spoon/Assets/custom_colors.dart';
import 'package:knife_and_spoon/Models/utente.dart';
import 'package:knife_and_spoon/Utils/check_connection.dart';
import 'package:knife_and_spoon/Utils/get_image.dart';
import 'package:knife_and_spoon/Widgets/custom_alert_dialog.dart';
import 'package:knife_and_spoon/Widgets/permission_warning.dart';
import 'package:uuid/uuid.dart';

class InsertRicettaScreen extends StatefulWidget {
  const InsertRicettaScreen({Key key, @required Utente utente})
      : _utente = utente;
  final Utente _utente;

  @override
  _InsertRicettaScreenState createState() => _InsertRicettaScreenState();
}

class _InsertRicettaScreenState extends State<InsertRicettaScreen>
    with SingleTickerProviderStateMixin {
  Utente _actualUser;
  bool imgInserted = false;
  ScrollController _scrollController;
  AnimationController _hideFabAnimController;
  File f;
  final titleController = TextEditingController();

  final timeController = TextEditingController();
  final peopleController = TextEditingController();
  String dropdownCat = "Antipasto";

  List<TextEditingController> nameIngCList = [];
  List<TextEditingController> qtIngCList = [];
  List<String> dropdownValueIng = [];
  List<bool> qbSelected = [];
  List<TextEditingController> passaggiCtList = [];

  @override
  void initState() {
    _actualUser = widget._utente;
    loadScrollController();
    _scrollController.addListener(() => setState(() {}));
    checkTextIntPositive(timeController);
    checkTextIntPositive(peopleController);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _hideFabAnimController.dispose();
    for (var value in nameIngCList) {
      value.dispose();
    }
    for (var value1 in qtIngCList) {
      value1.dispose();
    }
    for (var value2 in passaggiCtList) {
      value2.dispose();
    }
    super.dispose();
  }

  void loadScrollController() {
    _scrollController = ScrollController();
    _hideFabAnimController = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
      value: 1, // initially visible
    );

    _scrollController.addListener(() {
      switch (_scrollController.position.userScrollDirection) {
        // Scrolling up - forward the animation (value goes to 1)
        case ScrollDirection.forward:
          _hideFabAnimController.forward();
          break;
        // Scrolling down - reverse the animation (value goes to 0)
        case ScrollDirection.reverse:
          _hideFabAnimController.reverse();
          break;
        // Idle - keep FAB visibility unchanged
        case ScrollDirection.idle:
          break;
      }
    });
  }

  void checkTextIntPositive(var controller) {
    controller.addListener(() {
      if (controller.text.toString() != "") {
        if (controller.text.toString().substring(0, 1) == "0") {
          int lenght = controller.text.length;
          controller.text = controller.text.toString().substring(1, lenght);
        }
      }
    });
  }

  void _addNewIngrediente() {
    setState(() {
      nameIngCList.add(TextEditingController());
      qtIngCList.add(TextEditingController());
      qtIngCList[(qtIngCList.length - 1)].addListener(() {
        checkQtIng((qtIngCList.length - 1));
      });
      dropdownValueIng.add("unità");
      qbSelected.add(false);
    });
  }

  void _removeIngrediente(int i) {
    nameIngCList.removeAt(i);
    qtIngCList.removeAt(i);
    dropdownValueIng.removeAt(i);
    qbSelected.removeAt(i);
    setState(() {});
  }

  void _addNewPassaggio() {
    setState(() {
      passaggiCtList.add(TextEditingController());
    });
  }

  void _removePassaggio(int i) {
    setState(() {
      passaggiCtList.removeAt(i);
    });
  }

  void checkQtIng(int i) {
    if (qtIngCList[i].text.length > 1) {
      if (qtIngCList[i].text.startsWith("0")) {
        if (!(qtIngCList[i].text.substring(1, 2) == ".")) {
          qtIngCList[i].text = "0";
          qtIngCList[i].selection = TextSelection.fromPosition(
              TextPosition(offset: qtIngCList[i].text.length));
        }
      }
    }
  }

  void checkFields() {
    if (!imgInserted) {
      showErrorDialog("una foto del piatto");
      return;
    }
    if (titleController.text.trim().isEmpty) {
      showErrorDialog("il titolo della ricetta");
      return;
    }
    if (timeController.text.isEmpty) {
      showErrorDialog("il tempo di preparazione");
      return;
    }
    if (peopleController.text.isEmpty) {
      showErrorDialog("il numero delle persone");
      return;
    }
    if (nameIngCList.isEmpty) {
      showErrorDialog("almeno un ingrediente");
      return;
    } else {
      for (int i = 0; i < nameIngCList.length; i++) {
        if (nameIngCList[i].text.trim().isEmpty) {
          showErrorDialog(
              "il nome del " + (i + 1).toString() + "° ingrediente");
          return;
        }
        if (qtIngCList[i].text.isEmpty||qtIngCList[i].text=="0") {
          showErrorDialog(
              "la quantità del " + (i + 1).toString() + "° ingrediente");
          return;
        }
      }
    }
    if (passaggiCtList.isEmpty) {
      showErrorDialog("almeno un passaggio");
      return;
    } else {
      for (int i = 0; i < passaggiCtList.length; i++) {
        if (passaggiCtList[i].text.trim().isEmpty) {
          showErrorDialog(
              "la descrizione del " + (i + 1).toString() + "° passaggio");
          return;
        }
      }
    }

    pubblicaRicetta();
  }

  Future<void> showErrorDialog(String err) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return buildCustomAlertOKDialog(
            context, "Attenzione", "Inserisci " + err + ".");
      },
    );
  }

  void pubblicaRicetta()
  {
    List<String> passaggi=[];
    for (int i=0;i<passaggiCtList.length;i++) {
      passaggi.add(passaggiCtList[i].text);
    }
    List<Map> ingredienti=[];
    for (int i=0;i<nameIngCList.length;i++) {
      Map<String,String> mapIng=new Map();
      mapIng["Nome"]=nameIngCList[i].text.trim();
      mapIng["Quantità"]=qtIngCList[i].text;
      mapIng["Unità misura"]=dropdownValueIng[i];
      ingredienti.add(mapIng);
    }
    Map<String,dynamic>ricettaToUpload=new HashMap();
    ricettaToUpload["Autore"]=_actualUser.id;
    ricettaToUpload["Titolo"]=titleController.text.trim();
    ricettaToUpload["Categoria"]=dropdownCat;
    ricettaToUpload["Timestamp"]=FieldValue.serverTimestamp();
    ricettaToUpload["TempoPreparazione"]=timeController.text;
    ricettaToUpload["NumeroPersone"]=peopleController.text;
    ricettaToUpload["Passaggi"]=passaggi;
    ricettaToUpload["Ingredienti"]=ingredienti;
    ricettaToUpload["isApproved"]=false;
    uploadToFirebase(ricettaToUpload);
  }

  void uploadToFirebase(Map ricetta) async
  {
    var uuid = Uuid().v4();
    Reference ref=FirebaseStorage.instance.ref();
    Reference img=ref.child(uuid.toString() + ".jpg");
    await img.putFile(f);
    await img.getDownloadURL().then((url)
    {
      ricetta["Thumbnail"]=url;
      FirebaseFirestore.instance.collection("Ricette").add(ricetta).then((value) {
        print("CIAO");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return CheckConnection(
      child: SafeArea(
          child: Scaffold(
              floatingActionButton: FadeTransition(
                opacity: _hideFabAnimController,
                child: ScaleTransition(
                  scale: _hideFabAnimController,
                  child: FloatingActionButton.extended(
                    heroTag: "btnPublish",
                    onPressed: () {
                      checkFields();
                    },
                    label: Text("Pubblica"),
                    icon: Icon(Icons.edit),
                  ),
                ),
              ),
              body: NestedScrollView(
                controller: _scrollController,
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                      expandedHeight: height * (0.3),
                      floating: false,
                      pinned: true,
                      backgroundColor: CustomColors.red,
                      flexibleSpace: FlexibleSpaceBar(
                          centerTitle: false,
                          title: Text(titleController.text.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: width * .05,
                              )),
                          background: Stack(
                            fit: StackFit.expand,
                            children: [
                              imgInserted
                                  ? Image.file(
                                      f,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      "assets/pizza.png",
                                      fit: BoxFit.cover,
                                    ),
                              Container(
                                height: width * 0.1,
                                width: width,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment(0, -1),
                                    end: Alignment(0, 0.5),
                                    colors: [
                                      const Color(0xCC000000).withOpacity(0.6),
                                      const Color(0x00000000),
                                      const Color(0x00000000),
                                      const Color(0xCC000000).withOpacity(0.6),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )),
                    ),
                  ];
                },
                body: ListView(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(width * (0.04)),
                      child: Column(children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: Padding(
                              padding: EdgeInsets.only(right: width * (0.05)),
                              child: TextField(
                                controller: titleController,
                                maxLength: 30,
                                decoration: InputDecoration(
                                    hintText:
                                        "Inserisci il titolo della ricetta",
                                    counterText: ""),
                              ),
                            )),
                            FloatingActionButton(
                              heroTag: "btnAddImg",
                              onPressed: () async {
                                EasyPermissionValidator
                                    permissionValidatorStorage =
                                    EasyPermissionValidator(
                                  appName: "",
                                  context: context,
                                  customDialog:
                                      buildWarningPermissions(context),
                                );
                                var resultStorage =
                                    await permissionValidatorStorage.storage();
                                if (resultStorage) {
                                  EasyPermissionValidator
                                      permissionValidatorCamera =
                                      EasyPermissionValidator(
                                    appName: "",
                                    context: context,
                                    customDialog:
                                        buildWarningPermissions(context),
                                  );
                                  var resultCamera =
                                      await permissionValidatorCamera.camera();
                                  if (resultCamera) {
                                    _showPicker(context);
                                  }
                                }
                              },
                              child: Icon(Icons.camera_alt_outlined),
                            )
                          ],
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: height * (0.015)),
                            child: Row(children: [
                              SvgPicture.asset(
                                "assets/clock.svg",
                                height: width * (0.125),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: width * (0.05)),
                                child: Container(
                                  width: width * 0.31,
                                  child: TextField(
                                    controller: timeController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp("[0-9]"))
                                    ],
                                    textAlign: TextAlign.center,
                                    maxLength: 4,
                                    decoration: InputDecoration(
                                        hintText: "Tempo in minuti",
                                        counterText: ""),
                                  ),
                                ),
                              ),
                            ])),
                        Padding(
                            padding: EdgeInsets.only(top: height * (0.015)),
                            child: Row(children: [
                              SvgPicture.asset(
                                "assets/group.svg",
                                height: width * (0.125),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: width * (0.05)),
                                child: Container(
                                  width: width * 0.31,
                                  child: TextField(
                                    controller: peopleController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp("[0-9]"))
                                    ],
                                    maxLength: 2,
                                    decoration: InputDecoration(
                                        hintText: "Numero persone",
                                        counterText: ""),
                                  ),
                                ),
                              ),
                            ])),
                        Padding(
                            padding: EdgeInsets.only(top: height * (0.015)),
                            child: Row(children: [
                              Text(
                                "Categoria",
                                style: TextStyle(fontSize: width * (0.05)),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: width * (0.05)),
                                child: DropdownButton<String>(
                                  focusColor: CustomColors.red,
                                  value: dropdownCat,
                                  iconSize: 0,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: width * (0.05)),
                                  underline: Container(
                                    height: 2,
                                    color: CustomColors.silver,
                                  ),
                                  onChanged: (String newValue) {
                                    setState(() {
                                      dropdownCat = newValue;
                                    });
                                  },
                                  items: <String>[
                                    'Antipasto',
                                    'Primo',
                                    'Secondo',
                                    'Contorno',
                                    'Dolce'
                                  ].map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ])),
                        ListView.builder(
                            itemCount: qtIngCList.length,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, i) {
                              //return RowIngrediente();
                              return buildRowIngrediente(i);
                            }),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: height * 0.015),
                              child: Center(
                                child: SizedBox(
                                  width: width * (0.75),
                                  height: height * (0.075),
                                  child: OutlinedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              CustomColors.red),
                                      shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(40),
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      _addNewIngrediente();
                                    },
                                    child: Text(
                                      'Inserisci un ingrediente',
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
                        ListView.builder(
                            itemCount: passaggiCtList.length,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, i) {
                              return buildRowPassaggio(i);
                            }),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: height * 0.025),
                              child: Center(
                                child: SizedBox(
                                  width: width * (0.75),
                                  height: height * (0.075),
                                  child: OutlinedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              CustomColors.red),
                                      shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(40),
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      _addNewPassaggio();
                                    },
                                    child: Text(
                                      'Inserisci un passaggio',
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
                        )
                      ]),
                    )
                  ],
                ),
              ))),
    );
  }

  Widget buildRowIngrediente(int i) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Row(
          children: [
            FloatingActionButton(
              onPressed: () {
                _removeIngrediente(i);
              },
              child: Icon(Icons.remove),
            ),
            Expanded(
              child: Padding(
                  padding: EdgeInsets.only(top: height * (0.015)),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: width * .05,
                          ),
                          Expanded(
                            child: TextField(
                              controller: nameIngCList[i],
                              textAlign: TextAlign.center,
                              maxLength: 25,
                              decoration: InputDecoration(
                                  hintText: "Nome ingrediente",
                                  counterText: ""),
                            ),
                          ),
                          SizedBox(
                            width: width * .05,
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: width * .05,
                          ),
                          Expanded(
                            child: !qbSelected[i]
                                ? TextFormField(
                                    controller: qtIngCList[i],
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r"^\d+([.]\d{0,2})?$"))
                                    ],
                                    textAlign: TextAlign.center,
                                    maxLength: 6,
                                    decoration: InputDecoration(
                                        hintText: "Quantità", counterText: ""),
                                  )
                                : SizedBox(),
                          ),
                          SizedBox(
                            width: width * .05,
                          ),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              focusColor: CustomColors.red,
                              value: dropdownValueIng[i],
                              icon: Icon(Icons.arrow_downward),
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: width * (0.05)),
                              onChanged: (String newValue) {
                                if (newValue == "q.b.") {
                                  qtIngCList[i].text = "0";
                                  qbSelected[i] = true;
                                } else {
                                  if (qbSelected[i] == true) {
                                    qbSelected[i] = false;
                                    qtIngCList[i].text = "";
                                  }
                                }

                                setState(() {
                                  dropdownValueIng[i] = newValue;
                                });
                              },
                              items: <String>[
                                'unità',
                                'grammi',
                                'kg',
                                'bicchiere',
                                'litri',
                                'cucchiaio',
                                'cucchiaino',
                                'millilitri',
                                'q.b.'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                          SizedBox(
                            width: width * .05,
                          ),
                        ],
                      ),
                    ],
                  )),
            ),
          ],
        )
      ],
    );
  }

  Widget buildRowPassaggio(int i) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.only(top: height * (0.015)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FloatingActionButton(
              child: Icon(Icons.remove),
              onPressed: () {
                _removePassaggio(i);
              }),
          SizedBox(
            width: width * (0.05),
          ),
          Expanded(
            child: TextFormField(
              keyboardType: TextInputType.multiline,
              textAlign: TextAlign.left,
              maxLines: 4,
              style: TextStyle(fontSize: width * (0.05)),
              controller: passaggiCtList[i],
            ),
          ),
          SizedBox(
            width: width * (0.05),
          ),
        ],
      ),
    );
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
                        f = await getImageGallery();
                        if (f != null) {
                          setState(() {
                            imgInserted = true;
                          });
                        }

                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () async {
                      f = await getImageCamera();
                      if (f != null) {
                        setState(() {
                          imgInserted = true;
                        });
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }
}
