import 'package:flutter/material.dart';

class PanelHeader extends StatelessWidget {
  final int queueLength;

  PanelHeader(this.queueLength);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 70,
        color: Theme.of(context).bottomAppBarColor,
        width: MediaQuery.of(context).size.width,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('File d\'attente ($queueLength)',
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .copyWith(fontSize: 20)),
              Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Icon(
                    Icons.keyboard_arrow_up,
                    color: Theme.of(context).accentColor,
                    size: 50,
                  ))
            ]));
  }
}
