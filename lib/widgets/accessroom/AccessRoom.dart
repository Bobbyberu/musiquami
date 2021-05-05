import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:musiquamiapp/services/FirebaseService.dart';
import 'package:musiquamiapp/utils/CustomColors.dart';
import 'package:musiquamiapp/widgets/accessroom/RoomNotFoundDialog.dart';
import 'package:musiquamiapp/widgets/room/Room.dart';
import 'package:musiquamiapp/utils/UpperCaseTextFormatter.dart';

class AccessRoom extends StatefulWidget {
  @override
  _AccessRoomState createState() => _AccessRoomState();
}

class _AccessRoomState extends State<AccessRoom> {
  String code;
  bool buttonDisabled = true;
  final _controller = TextEditingController();

  void _valueChanged() {
    setState(() {
      buttonDisabled = _controller.text.length != 4;
    });
  }

// TODO ajouter loaders pour retour utilisateur?
  @override
  Widget build(BuildContext context) {
    return Theme(
        data: Theme.of(context),
        child: Scaffold(
            // keyboard should not move widget when displayed
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              leading: Builder(builder: (BuildContext context) {
                return IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  color: Theme.of(context).accentColor,
                );
              }),
            ),
            body: Column(children: [
              Padding(
                  padding: EdgeInsets.fromLTRB(30, 40, 30, 0),
                  child: Text(
                      'Ici tu peux rentrer le code de la salle à laquelle tu souhaites accéder.',
                      style: Theme.of(context)
                          .textTheme
                          .headline1
                          .copyWith(fontSize: 25))),
              Padding(
                  padding: EdgeInsets.fromLTRB(0, 100, 0, 0),
                  child: Wrap(children: [
                    Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 30),
                        child: TextFormField(
                          style: Theme.of(context)
                              .textTheme
                              .headline2
                              .copyWith(fontSize: 40),
                          controller: _controller,
                          decoration: InputDecoration(hintText: 'CODE'),
                          textAlign: TextAlign.center,
                          onChanged: (value) => _valueChanged(),
                          onFieldSubmitted: (value) => _submit(value),
                          inputFormatters: [
                            MaskedInputFormatter('####',
                                anyCharMatcher: RegExp(r'[a-zA-Z]')),
                            UpperCaseTextFormatter()
                          ],
                          keyboardType: TextInputType.name,
                        )),
                    Padding(
                      padding: EdgeInsets.fromLTRB(80, 30, 80, 0),
                      child: ElevatedButton(
                          // disable button if value has no input
                          onPressed: buttonDisabled
                              ? null
                              : () {
                                  // hide keyboard after pressing button
                                  FocusScope.of(context).unfocus();
                                  _submit(_controller.text);
                                },
                          child: Text('J\'y vais!',
                              style: buttonDisabled
                                  ? TextStyle(color: CustomColors.sakuraDarker)
                                  : Theme.of(context).textTheme.button),
                          style: Theme.of(context).elevatedButtonTheme.style),
                    )
                  ]))
            ])));
  }

  void _submit(String code) async {
    if (await FirebaseService.isRoom(code)) {
      Navigator.of(context).push(
          new MaterialPageRoute(builder: (context) => new Room(code: code)));
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return RoomNotFoundDialog();
          });
    }
  }
}
