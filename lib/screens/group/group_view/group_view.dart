import 'package:atsign_location_app/common_components/tiles/person_vertical_tile.dart';
import 'package:atsign_location_app/routes/route_names.dart';
import 'package:atsign_location_app/routes/routes.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/images.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_location_app/services/size_config.dart';
import 'package:flutter/rendering.dart';

class GroupView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                children: [
                  Image.asset(
                    AllImages().GROUP_PHOTO,
                    height: 272.toHeight,
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                  SizedBox(
                    height: 60.toHeight,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 15.toWidth, vertical: 0.toHeight),
                    child: GridView.count(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: 4,
                      //crossAxisSpacing: 15.toWidth,
                      mainAxisSpacing: 10.toHeight,
                      childAspectRatio: (85 / 100),
                      children: List.generate(20, (index) {
                        return CustomPersonVerticalTile(
                          imageLocation: AllImages().PERSON1,
                          title: 'Thomas',
                          subTitle: '@thomas',
                        );
                      }),
                    ),
                  ),
                ],
              ),
              Positioned(
                  top: 240.toHeight,
                  child: Container(
                    height: 64,
                    width: 343.toWidth,
                    margin: EdgeInsets.symmetric(
                        horizontal: 15.toWidth, vertical: 0.toHeight),
                    padding: EdgeInsets.symmetric(
                        horizontal: 15.toWidth, vertical: 10.toHeight),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: AllColors().WHITE,
                      boxShadow: [
                        BoxShadow(
                          color: AllColors().DARK_GREY,
                          blurRadius: 10.0,
                          spreadRadius: 1.0,
                          offset: Offset(0.0, 0.0),
                        )
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '@Alexa Team',
                              style: CustomTextStyles().black14,
                            ),
                            // SizedBox(height: 5.toHeight),
                            Text(
                              '15 members',
                              style: CustomTextStyles().darkGrey10,
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () =>
                              SetupRoutes.push(context, Routes.GROUP_MEMBERS),
                          child: Icon(
                            Icons.add,
                            color: AllColors().Black,
                            size: 30.toFont,
                          ),
                        )
                      ],
                    ),
                  )),
              Positioned(
                  top: 30.toHeight,
                  left: 10.toWidth,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back,
                      color: AllColors().Black,
                    ),
                  )),
              Positioned(
                  top: 30.toHeight,
                  right: 10.toWidth,
                  child: InkWell(
                    onTap: () => SetupRoutes.push(context, Routes.GROUP_EDIT),
                    child: Icon(
                      Icons.edit,
                      color: AllColors().Black,
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
