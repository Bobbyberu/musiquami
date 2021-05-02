import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:musiquamiapp/services/FirebaseService.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(leading: Builder(builder: (BuildContext context) {
          return IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.of(context).pop();
            },
          );
        })),
        body: Center(
            child: Wrap(children: <Widget>[
          TextFormField(
            controller: _controller,
            decoration:
                InputDecoration(border: OutlineInputBorder(), hintText: 'ABCD'),
            textAlign: TextAlign.center,
            onChanged: (value) => _valueChanged(),
            onFieldSubmitted: (value) => _submit(value),
            inputFormatters: [
              MaskedInputFormatter('####', anyCharMatcher: RegExp(r'[a-zA-Z]')),
              UpperCaseTextFormatter()
            ],
            keyboardType: TextInputType.name,
          ),
          ElevatedButton(
            // disable button if value has no input
            onPressed: buttonDisabled
                ? null
                : () {
                    // hide keyboard after pressing button
                    FocusScope.of(context).unfocus();
                    _submit(_controller.text);
                  },
            child: Text('J\'y vais!'),
          )
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
