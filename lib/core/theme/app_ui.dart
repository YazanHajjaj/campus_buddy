import 'package:flutter/material.dart';

class AppUI {
  static const primary = Color(0xFF2446C8);
  static const background = Color(0xFFF3F4F6);

  static BorderRadius cardRadius = BorderRadius.circular(18);
  static BorderRadius buttonRadius = BorderRadius.circular(14);

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.06),
      blurRadius: 18,
      offset: Offset(0, 8),
    ),
  ];
}