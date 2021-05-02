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
      title: 'Flutter Demo',
      home: Home(),
      theme: ThemeData(
        primarySwatch: CustomColors.sakuraLight,
      ),
    );
  }
}
