import 'package:flutter/cupertino.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:knife_and_spoon/Widgets/custom_alert_dialog.dart';

class CheckConnection extends StatefulWidget {
  final Widget child;
  final Function onCase;
  const CheckConnection({Key key, @required this.child, this.onCase}) : super(key: key);

  @override
  _CheckConnectionState createState() => _CheckConnectionState();
}

class _CheckConnectionState extends State<CheckConnection> {
  var subscription;
  bool dialogShown = false;

  @override
  void initState() {
    checkConnection();
    super.initState();
  }

  @override
  dispose() {
    super.dispose();

    subscription.cancel();
  }

  void checkConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none && !dialogShown) {
      dialogShown=true;
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => buildConnectionAlertDialog(() async {
                var connectivityResult =
                    await (Connectivity().checkConnectivity());
                if (connectivityResult != ConnectivityResult.none) {
                  if(widget.onCase!=null)
                    {
                      widget.onCase();
                    }
                  Navigator.of(context).pop();
                  dialogShown=false;
                }
              }));
    }
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none && !dialogShown) {
        dialogShown=true;
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => buildConnectionAlertDialog(() async {
                  var connectivityResult =
                      await (Connectivity().checkConnectivity());
                  if (connectivityResult != ConnectivityResult.none) {
                    if(widget.onCase!=null)
                    {
                      widget.onCase();
                    }
                    Navigator.of(context).pop();
                    dialogShown=false;
                  }
                }));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
