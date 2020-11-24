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
}
