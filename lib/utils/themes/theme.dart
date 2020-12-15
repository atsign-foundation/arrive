import 'package:atsign_location_app/utils/constants/colors.dart';
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
      primaryColor: AllColors().Black,
      accentColor: AllColors().ORANGE,
      textTheme: TextTheme(
          headline1: TextStyle(
              color: AllColors().Black,
              fontSize: 18,
              fontWeight: FontWeight.w700),
          headline2: TextStyle(fontSize: 14, color: AllColors().Black),
          headline3: TextStyle(
              color: AllColors().ORANGE,
              fontSize: 18,
              fontWeight: FontWeight.w700),
          headline4: TextStyle(fontSize: 10, color: AllColors().DARK_GREY)),
      iconTheme: IconThemeData(color: AllColors().Black),
      appBarTheme: AppBarTheme(
          color: AllColors().WHITE,
          iconTheme: IconThemeData(color: AllColors().Black),
          textTheme: TextTheme(
              headline1: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AllColors().Black),
              headline2: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AllColors().WHITE))),
      scaffoldBackgroundColor: AllColors().WHITE,
      fontFamily: 'HelveticaNeu',
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: AllColors().WHITE,
      accentColor: AllColors().ORANGE,
      textTheme: TextTheme(
          headline1: TextStyle(
              color: AllColors().LIGHT_GREY,
              fontSize: 18,
              fontWeight: FontWeight.w700),
          headline2: TextStyle(fontSize: 14, color: AllColors().WHITE),
          headline3: TextStyle(
              color: AllColors().ORANGE,
              fontSize: 18,
              fontWeight: FontWeight.w700),
          headline4: TextStyle(fontSize: 10, color: AllColors().LIGHT_GREY)),
      iconTheme: IconThemeData(color: AllColors().WHITE),
      appBarTheme: AppBarTheme(
          color: AllColors().Black,
          iconTheme: IconThemeData(color: AllColors().WHITE),
          textTheme: TextTheme(
              headline1: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AllColors().WHITE),
              headline2: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AllColors().WHITE))),
      scaffoldBackgroundColor: AllColors().Black,
      fontFamily: 'HelveticaNeu',
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  static getThemeData(ThemeColor _themeColor) {
    if (_themeColor == ThemeColor.Dark)
      return Themes.darkTheme;
    else
      return Themes.lightTheme;
  }
}
