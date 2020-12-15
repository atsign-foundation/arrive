import 'package:atsign_events/screens/create_event.dart';
import 'package:atsign_location_app/common_components/bottom_sheet/bottom_sheet.dart';
import 'package:atsign_location_app/common_components/display_tile.dart';
import 'package:atsign_location_app/common_components/draggable_symbol.dart';
import 'package:atsign_location_app/common_components/floating_icon.dart';
import 'package:atsign_location_app/common_components/tasks.dart';
import 'package:atsign_location_app/dummy_data/group_data.dart';
import 'package:atsign_location_app/screens/request_location/request_location_sheet.dart';
import 'package:atsign_location_app/screens/share_location/share_location_sheet.dart';
import 'package:atsign_location_app/screens/sidebar/sidebar.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:atsign_location_app/utils/constants/texts.dart';
import 'package:flutter/material.dart';
import 'package:atsign_location_app/services/size_config.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:map/map.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:latlng/latlng.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PanelController pc = PanelController();
  final controller = MapController(
    location: LatLng(35.68, 51.41),
  );
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          endDrawer: Container(
            width: 250.toWidth,
            child: SideBar(),
          ),
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
                right: 0,
                child: FloatingIcon(
                    bgColor: AllColors().Black,
                    icon: Icons.table_rows,
                    iconColor: AllColors().WHITE),
              ),
              Positioned(bottom: 264.toHeight, child: header()),
              SlidingUpPanel(
                controller: pc,
                minHeight: 267.toHeight,
                maxHeight: 530.toHeight,
                collapsed: collapsedContent(2),
                panel: collapsedContent(GroupData().group.length),
              )
            ],
          )),
    );
  }

  Widget collapsedContent(int length) {
    return Container(
        height: length == 2 ? 260.toHeight : 530.toHeight,
        padding: EdgeInsets.fromLTRB(15.toWidth, 7.toHeight, 0, 0),
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
        child: SingleChildScrollView(
          physics: length == 2
              ? NeverScrollableScrollPhysics()
              : AlwaysScrollableScrollPhysics(),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DraggableSymbol(),
                SizedBox(
                  height: 5.toHeight,
                ),
                DisplayTile(
                  image: GroupData().group[0].image,
                  title: 'Event @ Group Name',
                  semiTitle: 'Action required',
                  subTitle: 'Sharing my location until 20:00',
                  number: 10,
                ),
                Divider(),
                ListView.separated(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return DisplayTile(
                      image: GroupData().group[index].image,
                      title: GroupData().group[index].username,
                      subTitle: GroupData().group[index].canSeeLocation
                          ? 'Can see my location'
                          : 'Sharing my location until ${GroupData().group[index].sharingUntil}',
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider();
                  },
                ),
                length == 2
                    ? Container(
                        //height: 16.toHeight,
                        alignment: Alignment.topCenter,
                        width: SizeConfig().screenWidth,
                        padding: EdgeInsets.fromLTRB(
                            56.toHeight, 0.toHeight, 0.toWidth, 0.toHeight),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                        child: InkWell(
                          onTap: () => pc.open(),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'See 9 more ',
                                style: CustomTextStyles().darkGrey14,
                              ),
                              Icon(Icons.keyboard_arrow_down)
                            ],
                          ),
                        ))
                    : SizedBox()
              ]),
        ));
  }

  Widget header() {
    return Container(
      height: 77.toHeight,
      width: 356.toWidth,
      margin:
          EdgeInsets.symmetric(horizontal: 10.toWidth, vertical: 10.toHeight),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Tasks(
              task: 'Create Event',
              icon: Icons.event,
              onTap: () => bottomSheet(
                  context, CreateEvent(), SizeConfig().screenHeight * 0.9)),
          Tasks(
              task: 'Request Location',
              icon: Icons.refresh,
              onTap: () => bottomSheet(context, RequestLocationSheet(),
                  SizeConfig().screenHeight * 0.5)),
          Tasks(
              task: 'Share Location',
              icon: Icons.person_add,
              onTap: () => bottomSheet(context, ShareLocationSheet(),
                  SizeConfig().screenHeight * 0.6))
        ],
      ),
    );
  }
}
