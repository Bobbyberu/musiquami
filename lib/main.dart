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
          inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: CustomColors.sakuraDarker,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40.0))),
          textTheme: TextTheme(
            // top headline
            headline1: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: CustomColors.sakuraCream),
            // input text style
            headline2: TextStyle(color: CustomColors.sakuraCream, fontSize: 18),
            button: TextStyle(color: CustomColors.sakuraCream, fontSize: 22),
            // dialog and list view body text
            bodyText1: TextStyle(
                color: CustomColors.sakuraCream,
                fontSize: 17,
                fontWeight: FontWeight.normal),
            // dialog button text
            bodyText2: TextStyle(
                color: CustomColors.sakuraLighter,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          buttonTheme: ButtonThemeData(buttonColor: CustomColors.sakuraLight),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40.0))),
                padding: MaterialStateProperty.all(EdgeInsets.all(20)),
                // take width of parent container
                minimumSize:
                    MaterialStateProperty.all(Size(double.infinity, 0)),
                overlayColor:
                    MaterialStateProperty.all(CustomColors.sakuraLighter)),
          ),
          scaffoldBackgroundColor: CustomColors.sakuraDark),
    );
  }
}
