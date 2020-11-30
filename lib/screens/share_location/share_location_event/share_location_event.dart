import 'package:atsign_location_app/common_components/display_tile.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:atsign_location_app/utils/constants/texts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:latlng/latlng.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:map/map.dart';
import 'package:atsign_location_app/services/size_config.dart';

class ShareLocationEvent extends StatelessWidget {
  final PanelController pc = PanelController();
  final controller = MapController(
    location: LatLng(35.68, 51.41),
  );
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          endDrawer: Container(),
          body: Stack(
            children: [
              Map(
                controller: controller,
                builder: (context, x, y, z) {
                  return CachedNetworkImage(
                    imageUrl: AllText().URL(x, y, z),
                    fit: BoxFit.cover,
                  );
                },
              ),
              // Positioned(top: 0, right: 0, child: ShowDrawer()),
              // SlidingUpPanel(
              //   //color: Colors.transparent,
              //   controller: pc,
              //   minHeight: 220.toHeight,
              //   maxHeight: 431.toHeight,
              //   collapsed: Container(
              //     color: AllColors().WHITE,
              //     child: collapsedContent(),
              //   ),
              //   panel: collapsedContent(),
              // )
            ],
          )),
    );
  }

  Widget collapsedContent() {
    return Container(
        height: 200.toHeight,
        padding: EdgeInsets.fromLTRB(15.toWidth, 7.toHeight, 15.toWidth, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
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
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 6.toHeight,
                width: SizeConfig().screenWidth,
                alignment: Alignment.center,
                child: Container(
                    width: 60.toWidth,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7.toHeight),
                      color: AllColors().DARK_GREY,
                    )),
              ),
              SizedBox(
                height: 5.toHeight,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tina\'s Birthday Party',
                    style: CustomTextStyles().black18,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('Edit', style: CustomTextStyles().orange16),
                      Icon(Icons.edit, color: AllColors().ORANGE)
                    ],
                  )
                ],
              ),
              Text(
                '@ label',
                style: CustomTextStyles().black14,
              ),
              SizedBox(
                height: 5.toHeight,
              ),
              Text(
                'Event on 14 August 2020',
                style: CustomTextStyles().darkGrey14,
              ),
              SizedBox(
                height: 5.toHeight,
              ),
              Text(
                '22:00 - 23:45',
                style: CustomTextStyles().darkGrey14,
              ),
              Divider(),
              DisplayTile(
                title: 'Levina Thomas and 9 more',
                image: null,
                subTitle: '10 people',
                semiTitle: 'Share my location from 21:00 today',
              )
            ]));
  }
}
