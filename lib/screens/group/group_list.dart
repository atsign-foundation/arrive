import 'package:atsign_location_app/common_components/custom_appbar.dart';
import 'package:atsign_location_app/common_components/person_tile/person_horizontal_tile.dart';
import 'package:atsign_location_app/screens/group/empty_group/empty_group.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/images.dart';
import 'package:flutter/material.dart';
import 'package:atsign_location_app/services/size_config.dart';

class GroupList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          showBackIcon: true,
          centerTitle: true,
          title: 'Groups',
          action: Icon(
            Icons.add,
            color: AllColors().ORANGE,
          ),
        ),
        //body: EmptyGroup(),
        body: GridView.count(
          childAspectRatio: 150.toWidth / 60.toHeight, // width/height
          primary: false,
          padding: const EdgeInsets.all(20.0),
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 20.toHeight,
          crossAxisCount: 2,
          children: List.generate(14, (index) {
            return CustomPersonHorizontalTile(
              imageLocation: AllImages().PERSON1,
              title: 'Alexa Team',
              subTitle: '7 members',
            );
          }),
        ),
      ),
    );
  }
}
