import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: connectivityResult == ConnectivityResult.none
                ? Offline()
                : Wrap(children: <Widget>[
                    ElevatedButton(
                        onPressed: () => Navigator.push(
                            context,
                            PageTransition(
                                child: SpotifyAuth(),
                                type: PageTransitionType.rightToLeft)),
                        child: Text('Créer une salle')),
                    ElevatedButton(
                        onPressed: () => Navigator.push(
                            context,
                            PageTransition(
                                child: AccessRoom(),
                                type: PageTransitionType.rightToLeft)),
                        child: Text('Rejoindre une salle'))
                  ])));
  }
}
