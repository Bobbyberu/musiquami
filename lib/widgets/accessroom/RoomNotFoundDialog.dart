import 'package:flutter/material.dart';

class RoomNotFoundDialog extends StatelessWidget {
  final String message;

  RoomNotFoundDialog(this.message);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'P\'tit problème',
          style: Theme.of(context)
              .textTheme
              .bodyText1
              .copyWith(fontWeight: FontWeight.w900),
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                message,
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
