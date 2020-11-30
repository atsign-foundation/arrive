import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';

void bottomSheet(BuildContext context, T, double height) {
  showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          height: height,
          decoration: new BoxDecoration(
            color: AllColors().WHITE,
            borderRadius: new BorderRadius.only(
              topLeft: const Radius.circular(12.0),
              topRight: const Radius.circular(12.0),
            ),
          ),
          child: T,
        );
      });
}
