import 'package:flutter/material.dart';
import 'package:musiquamiapp/widgets/common/BlurredLogo.dart';

class Offline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        BlurredLogo(),
        Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text('Aucune connexion !',
                    style: Theme.of(context).textTheme.headline1)),
            Icon(
              Icons.wifi_off,
              color: Theme.of(context).accentColor,
              size: 100,
            )
          ],
        ))
      ]),
    );
  }
}
