import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:musiquamiapp/utils/CustomColors.dart';
import 'package:musiquamiapp/widgets/home/Home.dart';

void main() {
  // "transparent" status bar
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  runApp(MusiquamiApp());
}

class MusiquamiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // app should only be displayed in portrait
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Musiquami',
      home: Home(),
      theme: ThemeData(
          fontFamily: 'Lato',
          primarySwatch: CustomColors.sakuraLight,
          backgroundColor: CustomColors.sakuraDark,
          appBarTheme: AppBarTheme(
              // android/ios status bar should be displayed using bright font color
              brightness: Brightness.dark,
              backgroundColor: CustomColors.sakuraDark,
              elevation: 0.0),
          accentColor: CustomColors.sakuraCream,
          disabledColor: CustomColors.sakuraDark2,
          // sliding up panel background color
          bottomAppBarColor: CustomColors.sakuraDark3,
          inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: CustomColors.sakuraDark2,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40.0))),
          textTheme: TextTheme(
            // top headline
            headline1: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
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
                color: CustomColors.sakuraLight2,
                fontSize: 20,
                fontWeight: FontWeight.w900),
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
                    MaterialStateProperty.all(CustomColors.sakuraLight2)),
          ),
          scaffoldBackgroundColor: CustomColors.sakuraDark),
    );
  }
}
