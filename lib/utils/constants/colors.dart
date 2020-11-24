import 'package:flutter/material.dart';

class AllColors {
  AllColors._();
  static AllColors _instance = AllColors._();
  factory AllColors() => _instance;

  // ignore: non_constant_identifier_names
  Color WHITE = Color(0xFFFFFFFF);
  // ignore: non_constant_identifier_names
  Color LIGHT_GREY = Color(0xFFECECF0);
  // ignore: non_constant_identifier_names
  Color DARK_GREY = Color(0xFF868A92);
  // ignore: non_constant_identifier_names
  Color ORANGE = Color(0xFFE0732F);
  // ignore: non_constant_identifier_names
  Color PURPLE = Color(0xFFD9D9FF);
  // ignore: non_constant_identifier_names
  Color LIGHT_BLUE = Color(0xFFCFFFFF);
  // ignore: non_constant_identifier_names
  Color LIGHT_PINK = Color(0xFFFED2CF);
  // ignore: non_constant_identifier_names
  Color GREY = Colors.grey[400]; // Change it to Hex Later
}
