import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:atsign_location_app/services/size_config.dart';

class DraggableSymbol extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4.toHeight,
      width: SizeConfig().screenWidth,
      alignment: Alignment.center,
      child: Container(
          width: 60.toWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7.toHeight),
            color: AllColors().DARK_GREY,
          )),
    );
  }
}
