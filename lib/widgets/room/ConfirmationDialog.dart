import 'package:flutter/material.dart';
import 'package:musiquamiapp/entities/Track.dart';

class ConfirmationDialog extends StatelessWidget {
  ConfirmationDialog(this.track, this.onConfirm);

  final Track track;
  final Function onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Text(
        'T\'es sûr ?',
        style: Theme.of(context)
            .textTheme
            .bodyText1
            .copyWith(fontWeight: FontWeight.w900),
      ),
      content: SingleChildScrollView(
        child: RichText(
            text: TextSpan(
                style: Theme.of(context).textTheme.bodyText1,
                children: [
              TextSpan(text: 'Tu vas mettre '),
              TextSpan(
                  text: track.name,
                  style: TextStyle(fontWeight: FontWeight.w900)),
              TextSpan(
                  text:
                      ' de ${_getFirstArtist(track.artists)} dans la file d\'attente. '),
              TextSpan(text: 'C\'est parti tu nous mets bien ?')
            ])),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Non', style: TextStyle(fontWeight: FontWeight.w900)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
            child:
                Text('Allez !', style: TextStyle(fontWeight: FontWeight.w900)),
            onPressed: onConfirm),
      ],
    );
  }

  String _getFirstArtist(String artists) {
    return artists.split(',')[0];
  }
}
