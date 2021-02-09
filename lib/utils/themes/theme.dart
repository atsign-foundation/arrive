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
      brightness: Brightness.light,
      primaryColor: AllColors().Black,
      accentColor: AllColors().ORANGE,
      hintColor: AllColors().DARK_GREY,
      textTheme: TextTheme(
        subtitle1: TextStyle(color: AllColors().DARK_GREY, fontSize: 12),
        subtitle2: TextStyle(color: AllColors().DARK_GREY, fontSize: 10),
        bodyText1: TextStyle(color: AllColors().DARK_GREY, fontSize: 16),
        bodyText2: TextStyle(color: AllColors().DARK_GREY, fontSize: 14),
        headline1: TextStyle(
            color: AllColors().Black,
            fontSize: 18,
            fontWeight: FontWeight.w700),
        headline2: TextStyle(
            color: AllColors().ORANGE,
            fontSize: 18,
            fontWeight: FontWeight.w700),
        headline3: TextStyle(color: AllColors().GREY, fontSize: 16),
        headline4: TextStyle(color: AllColors().GREY, fontSize: 14),
        headline5: TextStyle(color: AllColors().GREY, fontSize: 12),
      ),
      primaryTextTheme: TextTheme(
        headline1: TextStyle(
            color: AllColors().Black,
            fontSize: 18,
            fontWeight: FontWeight.w700),
        headline2: TextStyle(color: AllColors().Black, fontSize: 16),
        headline3: TextStyle(color: AllColors().Black, fontSize: 14),
        headline4: TextStyle(color: AllColors().Black, fontSize: 12),
        headline5: TextStyle(color: AllColors().Black, fontSize: 10),
      ),
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
      brightness: Brightness.dark,
      primaryColor: AllColors().WHITE,
      accentColor: AllColors().ORANGE,
      hintColor: AllColors().DARK_GREY,
      textTheme: TextTheme(
        subtitle1: TextStyle(color: AllColors().DARK_GREY, fontSize: 12),
        subtitle2: TextStyle(color: AllColors().DARK_GREY, fontSize: 10),
        bodyText1: TextStyle(color: AllColors().DARK_GREY, fontSize: 16),
        bodyText2: TextStyle(color: AllColors().DARK_GREY, fontSize: 14),
        headline1: TextStyle(
            color: AllColors().LIGHT_GREY,
            fontSize: 18,
            fontWeight: FontWeight.w700),
        headline2: TextStyle(
            color: AllColors().ORANGE,
            fontSize: 18,
            fontWeight: FontWeight.w700),
        headline3: TextStyle(color: AllColors().GREY, fontSize: 16),
        headline4: TextStyle(color: AllColors().GREY, fontSize: 14),
        headline5: TextStyle(color: AllColors().GREY, fontSize: 12),
      ),
      primaryTextTheme: TextTheme(
        headline1: TextStyle(
            color: AllColors().WHITE,
            fontSize: 18,
            fontWeight: FontWeight.w700),
        headline2: TextStyle(color: AllColors().WHITE, fontSize: 16),
        headline3: TextStyle(color: AllColors().WHITE, fontSize: 14),
        headline4: TextStyle(color: AllColors().WHITE, fontSize: 12),
        headline5: TextStyle(color: AllColors().WHITE, fontSize: 10),
      ),
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
