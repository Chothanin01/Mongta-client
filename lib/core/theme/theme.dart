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

  // near chart
  static const Color nearchartSoftPink = Color.fromARGB(255, 248, 219, 230);
  static const Color nearchartWhite = Color.fromARGB(255, 252, 252, 252);
  static const Color nearchartPink = Color.fromARGB(255, 245, 187, 209);
  static const Color nearchartRed = Color.fromARGB(255, 228, 77, 81);
  static const Color nearchartGrey = Color.fromARGB(255, 217, 217, 217);

  // chat
  static const Color chatDivider = Color.fromARGB(255, 179, 179, 179);
  static const Color chatInfo = Color.fromARGB(255, 240, 242, 245);
  static const Color chatGrey = Color.fromARGB(255, 158, 158, 158);
  static const Color chatGreen = Color.fromARGB(255, 142, 200, 52);
  static const Color chatPink = Color.fromARGB(255, 245, 187, 209);
  static const Color chatWhite = Color.fromARGB(255, 252, 252, 252);
  static const Color chatBlue = Color.fromARGB(255, 18, 53, 143);

  // button (* include gradient button *)
  static const Color buttonBackground = Color.fromRGBO(18, 53, 143, 1);

  static const buttonNearChartBackground = LinearGradient(
    colors: [
      Color(0xFF12358F),
      Color(0xFFF5BBD1)
    ],
    stops: [0.4, 1.0],
  );

  static const buttonScanBackground = LinearGradient(
    colors: [
      Color(0xFF12358F),
      Color(0xFF749DF5)
    ],
    stops: [0.4, 1.0],
  );

  static const Color buttonBorder = Color.fromRGBO(0, 0, 0, 1);

  // text
  static const Color mainText = Color.fromRGBO(0, 0, 0, 1);
  static const Color hyperlinkedText = Color.fromRGBO(18, 53, 143, 1);
  static const Color blueText = Color.fromRGBO(18, 53, 143, 1);
  static const Color buttonText = Color.fromRGBO(255, 255, 255, 1);
  static const Color placeholderText = Color.fromRGBO(179, 179, 179, 1);

  // text field
  static const Color textfieldBorder = Color.fromRGBO(179, 179, 179, 1);
  static const Color textfieldFocus = Color.fromRGBO(18, 53, 143, 1);
  static const Color textfieldBackground = Color.fromRGBO(255, 255, 255, 1);

  // misc
  static const Color white = Color.fromRGBO(255, 255, 255, 1);
  static const Color black = Color.fromRGBO(0, 0, 0, 1);
  static const Color grey = Color.fromRGBO(158, 158, 158, 1);
  static const Color logoBorder = Color.fromRGBO(217, 217, 217, 1);
  static const Color transparent = Color.fromRGBO(0, 0, 0, 0);
  // static const Color test = Colors.blue;
  // static const Color test2 = Colors.pink;

}