import 'package:flutter/material.dart';
import 'package:knife_and_spoon/Assets/custom_colors.dart';
import 'package:knife_and_spoon/Models/ricetta.dart';
import 'package:knife_and_spoon/Models/utente.dart';
import 'package:knife_and_spoon/Pages/ricetta_show_screen.dart';

class RicettaButton extends StatefulWidget {
  const RicettaButton(
      {Key key,
      @required Utente utente,
      @required List<Ricetta> ricette,
      Function onCase})
      : _utente = utente,
        _ricette = ricette,
        onCase = onCase,
        super(key: key);
  final Utente _utente;
  final List<Ricetta> _ricette;
  final Function onCase;

  @override
  _RicettaButtonState createState() => _RicettaButtonState();
}

class _RicettaButtonState extends State<RicettaButton> {
  Utente _actualUser;
  List<Ricetta> _ricette;

  @override
  void initState() {
    _actualUser = widget._utente;
    _ricette = widget._ricette;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: _ricette.length,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, i) {
          return Container(
            height: MediaQuery.of(context).size.height * .2,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding:
                  EdgeInsets.all(MediaQuery.of(context).size.width * (.02)),
              child: Material(
                child: InkWell(
                  onTap: () {
                    if (widget.onCase == null) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => RicettaShow(
                                    utente: _actualUser,
                                    ricetta: _ricette[i],
                                  )));
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => RicettaShow(
                                    utente: _actualUser,
                                    ricetta: _ricette[i],
                                  ))).then((value) => widget.onCase());
                    }
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          _ricette[i].thumbnail,
                          fit: BoxFit.cover,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes
                                    : null,
                                valueColor: new AlwaysStoppedAnimation<Color>(
                                    CustomColors.red),
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.width * 0.1,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            begin: Alignment(0, -1),
                            end: Alignment(0, 0.5),
                            colors: [
                              const Color(0xCC000000).withOpacity(0.1),
                              const Color(0x00000000),
                              const Color(0x00000000),
                              const Color(0xCC000000).withOpacity(0.6),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Align(
                                alignment: Alignment.bottomLeft,
                                child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: Text(
                                      _ricette[i].title,
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              (.05),
                                          color: CustomColors.white),
                                    ))),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
