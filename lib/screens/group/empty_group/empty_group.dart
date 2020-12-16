import 'package:atsign_location_app/common_components/custom_button.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/images.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_location_app/services/size_config.dart';

class EmptyGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            AllImages().EMPTY_GROUP,
            width: 181.toWidth,
            height: 181.toWidth,
            fit: BoxFit.cover,
          ),
          SizedBox(
            height: 15.toHeight,
          ),
          Text(
            'No Groups!',
            style: CustomTextStyles().black18,
          ),
          SizedBox(
            height: 5.toHeight,
          ),
          Text(
            'Would you like to create a group ',
            style: CustomTextStyles().grey14,
          ),
          SizedBox(
            height: 20.toHeight,
          ),
          CustomButton(
              height: 40.toHeight,
              width: 120.toWidth,
              radius: 100.toHeight,
              child: Text(
                'Create',
                style:
                    TextStyle(color: Theme.of(context).scaffoldBackgroundColor),
              ),
              onTap: null,
              bgColor: Theme.of(context).primaryColor)
        ],
      ),
    );
  }
}
