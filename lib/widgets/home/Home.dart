import 'dart:async';
import 'dart:ui';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:musiquamiapp/utils/CustomColors.dart';
import 'package:musiquamiapp/widgets/accessroom/AccessRoom.dart';
import 'package:musiquamiapp/widgets/common/BlurredLogo.dart';
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
    super.dispose();
    subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            body: Center(
                child: connectivityResult == ConnectivityResult.none
                    ? Offline()
                    : Stack(children: [
                        BlurredLogo(),
                        Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 30, right: 30),
                                child: Text(
                                  'Mettez votre propre musique chez vos amis dès maintenant avec Musiquami.',
                                  style: Theme.of(context).textTheme.headline1,
                                ),
                              ),
                              Padding(
                                  padding: EdgeInsets.only(left: 20, right: 20),
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Padding(
                                            padding:
                                                EdgeInsets.only(bottom: 20),
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
                                                      color: CustomColors
                                                          .sakuraCream),
                                                ),
                                                style: Theme.of(context)
                                                    .elevatedButtonTheme
                                                    .style)),
                                        Padding(
                                            padding: EdgeInsets.only(top: 20),
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
                                                      color: CustomColors
                                                          .sakuraCream),
                                                ),
                                                style: Theme.of(context)
                                                    .elevatedButtonTheme
                                                    .style))
                                      ]))
                            ])
                      ]))));
  }
}
