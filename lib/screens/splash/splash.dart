import 'package:atsign_location_app/common_components/custom_button.dart';
import 'package:atsign_location_app/routes/route_names.dart';
import 'package:atsign_location_app/routes/routes.dart';
import 'package:atsign_location_app/services/size_config.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Image.asset(
              "assets/images/splash_bg.png",
              fit: BoxFit.fill,
              height: SizeConfig().screenHeight,
              width: SizeConfig().screenWidth,
            ),
            Positioned(
              top: 330.toHeight,
              left: 16.toWidth,
              child: Text(
                'Stay connected!',
                style: CustomTextStyles().blackPlayfairDisplay38,
              ),
            ),
            Positioned(
              top: 381.toHeight,
              left: 15.toWidth,
              child: Text(
                'Wherever',
                style: CustomTextStyles().blackPlayfairDisplay38,
              ),
            ),
            Positioned(
              top: 428.toHeight,
              left: 15.toWidth,
              child: Text(
                'you go.',
                style: CustomTextStyles().blackPlayfairDisplay38,
              ),
            ),
            Positioned(
              top: 511.toHeight,
              left: 16.toWidth,
              child: Text(
                'Lorem ipsum dolor sit amet, consectetur',
                style: CustomTextStyles().darkGrey15,
              ),
            ),
            Positioned(
              top: 530.toHeight,
              left: 16.toWidth,
              child: Text(
                'adipiscing elit.',
                style: CustomTextStyles().darkGrey15,
              ),
            ),
            Positioned(
              bottom: 32.toHeight,
              left: 16.toWidth,
              child: Text(
                ' The @ Company Copyright 2020',
                style: CustomTextStyles().darkGrey13,
              ),
            ),
            Positioned(
                bottom: 130.toHeight,
                right: 36.toWidth,
                child: CustomButton(
                    height: 40.toHeight,
                    width: 120.toWidth,
                    radius: 100.toHeight,
                    child: Text(
                      'Explore',
                      style: CustomTextStyles().white15,
                    ),
                    onTap: () {
                      SetupRoutes.push(context, Routes.HOME);
                    },
                    bgColor: AllColors().Black)),
          ],
        ),
      ),
    );
  }
}
