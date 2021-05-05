import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:musiquamiapp/widgets/room/Room.dart';

class RoomSas extends StatelessWidget {
  RoomSas(this.roomCode);

  static const routeName = '/roomsas';
  final String roomCode;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        // pop straight to homepage instead of SpotifyAuth webpage
        onWillPop: () async {
          Navigator.of(context).popUntil((route) => route.isFirst);
          return true;
        },
        child: Scaffold(
            appBar: AppBar(leading: Builder(builder: (BuildContext context) {
              return IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                color: Theme.of(context).accentColor,
              );
            })),
            body: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                      padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
                      child: Wrap(children: [
                        Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 40),
                            child: Text('Ta salle est créée !',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline1
                                    .copyWith(fontSize: 30))),
                        Text(
                            'Les autres peuvent y avoir accès en rentrant le code suivant :',
                            style: Theme.of(context)
                                .textTheme
                                .headline1
                                .copyWith(fontSize: 25))
                      ])),
                  Text(roomCode,
                      style: Theme.of(context)
                          .textTheme
                          .headline1
                          .copyWith(fontSize: 45)),
                  Padding(
                      padding: EdgeInsets.fromLTRB(60, 0, 60, 0),
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).push(
                            new MaterialPageRoute(
                                builder: (context) =>
                                    new Room(code: roomCode))),
                        child: Text('J\'accède à ma salle',
                            style: Theme.of(context).textTheme.button),
                        style: Theme.of(context).elevatedButtonTheme.style,
                      ))
                ])));
  }
}
