import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:knife_and_spoon/custom_colors.dart';
import 'package:knife_and_spoon/insert_username.dart';
import 'authentication.dart';

class GoogleSignInButton extends StatefulWidget {
  @override
  _GoogleSignInButtonState createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _isSigningIn = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: _isSigningIn
          ? CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(CustomColors.white),
      )
          : OutlinedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(CustomColors.white),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        ),
        onPressed: () async {setState((){
          _isSigningIn=true;
        });
        User? user = await Authentication.signInWithGoogle(context: context);
        setState(() {
          _isSigningIn = false;
        });
        if (user != null) {
          FirebaseFirestore.instance
              .collection('Utenti')
              .get()
              .then((QuerySnapshot querySnapshot) {
            querySnapshot.docs.forEach((doc) {
              //l'utente è entrato con l'account almeno una volta
              if(doc["Mail"]==user.email)
              {
                if(doc["Nome"]!="")
                {
                  //l'utente si è registrato in maniera corretta
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => InsertUsernameScreen(user: user)));
                }
                else
                {
                  //l'utente era già entrato con l'account ma non aveva completato la procedura di registrazione
                }

              }
              else
              {
                //l'utente entra per la prima volta con l'account
              }
            });
          });
          //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => UserInfoScreen(user: user,),),);
        }
        // TODO: Add method call to the Google Sign-In authentication
        setState(() {
          _isSigningIn = false;
        });

        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image(
                image: AssetImage("assets/google_logo.png"),
                height: 35.0,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  'Sign in with Google',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}