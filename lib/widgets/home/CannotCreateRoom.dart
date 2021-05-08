import 'package:flutter/material.dart';

class CannotCreateRoom extends StatelessWidget {
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
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Text(
                    'Il semblerait que tu ne possèdes pas de compte Spotify premium. Tu ne peux pas créer de salle...',
                    style: Theme.of(context)
                        .textTheme
                        .headline1
                        .copyWith(fontSize: 25))),
            Text(
              '😔',
              style: TextStyle(fontSize: 100),
            ),
            Padding(
                padding: EdgeInsets.only(left: 40, right: 40),
                child: ElevatedButton(
                    onPressed: () => Navigator.of(context)
                        .popUntil((route) => route.isFirst),
                    child: Text(
                      'Je reste dans ma pauvreté',
                      style: Theme.of(context).textTheme.button,
                    )))
          ],
        ),
      ),
    );
  }
}
