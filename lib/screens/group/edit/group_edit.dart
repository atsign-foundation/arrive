import 'package:atsign_location_app/common_components/custom_appbar.dart';
import 'package:atsign_location_app/common_components/custom_input_field.dart';
import 'package:atsign_location_app/common_components/pop_button.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/images.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_location_app/services/size_config.dart';

class GroupEdit extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          leadingWidget: PopButton(
            label: 'Cancel',
            textStyle: CustomTextStyles().black16,
          ),
          action: PopButton(label: 'Done'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              AllImages().GROUP_PHOTO,
              height: 272.toHeight,
              width: double.infinity,
              fit: BoxFit.fitWidth,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 27.toWidth, vertical: 15.toHeight),
              child: InkWell(
                onTap: () => bottomSheet(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Edit group Picture',
                      style: CustomTextStyles().orange12,
                    ),
                    SizedBox(
                      width: 5.toWidth,
                    ),
                    Icon(
                      Icons.edit,
                      color: AllColors().ORANGE,
                      size: 20.toFont,
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 27.toWidth, vertical: 2.toHeight),
              child: Text(
                'Group Name',
                style: CustomTextStyles().darkGrey14,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 27.toWidth, vertical: 2.toHeight),
              child: CustomInputField(
                icon: Icons.emoji_emotions_outlined,
                width: double.infinity,
              ),
            )
          ],
        ),
      ),
    );
  }

  void bottomSheet(BuildContext context) {
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
            height: 119.toHeight,
            decoration: new BoxDecoration(
              color: AllColors().WHITE,
              borderRadius: new BorderRadius.only(
                topLeft: const Radius.circular(12.0),
                topRight: const Radius.circular(12.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Change Group Photo',
                    style: CustomTextStyles().darkGrey16,
                  ),
                  Divider(),
                  Text(
                    'Remove Group Photo',
                    style: CustomTextStyles().darkGrey16,
                  )
                ],
              ),
            ),
          );
        });
  }
}
