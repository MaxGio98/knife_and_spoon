import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:knife_and_spoon/Assets/custom_colors.dart';
import 'package:knife_and_spoon/Models/utente.dart';
import 'package:knife_and_spoon/Pages/sign_in_screen.dart';
import 'package:knife_and_spoon/Pages/username_change_screen.dart';
import 'package:knife_and_spoon/Utils/authentication.dart';

class SettingsScreen extends StatefulWidget
{
  const SettingsScreen({Key key, @required Utente utente}): _utente=utente;
  final Utente _utente;
  @override
_SettingsScreenState createState()=>_SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
{
  Utente _actualUser;
  @override
  void initState() {
    _actualUser=widget._utente;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width=MediaQuery.of(context).size.width;
    var height=MediaQuery.of(context).size.height;
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            iconTheme: IconThemeData(color: CustomColors.red,),
          ),
        body: Stack(
          children: [
            Column(
              children: [
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
                Padding(
                  padding: EdgeInsets.only(top: height*0.10),
                  child: Center(
                    child: SizedBox(
                      width: width*(0.75),
                      height: height*(0.075),
                      child: OutlinedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(CustomColors.red),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                        ),
                        onPressed: ()  {
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
                  padding: EdgeInsets.only(top: height*0.015),
                  child: Center(
                    child: SizedBox(
                      width: width*(0.75),
                      height: height*(0.075),
                      child: OutlinedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(CustomColors.red),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                        ),
                        onPressed: ()  {
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
              padding: EdgeInsets.only(bottom: height*(0.01)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Center(
                    child: SizedBox(
                      width: width*(0.75),
                      height: height*(0.075),
                      child: OutlinedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(CustomColors.red),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                        ),
                        onPressed: ()  async {
                          await Authentication.signOut(context: context);
                          Navigator.of(context).pushAndRemoveUntil(_routeToSignInScreen(),(Route<dynamic> route) => false);

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
    )
    );
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