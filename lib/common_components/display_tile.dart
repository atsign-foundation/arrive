import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_location_app/services/size_config.dart';

class DisplayTile extends StatelessWidget {
  final String title, semiTitle, subTitle, image;
  final int number;
  DisplayTile(
      {@required this.title,
      @required this.image,
      @required this.subTitle,
      this.semiTitle,
      this.number});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 10.5.toHeight),
      // height: semiTitle == null
      //     ? 56.toHeight
      //     : 56.toHeight, //semiTitle == null ? 46.toHeight // was cropping the circle
      child: Row(
        children: [
          Stack(
            children: [
              Image.asset(
                image,
                width: 46,
                height: 46,
                fit: BoxFit.cover,
              ),
              number != null
                  ? Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        alignment: Alignment.center,
                        height: 28,
                        width: 28,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            color: AllColors().BLUE),
                        child: Text(
                          '+$number',
                          style: CustomTextStyles().black10,
                        ),
                      ),
                    )
                  : Container(
                      height: 0,
                      width: 0,
                    ),
            ],
          ),
          Flexible(
              child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: CustomTextStyles().darkGrey14,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                semiTitle != null
                    ? Text(
                        semiTitle,
                        style: CustomTextStyles().orange12,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : SizedBox(),
                Text(
                  subTitle,
                  style: CustomTextStyles().darkGrey12,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
