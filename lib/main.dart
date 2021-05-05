import 'package:flutter/material.dart';
import 'package:musiquamiapp/utils/CustomColors.dart';
import 'package:musiquamiapp/widgets/home/Home.dart';

void main() {
  runApp(MusiquamiApp());
}

class MusiquamiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Musiquami',
      home: Home(),
      theme: ThemeData(
          primarySwatch: CustomColors.sakuraLight,
          appBarTheme: AppBarTheme(
              backgroundColor: CustomColors.sakuraDark, elevation: 0.0),
          accentColor: CustomColors.sakuraCream,
          disabledColor: CustomColors.sakuraDarker,
          textTheme: TextTheme(
              headline1: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: CustomColors.sakuraCream),
              button: TextStyle(color: CustomColors.sakuraCream, fontSize: 22),
              // dialog body text
              bodyText1: TextStyle(
                  color: CustomColors.sakuraCream,
                  fontSize: 17,
                  fontWeight: FontWeight.normal),
              // dialog button text
              bodyText2: TextStyle(
                  color: CustomColors.sakuraLighter,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          buttonTheme: ButtonThemeData(buttonColor: CustomColors.sakuraLight),
          scaffoldBackgroundColor: CustomColors.sakuraDark),
    );
  }
}
