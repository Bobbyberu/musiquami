import 'dart:ui';

import 'package:flutter/material.dart';

class BlurredLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: FractionalOffset.bottomCenter,
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Image.asset(
            'assets/images/logo_transparent.png',
            fit: BoxFit.contain,
          ),
        ));
  }
}
