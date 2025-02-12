import 'package:flutter/material.dart';

// const color for background theme, navbar and others
class MainTheme {
  // Background
  static const Color mainBackground = Color.fromRGBO(252, 252, 252, 1);

  // navbar
  static const Color navbarBackground = Color.fromRGBO(252, 252, 252, 1);
  static const Color navbarBackground2 = Color.fromRGBO(235, 235, 235, 1);
  static const Color navbarText = Color.fromRGBO(179, 179, 179, 1);
  static const Color navbarFocusText = Color.fromRGBO(18, 53, 143, 1);

  // home page
  static const Color pinkBox = Color.fromRGBO(245, 187, 209, 1);
  static const Color blueBox = Color.fromRGBO(18, 53, 143, 1);

  // button (* include gradient button *)
  static const Color buttonBackground = Color.fromRGBO(18, 53, 143, 1);
  static const Color maleButtonBackground = Color.fromRGBO(116, 157, 245, 1);
  static const Color femaleButtonBackground = Color.fromRGBO(245, 187, 209, 1);

  static const buttonNearChartBackground = LinearGradient(
    colors: [
      Color.fromRGBO(18, 53, 143, 1),
      Color.fromRGBO(245, 187, 209, 1)
    ],
    stops: [0.4, 1.0],
  );

  static const buttonScanBackground = LinearGradient(
    colors: [
      Color.fromRGBO(18, 53, 143, 1),
      Color.fromRGBO(116, 157, 245, 1)
    ],
    stops: [0.4, 1.0],
  );

  static const Color buttonBorder = Color.fromRGBO(0, 0, 0, 1);

  // text
  static const Color mainText = Color.fromRGBO(0, 0, 0, 1);
  static const Color hyperlinkedText = Color.fromRGBO(18, 53, 143, 1);
  static const Color blueText = Color.fromRGBO(18, 53, 143, 1);
  static const Color redText = Color.fromRGBO(228, 77, 81, 1);
  static const Color buttonText = Color.fromRGBO(255, 255, 255, 1);
  static const Color placeholderText = Color.fromRGBO(179, 179, 179, 1);

  // text field
  static const Color textfieldBorder = Color.fromRGBO(179, 179, 179, 1);
  static const Color textfieldFocus = Color.fromRGBO(18, 53, 143, 1);
  static const Color textfieldBackground = Color.fromRGBO(255, 255, 255, 1);

  // progress bar (page indicator)
  static const Color activeDot = Color.fromRGBO(18, 53, 143, 1);
  static const Color inactiveDot = Color.fromRGBO(179, 179, 179, 1);
  
  // warning + error
  static const Color redWarning = Color.fromRGBO(244, 67, 54, 1);

  // misc
  static const Color white = Color.fromRGBO(255, 255, 255, 1);
  static const Color black = Color.fromRGBO(0, 0, 0, 1);
  static const Color grey = Color.fromRGBO(158, 158, 158, 1);
  static const Color logoBorder = Color.fromRGBO(217, 217, 217, 1);
  static const Color transparent = Color.fromRGBO(0, 0, 0, 0);
  // static const Color test = Colors.blue;
  // static const Color test2 = Colors.pink;

}