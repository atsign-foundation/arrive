import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class Themes {
  Themes._();
  static final Themes _instance = Themes._();
  factory Themes() => _instance;
  // ignore: non_constant_identifier_names
  ThemeData PRIMARY_THEME = ThemeData(
    primaryColor: AllColors().Black,
    fontFamily: 'HelveticaNeu',
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
