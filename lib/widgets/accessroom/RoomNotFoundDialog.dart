import 'package:flutter/material.dart';

class RoomNotFoundDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text('Déso'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('J\'ai pas trouvé de salle mon reuf'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
              child: Text('Flemme'),
              onPressed: () {
                Navigator.of(context).pop();
              })
        ]);
  }
}
