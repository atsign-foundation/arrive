import 'package:atsign_location_app/common_components/custom_appbar.dart';
import 'package:atsign_location_app/common_components/display_tile.dart';
import 'package:atsign_location_app/common_components/draggable_symbol.dart';
import 'package:atsign_location_app/common_components/pop_button.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/images.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';

class Participants extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 422.toHeight,
      padding:
          EdgeInsets.fromLTRB(15.toWidth, 5.toHeight, 15.toWidth, 10.toHeight),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DraggableSymbol(),
            CustomAppBar(
              title: 'Participants',
              action: PopButton(label: 'Close'),
            ),
            SizedBox(
              height: 10.toHeight,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 46.toWidth,
                  height: 46.toWidth,
                  decoration: new BoxDecoration(
                    color: AllColors().MILD_GREY,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(Icons.add, color: AllColors().ORANGE),
                  ),
                ),
                SizedBox(width: 20.toWidth),
                Text('Add Participant', style: CustomTextStyles().darkGrey16)
              ],
            ),
            SizedBox(
              height: 10.toHeight,
            ),
            ListView.separated(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: 5,
              itemBuilder: (BuildContext context, int index) {
                return DisplayTile(
                  title: 'user name',
                  subTitle: '@sign',
                  action: Text(
                    'At the location',
                    style: CustomTextStyles().darkGrey14,
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return Divider();
              },
            )
          ],
        ),
      ),
    );
  }
}
