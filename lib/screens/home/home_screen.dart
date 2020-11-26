import 'package:atsign_location_app/common_components/display_tile.dart';
import 'package:atsign_location_app/common_components/show_drawer.dart';
import 'package:atsign_location_app/common_components/tasks.dart';
import 'package:atsign_location_app/dummy_data/group_data.dart';
import 'package:atsign_location_app/screens/create_event/create_event.dart';
import 'package:atsign_location_app/screens/request_location/request_location.dart';
import 'package:atsign_location_app/screens/share_location/share_location.dart';
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
  ScrollController _scrollController = new ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );
  PanelController pc = PanelController();
  final controller = MapController(
    location: LatLng(35.68, 51.41),
  );
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return SafeArea(
      child: Scaffold(
          endDrawer: Container(
            width: 220.toWidth,
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
              Positioned(top: 0, right: 0, child: ShowDrawer()),
              Positioned(bottom: 280.toHeight, child: header()),
              SlidingUpPanel(
                color: Colors.transparent,
                controller: pc,
                minHeight: 267.toHeight,
                maxHeight: 530.toHeight,
                collapsed: Container(
                  height: 267.toHeight,
                  //padding: EdgeInsets.only(bottom: 2.toHeight),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        collapsedContent(2),
                      ]),
                ),
                panel: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 0),
                  child: Column(
                    children: [
                      collapsedContent(GroupData().group.length),
                    ],
                  ),
                ),
              )
            ],
          )),
    );
  }

  Widget collapsedContent(int length) {
    return Column(
      children: [
        Container(
            padding: EdgeInsets.fromLTRB(15.toWidth, 7.toHeight, 0, 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0)),
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
            child: Container(
              height: length == 2 ? 245.toHeight : 530.toHeight,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 0),
                controller: _scrollController,
                physics: length == 2
                    ? NeverScrollableScrollPhysics()
                    : AlwaysScrollableScrollPhysics(),
                child: Column(
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
                      Text(
                        'Locations',
                        style: CustomTextStyles().darkGrey14,
                      ),
                      DisplayTile(
                        image: GroupData().group[0].image,
                        title: 'Event @ Group Name',
                        semiTitle: 'Action required',
                        subTitle: 'Sharing my location until 20:00',
                        number: 10,
                      ),
                      Divider(),
                      ListView.builder(
                          padding: EdgeInsets.only(bottom: 0),
                          // primary: false,
                          //controller: myscrollController,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: length,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            return Column(
                              children: [
                                DisplayTile(
                                  image: GroupData().group[index].image,
                                  title: GroupData().group[index].username,
                                  subTitle: GroupData()
                                          .group[index]
                                          .canSeeLocation
                                      ? 'Can see my location'
                                      : 'Sharing my location until ${GroupData().group[index].sharingUntil}',
                                ),
                                Divider(),
                              ],
                            );
                          }),
                      length == 2
                          ? Container(
                              height: 16.toHeight,
                              width: SizeConfig().screenWidth,
                              padding: EdgeInsets.fromLTRB(60.toWidth,
                                  0.toHeight, 0.toWidth, 0.toHeight),
                              decoration: BoxDecoration(
                                color: AllColors().WHITE,
                              ),
                              child: InkWell(
                                onTap: () {
                                  pc.open();
                                },
                                child: Row(
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
              ),
            )),
      ],
    );
  }

  Widget header() {
    return Container(
      width: SizeConfig().screenWidth - 30.toWidth,
      margin:
          EdgeInsets.symmetric(horizontal: 15.toWidth, vertical: 10.toHeight),
      padding:
          EdgeInsets.symmetric(horizontal: 10.toWidth, vertical: 10.toHeight),
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InkWell(
            onTap: () {
              homeBottomSheet(
                  context, CreateEvent(), SizeConfig().screenHeight * 0.9);
            },
            child: Tasks(task: 'Create Event', color: AllColors().PURPLE),
          ),
          InkWell(
            onTap: () {
              homeBottomSheet(
                  context, RequestLocation(), SizeConfig().screenHeight * 0.5);
            },
            child:
                Tasks(task: 'Request Location', color: AllColors().LIGHT_BLUE),
          ),
          InkWell(
            onTap: () {
              homeBottomSheet(
                  context, ShareLocation(), SizeConfig().screenHeight * 0.6);
            },
            child: Tasks(task: 'Share Location', color: AllColors().LIGHT_PINK),
          )
        ],
      ),
    );
  }
}

void homeBottomSheet(BuildContext context, T, double height) {
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
          height: height,
          decoration: new BoxDecoration(
            color: AllColors().WHITE,
            borderRadius: new BorderRadius.only(
              topLeft: const Radius.circular(12.0),
              topRight: const Radius.circular(12.0),
            ),
          ),
          child: T,
        );
      });
}
