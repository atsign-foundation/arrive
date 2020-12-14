import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/fonts/fonts.dart';
import 'package:atsign_location_app/view_models/theme_view_model.dart';
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

  static ThemeData get lightTheme {
    return ThemeData(
      appBarTheme: AppBarTheme(
        color: AllColors().WHITE,
        elevation: 0,
      ),
      primaryColor: AllColors().WHITE,
      accentColor: AllColors().ORANGE,
      scaffoldBackgroundColor: Colors.white,
      fontFamily: Fonts.defaultFont,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      appBarTheme: AppBarTheme(
        color: AllColors().Black,
        elevation: 0,
        iconTheme: IconThemeData(color: AllColors().WHITE),
      ),
      primaryColor: AllColors().Black,
      accentColor: AllColors().ORANGE,
      scaffoldBackgroundColor: AllColors().Black,
      fontFamily: Fonts.defaultFont,
    );
  }

  static getThemeData(ThemeColor _themeColor) {
    if (_themeColor == ThemeColor.Dark)
      return Themes.darkTheme;
    else if (_themeColor == ThemeColor.Light)
      return Themes.lightTheme;
    else
      return Themes.lightTheme;
  }
}
