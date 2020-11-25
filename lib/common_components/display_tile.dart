import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:atsign_location_app/services/size_config.dart';

class DisplayTile extends StatelessWidget {
  final String title;
  final String subTitle;
  final int number;
  DisplayTile({@required this.title, @required this.subTitle, this.number});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.all(0),
      leading: Stack(
        children: [
          Container(
            height: 55.toHeight,
            width: 50.toWidth,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(27.toHeight),
                color: number != null
                    ? AllColors().DARK_GREY
                    : AllColors().LIGHT_GREY),
          ),
          number != null
              ? Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    alignment: Alignment.center,
                    height: 30.toHeight,
                    width: 30.toWidth,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: AllColors().LIGHT_GREY),
                    child: Text('+$number'),
                  ),
                )
              : Container(
                  height: 0,
                  width: 0,
                ),
        ],
      ),
      title: Text(
        title,
        style: TextStyle(color: AllColors().DARK_GREY, fontSize: 16.toFont),
      ),
      subtitle: Text(
        subTitle,
        style: TextStyle(color: AllColors().GREY, fontSize: 14.toFont),
      ),
    );
  }
}
