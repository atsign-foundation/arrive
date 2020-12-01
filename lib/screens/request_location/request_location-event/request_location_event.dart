import 'package:atsign_location_app/common_components/bottom_sheet/bottom_sheet.dart';
import 'package:atsign_location_app/common_components/display_tile.dart';
import 'package:atsign_location_app/common_components/draggable_symbol.dart';
import 'package:atsign_location_app/common_components/floating_icon.dart';
import 'package:atsign_location_app/common_components/pop_button.dart';
import 'package:atsign_location_app/screens/chat_area/chat_area.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/images.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:atsign_location_app/utils/constants/texts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:latlng/latlng.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:map/map.dart';
import 'package:atsign_location_app/services/size_config.dart';

class RequestLocationEvent extends StatelessWidget {
  final PanelController pc = PanelController();
  final controller = MapController(
    location: LatLng(35.68, 51.41),
  );
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
          Positioned(
            top: 0,
            left: 0,
            child: FloatingIcon(
              bgColor: AllColors().WHITE,
              icon: Icons.arrow_back,
              iconColor: AllColors().Black,
              isTopLeft: true,
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: FloatingIcon(
              bgColor: AllColors().Black,
              icon: Icons.message_outlined,
              iconColor: AllColors().WHITE,
              onPressed: () => bottomSheet(context, ChatArea(), 743.toHeight),
            ),
          ),
          SlidingUpPanel(
            //color: Colors.transparent,
            controller: pc,
            minHeight: 119,
            maxHeight: 291,
            collapsed: collapsedContent(false, context),
            panel: collapsedContent(true, context),
          )
        ],
      )),
    );
  }

  Widget collapsedContent(bool expanded, BuildContext context) {
    return Container(
        height: expanded ? 291 : 119,
        width: SizeConfig().screenWidth,
        padding: EdgeInsets.fromLTRB(15, 3, 15, 0),
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              DraggableSymbol(),
              SizedBox(
                height: 3,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DisplayTile(
                            title: 'Levina Thomas',
                            image: AllImages().PERSON2,
                            subTitle: '@sign'),
                        Text(
                          'This user does not share his location',
                          style: CustomTextStyles().grey12,
                        ),
                        Text(
                          'Sharing my location until 20:35 today',
                          style: CustomTextStyles().black12,
                        )
                      ],
                    ),
                  ),
                  Transform.rotate(
                    angle: 5.8,
                    child: InkWell(
                      onTap: () => bottomSheet(
                          context,
                          Container(
                            height: 157.toHeight,
                            padding: EdgeInsets.fromLTRB(15.toWidth, 5.toHeight,
                                15.toWidth, 20.toHeight),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                        child: Text(
                                      'Choose an application to navigate to the venue',
                                      style: CustomTextStyles().grey14,
                                    )),
                                    SizedBox(
                                      width: 10.toWidth,
                                    ),
                                    PopButton(label: 'Close')
                                  ],
                                ),
                                SizedBox(
                                  height: 10.toWidth,
                                ),
                                Expanded(
                                  child: Text(
                                    'Google Map',
                                    style: CustomTextStyles().darkGrey16,
                                  ),
                                ),
                                Divider(),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => Navigator.pop(context),
                                    child: Text(
                                      'Apple Map',
                                      style: CustomTextStyles().darkGrey16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          157),
                      child: Container(
                        alignment: Alignment.center,
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: AllColors().ORANGE,
                        ),
                        child: Icon(
                          Icons.send_outlined,
                          color: AllColors().WHITE,
                          size: 25.toFont,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              expanded
                  ? Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Share Location',
                                style: CustomTextStyles().darkGrey16,
                              ),
                              Switch(
                                  value: true,
                                  onChanged: (value) => print('value'))
                            ],
                          ),
                          Divider(),
                          Expanded(
                            child: Text(
                              'Request Location',
                              style: CustomTextStyles().darkGrey16,
                            ),
                          ),
                          Divider(),
                          Expanded(
                            child: InkWell(
                              onTap: () => Navigator.pop(context),
                              child: Text(
                                'Remove Person',
                                style: CustomTextStyles().orange16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : SizedBox(
                      height: 2,
                    )
            ]));
  }
}
