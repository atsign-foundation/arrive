import 'package:atsign_location_app/common_components/custom_appbar.dart';
import 'package:atsign_location_app/common_components/custom_input_field.dart';
import 'package:atsign_location_app/common_components/person_tile/person_vertical_tile.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/images.dart';
import 'package:flutter/material.dart';
import 'package:atsign_location_app/services/size_config.dart';

class NewGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
            title: 'New Group', centerTitle: true, showBackIcon: true),
        body: Container(
          child: Column(
            children: <Widget>[
              SizedBox(height: 20.toHeight),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 15.toWidth,
                  ),
                  Container(
                    width: 68.toWidth,
                    height: 68.toWidth,
                    decoration: new BoxDecoration(
                      color: AllColors().MILD_GREY,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(Icons.add, color: AllColors().ORANGE),
                    ),
                  ),
                  SizedBox(width: 10.toWidth),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Group name'),
                        SizedBox(height: 5),
                        CustomInputField(
                          icon: Icons.emoji_emotions_outlined,
                          isIcon: true,
                          width: 240.toWidth,
                        ),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(height: 13.toHeight),
              Divider(),
              SizedBox(height: 13.toHeight),
              Container(
                height: SizeConfig().screenHeight - 290.toHeight,
                width: double.infinity,
                // color: Colors.red,
                child: SingleChildScrollView(
                  child: GridView.count(
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    crossAxisCount: 4,
                    crossAxisSpacing: 15.toWidth,
                    // mainAxisSpacing: 38.toHeight,
                    childAspectRatio: (85 / 120),
                    children: List.generate(20, (index) {
                      return CustomPersonVerticalTile(
                        imageLocation: AllImages().PERSON1,
                        title: 'Thomas',
                        subTitle: '@thomas',
                        icon: Icons.highlight_off,
                        isTopRight: true,
                      );
                    }),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
