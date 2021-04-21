import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:knife_and_spoon/Assets/custom_colors.dart';
import 'package:knife_and_spoon/Models/utente.dart';
import 'package:knife_and_spoon/Utils/username_change_check.dart';
import 'package:knife_and_spoon/Utils/username_check.dart';

class ChangeUsernameScreen extends StatefulWidget
{
  const ChangeUsernameScreen({Key key, @required Utente utente}): _utente=utente;
  final Utente _utente;
  @override
  _ChangeUsernameScreenState createState()=>_ChangeUsernameScreenState();
}

class _ChangeUsernameScreenState extends State<ChangeUsernameScreen>
{
  Utente _actualUser;


  @override
  void initState() {
    _actualUser=widget._utente;
    super.initState();
  }

  bool check=false;
  final usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var height=MediaQuery.of(context).size.height;
    var width=MediaQuery.of(context).size.width;
      return SafeArea(child: Scaffold(
        backgroundColor: CustomColors.red,
      body: SingleChildScrollView(
        child: Container(
          height: height,
          width: width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 7,
                child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Center(
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(width*(0.7)),
                              child: Image.network(
                                _actualUser.immagine,
                                fit: BoxFit.cover,
                                height: width*(0.7),
                                width: width*(0.7),
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
                              )
                          ),
                        ),
                      ],
                    )),
              ),
              Expanded(
                  flex: 6,
                  child: Padding(
                    padding: EdgeInsets.only(top:width*(0.05),left: width*(0.05),right: width*(0.05)),
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Ciao ' + _actualUser.nome,
                          style: TextStyle(
                            color: CustomColors.white,
                            fontSize: 26,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: width*(0.05)),
                          child: TextField(
                            cursorColor: CustomColors.white,
                            decoration: InputDecoration(
                                counterStyle:
                                TextStyle(color: CustomColors.silver),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                  BorderSide(color: CustomColors.silver),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                hintText: "Inserisci qui il tuo nuovo username",
                                hintStyle: TextStyle(color: CustomColors.silver)),
                            controller: usernameController,
                            maxLength: 20,
                            style: TextStyle(color: CustomColors.white),
                            onSubmitted: (value){
                              checkValue();
                            },
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 250),
                          child:check?CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white),): SizedBox(
                            width: width*(0.75),
                            height: height*(0.075),
                            child: OutlinedButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(CustomColors.white),
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                ),
                              ),
                              onPressed: () {
                                checkValue();
                              },
                              child: Text(
                                'Cambia il mio username!',
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
        ),
      ),
      )
      );
  }

  void checkValue() async
  {
    setState(() {
      check=true;
    });
    await checkChangeUsername(usernameController.text, context,
        _actualUser);
    setState(() {
      check=false;
    });
  }
}