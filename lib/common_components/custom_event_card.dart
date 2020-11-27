import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/images.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_location_app/services/size_config.dart';

class CustomEventCard extends StatelessWidget {
  final Text eventAndGroupName,
      invitedByLabel,
      shareLocationDurationLable,
      eventDate;

  CustomEventCard({
    this.eventAndGroupName = const Text(''),
    this.invitedByLabel = const Text(''),
    this.shareLocationDurationLable = const Text(''),
    this.eventDate = const Text(''),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 70,
            width: 100,
            decoration: new BoxDecoration(
              shape: BoxShape.circle,
              image: new DecorationImage(
                fit: BoxFit.cover,
                image: new AssetImage(AllImages().PERSON2),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 60,
                  top: 40,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: new BoxDecoration(
                      color: AllColors().EVENT_MEMBERS,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '+10',
                        style: CustomTextStyles().black10,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  eventAndGroupName,
                  SizedBox(height: 6.toHeight),
                  shareLocationDurationLable,
                  SizedBox(height: 6.toHeight),
                  eventDate,
                  SizedBox(height: 10.toHeight),
                  invitedByLabel,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
