import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:musiquamiapp/widgets/room/Room.dart';

class RoomSas extends StatelessWidget {
  RoomSas(this.roomCode);

  static const routeName = '/roomsas';
  final String roomCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(leading: Builder(builder: (BuildContext context) {
          return IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.of(context).pop();
            },
          );
        })),
        body: Center(
            child: Wrap(children: [
          Text(
              'Ta salle est créée! Les autres peuvent y avoir accès en rentrant le code $roomCode'),
          ElevatedButton(
              onPressed: () => Navigator.of(context).push(new MaterialPageRoute(
                  builder: (context) => new Room(code: roomCode))),
              child: Text('J\'accède à ma salle'))
        ])));
  }
}
