import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:atsign_location_app/services/size_config.dart';

class CustomTextStyles {
  CustomTextStyles._();
  static CustomTextStyles _instance = CustomTextStyles._();
  factory CustomTextStyles() => _instance;

  TextStyle blackPlayfairDisplay38 = TextStyle(
      fontFamily: 'PlayfairDisplay',
      fontSize: 38.toHeight,
      color: AllColors().Black);

  TextStyle greyLabel14 = TextStyle(
    color: AllColors().GREY_LABEL,
    fontSize: 14.toFont,
  );

  TextStyle black16 = TextStyle(
    color: AllColors().Black,
    fontSize: 16.toFont,
  );

  TextStyle white15 = TextStyle(
    color: AllColors().WHITE,
    fontSize: 15.toFont,
  );

  TextStyle orange16 = TextStyle(
    color: AllColors().ORANGE,
    fontSize: 16.toFont,
  );

  TextStyle orange12 = TextStyle(
    color: AllColors().ORANGE,
    fontSize: 12.toFont,
  );

  TextStyle darkGrey15 = TextStyle(
    color: AllColors().DARK_GREY,
    fontSize: 15.toFont,
  );

  TextStyle darkGrey13 = TextStyle(
    color: AllColors().DARK_GREY,
    fontSize: 13.toFont,
  );

  TextStyle darkGrey14 =
      TextStyle(color: AllColors().DARK_GREY, fontSize: 14.toFont);

  TextStyle darkGrey16 =
      TextStyle(color: AllColors().DARK_GREY, fontSize: 16.toFont);

  TextStyle darkGrey12 =
      TextStyle(color: AllColors().DARK_GREY, fontSize: 12.toFont);

  TextStyle grey14 = TextStyle(color: AllColors().GREY, fontSize: 14.toFont);
}
