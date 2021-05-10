import 'package:flutter/material.dart';
import 'package:musiquamiapp/services/FirebaseService.dart';
import 'package:musiquamiapp/utils/CustomColors.dart';
import 'package:musiquamiapp/widgets/home/Home.dart';

class RoomPresentation extends StatelessWidget {
  final String code;
  final bool isRoomOwned;

  RoomPresentation(this.code, this.isRoomOwned);
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Padding(
          padding: EdgeInsets.only(left: 30, right: 30, bottom: 50),
          child: Wrap(children: [
            Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: Text('Bienvenue 👋',
                    style: Theme.of(context)
                        .textTheme
                        .headline1
                        .copyWith(fontSize: 30))),
            Text(
                'Tu peux inviter d\'autres personnes en leur donnant ce code :',
                style: Theme.of(context)
                    .textTheme
                    .headline1
                    .copyWith(fontSize: 25))
          ])),
      Text(code,
          style: Theme.of(context).textTheme.headline1.copyWith(fontSize: 45)),
      if (isRoomOwned)
        Padding(
            padding: EdgeInsets.only(left: 40, right: 40, top: 80),
            child: ElevatedButton(
                onPressed: () {
                  // delete room then back to homepage
                  FirebaseService.deleteRoom(code);
                  Navigator.of(context).push(
                      new MaterialPageRoute(builder: (context) => Home()));
                },
                child: Text('Supprimer cette salle',
                    style: TextStyle(
                        fontSize: 22, color: CustomColors.sakuraCream)),
                style: Theme.of(context).elevatedButtonTheme.style))
    ]);
  }
}
