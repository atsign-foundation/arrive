import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:atsign_location_app/services/size_config.dart';

class ShowDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.toHeight,
      width: 50.toHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10.0),
        ),
        color: AllColors().Black,
        boxShadow: [
          BoxShadow(
            color: AllColors().GREY,
            blurRadius: 2.0,
            spreadRadius: 2.0,
            offset: Offset(0.0, 0.0),
          )
        ],
      ),
      child: IconButton(
          padding: EdgeInsets.all(10.toHeight),
          //iconSize: 20.toHeight,
          icon: Icon(
            Icons.table_rows,
            color: AllColors().WHITE,
            size: 27.toFont,
          ),
          onPressed: () {
            Scaffold.of(context).openEndDrawer();
          }),
    );
  }
}
