import 'package:flutter/material.dart';
import 'package:musiquamiapp/entities/Track.dart';

class ConfirmationDialog extends StatelessWidget {
  ConfirmationDialog(this.track, this.onConfirm);

  final Track track;
  final Function onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('T\'es sûr ?'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(
                'Tu vas mettre ${track.name} de ${track.artists} dans la file d\'attente.'),
            Text('C\'est parti tu nous mets bien ?'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Non'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(child: Text('Allez!'), onPressed: onConfirm),
      ],
    );
  }
}
