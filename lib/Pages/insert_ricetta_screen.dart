import 'dart:io';

import 'package:easy_permission_validator/easy_permission_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knife_and_spoon/Assets/custom_colors.dart';
import 'package:knife_and_spoon/Models/utente.dart';
import 'package:knife_and_spoon/Utils/get_image.dart';
import 'package:knife_and_spoon/Widgets/permission_warning.dart';

class InsertRicettaScreen extends StatefulWidget {
  const InsertRicettaScreen({Key key, @required Utente utente})
      : _utente = utente;
  final Utente _utente;

  @override
  _InsertRicettaScreenState createState() => _InsertRicettaScreenState();
}

class _InsertRicettaScreenState extends State<InsertRicettaScreen> {
  Utente _actualUser;
  bool imgInserted = false;
  ScrollController _scrollController;
  File f;
  final titleController = TextEditingController();

  final timeController = TextEditingController();
  final peopleController = TextEditingController();
  String dropdownValue = "Antipasto";
  String dropdownValueIng = "unità";
  List<TextEditingController> nameIngCList=[];
  List<TextEditingController> qtIngCList=[];

  @override
  void initState() {
    _actualUser = widget._utente;
    _scrollController = new ScrollController();
    _scrollController.addListener(() => setState(() {}));
    checkTextIntPositive(timeController);
    checkTextIntPositive(peopleController);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (var value in nameIngCList) {
      value.dispose();
    }
    for (var value1 in qtIngCList) {
      value1.dispose();

    }
    super.dispose();
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
    });
  }

  void _removeIngrediente(int i)
  {
    nameIngCList.removeAt(i);
    qtIngCList.removeAt(i);
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return SafeArea(
        child: Scaffold(
            floatingActionButton: FloatingActionButton.extended(
              heroTag: "btnPublish",
              onPressed: () {},
              label: Text("Pubblica"),
              icon: Icon(Icons.edit),
            ),
            body: NestedScrollView(
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
                                  hintText: "Inserisci il titolo della ricetta",
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
                                customDialog: buildWarningPermissions(context),
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
                                  maxLength: 4,
                                  decoration: InputDecoration(
                                      hintText: "Numero Persone",
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
                                value: dropdownValue,
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
                                    dropdownValue = newValue;
                                  });
                                },
                                items: <String>[
                                  'Antipasto',
                                  'Primo',
                                  'Secondo',
                                  'Contorno',
                                  'Dolce'
                                ].map<DropdownMenuItem<String>>((String value) {
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
                                    backgroundColor: MaterialStateProperty.all(
                                        CustomColors.red),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(40),
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
                      )
                    ]),
                  )
                ],
              ),
            )));
  }

  Widget buildRowIngrediente(int i)
  {
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
                            width: width*.05,
                          ),
                          Expanded(
                            child: TextField(
                              controller: nameIngCList[i],
                              textAlign: TextAlign.center,
                              maxLength: 25,
                              decoration: InputDecoration(
                                  hintText: "Nome ingrediente", counterText: ""),
                            ),
                          ),
                          SizedBox(
                            width: width*.05,
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: width*.05,
                          ),
                          Expanded(
                            child: TextFormField(
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
                            ),
                          ),
                          SizedBox(
                            width: width*.05,
                          ),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              focusColor: CustomColors.red,
                              value: dropdownValueIng,
                              icon: Icon(Icons.arrow_downward),
                              style: TextStyle(
                                  color: Colors.black, fontSize: width * (0.05)),
                              onChanged: (String newValue) {
                                setState(() {
                                  dropdownValueIng = newValue;
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
                            width: width*.05,
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
