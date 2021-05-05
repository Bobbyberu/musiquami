import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:musiquamiapp/utils/CustomColors.dart';
import 'package:musiquamiapp/widgets/accessroom/AccessRoom.dart';
import 'package:musiquamiapp/widgets/home/SpotifyAuth.dart';
import 'package:musiquamiapp/widgets/offline/Offline.dart';
import 'package:page_transition/page_transition.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  StreamSubscription<ConnectivityResult> subscription;
  ConnectivityResult connectivityResult;

  @override
  void initState() {
    super.initState();
    initConnectivity();
    initConnectivitySubscription();
  }

  void initConnectivity() async {
    var result = await (Connectivity().checkConnectivity());
    setState(() {
      connectivityResult = result;
    });
  }

  void initConnectivitySubscription() {
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        connectivityResult = result;
      });
      if (connectivityResult == ConnectivityResult.none) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });
  }

  @override
  void dispose() {
    print('dispose main');
    super.dispose();
    subscription.cancel();
  }

// TODO gérer si pas spotify premium
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: connectivityResult == ConnectivityResult.none
                ? Offline()
                // TODO rajouter logo stylé quand il y en aura un
                : Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
                          child: Text(
                            'Mettez votre propre musique chez vos amis dès maintenant.',
                            style: Theme.of(context).textTheme.headline1,
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                      padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                                      child: ElevatedButton(
                                          onPressed: () => Navigator.push(
                                              context,
                                              PageTransition(
                                                  child: SpotifyAuth(),
                                                  type: PageTransitionType
                                                      .rightToLeft)),
                                          child: Text(
                                            'Créer une salle',
                                            style: TextStyle(
                                                fontSize: 22,
                                                color:
                                                    CustomColors.sakuraCream),
                                          ),
                                          style: _builButtonStyle())),
                                  Padding(
                                      padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                                      child: ElevatedButton(
                                          onPressed: () => Navigator.push(
                                              context,
                                              PageTransition(
                                                  child: AccessRoom(),
                                                  type: PageTransitionType
                                                      .rightToLeft)),
                                          child: Text(
                                            'Rejoindre une salle',
                                            style: TextStyle(
                                                fontSize: 22,
                                                color:
                                                    CustomColors.sakuraCream),
                                          ),
                                          style: _builButtonStyle()))
                                ]))
                      ])));
  }

  ButtonStyle _builButtonStyle() {
    return ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0))),
        padding: MaterialStateProperty.all(EdgeInsets.all(20)),
        // take width of parent container
        minimumSize: MaterialStateProperty.all(Size(double.infinity, 0)),
        overlayColor: MaterialStateProperty.all(CustomColors.sakuraLighter));
  }
}
