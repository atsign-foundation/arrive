import 'package:atsign_location_app/common_components/custom_circle_avatar.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/images.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_location_app/services/size_config.dart';

class Message extends StatelessWidget {
  final bool send;
  final String text;
  Message({@required this.send, @required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 10.toHeight),
        child: send
            ? Row(
                children: [
                  SizedBox(
                    width: 60.toWidth,
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: AllColors().BLUE,
                      ),
                      child: Text(
                        text,
                        style: CustomTextStyles().darkGrey14,
                      ),
                    ),
                  ),
                  SizedBox(width: 30.toWidth),
                  CustomCircleAvatar(
                    image: AllImages().PERSON1,
                  ),
                ],
              )
            : Row(
                children: [
                  CustomCircleAvatar(
                    image: AllImages().PERSON2,
                  ),
                  SizedBox(width: 30.toWidth),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: AllColors().INPUT_GREY_BACKGROUND,
                      ),
                      child: Text(
                        text,
                        style: CustomTextStyles().darkGrey14,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 60.toWidth,
                  )
                ],
              ));
  }
}
