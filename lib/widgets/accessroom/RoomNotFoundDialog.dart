import 'package:flutter/material.dart';

class RoomNotFoundDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'P\'tit problème',
          style: Theme.of(context)
              .textTheme
              .bodyText1
              .copyWith(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                'Je n\'ai trouvé aucune salle avec ce code !',
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
              child: Text(
                'Ok',
                style: Theme.of(context).textTheme.bodyText2,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              })
        ]);
  }
}
