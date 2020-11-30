import 'package:atsign_location_app/common_components/custom_appbar.dart';
import 'package:atsign_location_app/common_components/custom_button.dart';
import 'package:atsign_location_app/common_components/custom_circle_avatar.dart';
import 'package:atsign_location_app/common_components/person_tile/person_vertical_tile.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/images.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_location_app/services/size_config.dart';

class GroupMembers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Trusted Senders',
          centerTitle: true,
          showBackIcon: true,
          action: Icon(
            Icons.add,
            color: AllColors().Black,
            size: 28.toFont,
          ),
        ),
        body: Padding(
          padding: EdgeInsets.fromLTRB(
              15.toWidth, 20.toHeight, 15.toWidth, 2.toHeight),
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 4,
            mainAxisSpacing: 10.toHeight,
            childAspectRatio: (85 / 120),
            children: List.generate(20, (index) {
              return InkWell(
                onTap: () => showMyDialog(context),
                child: CustomPersonVerticalTile(
                  imageLocation: AllImages().PERSON1,
                  title: 'Thomas',
                  subTitle: '@thomas',
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Future<void> showMyDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Are you sure you want to remove from the group?',
                style: CustomTextStyles().darkGrey14,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15.toHeight),
              CustomCircleAvatar(
                image: AllImages().PERSON2,
                size: 74,
              ),
              SizedBox(height: 15.toHeight),
              Text(
                'Levina Thomas',
                style: CustomTextStyles().black14,
              ),
              Text(
                '@levinat',
                style: CustomTextStyles().darkGrey10,
              ),
              SizedBox(height: 20.toHeight),
              CustomButton(
                  height: 60,
                  width: double.infinity,
                  radius: 100.toHeight,
                  child: Text(
                    'Yes',
                    style: CustomTextStyles().white15,
                  ),
                  onTap: null,
                  bgColor: AllColors().Black),
              SizedBox(height: 5.toHeight),
              InkWell(
                onTap: null,
                child: Text(
                  'No',
                  style: CustomTextStyles().black14,
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
