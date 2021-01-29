import 'package:atsign_location/atsign_location.dart';
import 'package:atsign_location/atsign_location_plugin.dart';
import 'package:atsign_location_app/common_components/bottom_sheet/bottom_sheet.dart';
import 'package:atsign_location_app/common_components/display_tile.dart';
import 'package:atsign_location_app/common_components/draggable_symbol.dart';
import 'package:atsign_location_app/common_components/floating_icon.dart';
import 'package:atsign_location_app/common_components/participants.dart';
import 'package:atsign_location_app/dummy_data/latLng.dart';
import 'package:atsign_location_app/screens/chat_area/chat_area.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/images.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:atsign_common/services/size_config.dart';

class ShareLocationScreen extends StatelessWidget {
  int length;
  ShareLocationScreen({this.length});
  final PanelController pc = PanelController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Stack(
        children: [
          // AtsignLocationPlugin(
          //   (length == 2) ? getLatLng(length: 2) : getLatLng(),
          //   bottom: 215,
          // ),
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
              bgColor: Theme.of(context).primaryColor,
              icon: Icons.message_outlined,
              iconColor: AllColors().WHITE,
              onPressed: () => bottomSheet(context, ChatArea(), 743.toHeight),
            ),
          ),
          SlidingUpPanel(
            controller: pc,
            minHeight: 205,
            maxHeight: 431,
            collapsed: collapsedContent(false, context),
            panel: collapsedContent(true, context),
          )
        ],
      )),
    );
  }

  Widget collapsedContent(bool expanded, BuildContext context) {
    return Container(
        height: expanded ? 431 : 205,
        padding: EdgeInsets.fromLTRB(15, 3, 15, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
          color: Theme.of(context).scaffoldBackgroundColor,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tina\'s Birthday Party',
                    style: Theme.of(context).primaryTextTheme.headline1,
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
                height: 3,
              ),
              Text(
                'Event on 14 August 2020',
                style: CustomTextStyles().darkGrey14,
              ),
              SizedBox(
                height: 3,
              ),
              Text(
                '22:00 - 23:45',
                style: CustomTextStyles().darkGrey14,
              ),
              Divider(),
              DisplayTile(
                  title: 'Levina Thomas and 9 more',
                  semiTitle: '10 people',
                  subTitle: 'Share my location from 21:00 today',
                  action: Transform.rotate(
                    angle: 5.8,
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
                  )),
              Padding(
                padding: EdgeInsets.only(left: 56.toWidth),
                child: InkWell(
                  onTap: () => bottomSheet(context, Participants(), 422),
                  child: Text(
                    'See Participants',
                    style: CustomTextStyles().orange14,
                  ),
                ),
              ),
              expanded
                  ? Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Divider(),
                          Text(
                            'Address',
                            style: CustomTextStyles().darkGrey14,
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Flexible(
                            child: Text(
                              '194, White Pane Lane, Troutile, Virginia, 24175',
                              style: CustomTextStyles().darkGrey14,
                            ),
                          ),
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
                            child: InkWell(
                              onTap: () => Navigator.pop(context),
                              child: Text(
                                'Exit Event',
                                style: CustomTextStyles().orange16,
                              ),
                            ),
                          ),
                          Divider(),
                          Expanded(
                            child: InkWell(
                              onTap: () => Navigator.pop(context),
                              child: Text(
                                'Cancel Event',
                                style: CustomTextStyles().orange16,
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  : SizedBox(
                      height: 2,
                    )
            ]));
  }
}
