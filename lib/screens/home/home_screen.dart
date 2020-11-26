import 'package:atsign_location_app/common_components/display_tile.dart';
import 'package:atsign_location_app/dummy_data/group_data.dart';
import 'package:atsign_location_app/screens/create_event/create_event.dart';
import 'package:atsign_location_app/screens/request_location/request_location.dart';
import 'package:atsign_location_app/screens/share_location/share_location.dart';
import 'package:atsign_location_app/screens/sidebar/sidebar.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
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
                  final url =
                      'https://www.google.com/maps/vt/pb=!1m4!1m3!1i$z!2i$x!3i$y!2m3!1e0!2sm!3i420120488!3m7!2sen!5e1105!12m4!1e68!2m2!1sset!2sRoadmap!4e0!5m1!1e0!23i4111425';
                  return CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                  );
                },
              ),
              Positioned(top: 0, right: 0, child: ShowDrawer()),
              SlidingUpPanel(
                color: Colors.transparent,
                controller: pc,
                minHeight: SizeConfig().screenHeight * 0.55,
                maxHeight: SizeConfig().screenHeight * 0.9,
                collapsed: Column(children: [
                  collapsedContent(),
                  Expanded(
                    child: Container(
                        width: SizeConfig().screenWidth,
                        padding: EdgeInsets.fromLTRB(
                            80.toWidth, 0.toHeight, 0.toWidth, 7.toHeight),
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
                                style: TextStyle(
                                    color: AllColors().DARK_GREY,
                                    fontSize: 14.toFont),
                              ),
                              Icon(Icons.keyboard_arrow_down)
                            ],
                          ),
                        )),
                  )
                ]),
                panel: SingleChildScrollView(
                  child: Column(
                    children: [
                      header(),
                      Container(
                        width: SizeConfig().screenWidth,
                        padding: EdgeInsets.symmetric(
                            horizontal: 15.toWidth, vertical: 10.toHeight),
                        decoration: BoxDecoration(
                          color: AllColors().WHITE,
                        ),
                        child:
                            // Column(
                            //   children: GroupData().group.map((user) {
                            //     return DisplayTile(
                            //       title: 'Event @ Group Name',
                            //       subTitle: 'Sharing my location until 20:00',
                            //       number: 10,
                            //     );
                            //   }).toList(),
                            // )

                            ListView.builder(
                                //controller: myscrollController,
                                physics: AlwaysScrollableScrollPhysics(),
                                itemCount: GroupData().group.length,
                                shrinkWrap: true,
                                itemBuilder: (BuildContext context, int index) {
                                  return Column(
                                    children: [
                                      DisplayTile(
                                        title:
                                            GroupData().group[index].username,
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
                      ),
                    ],
                  ),
                ),
              )
            ],
          )),
    );
  }

  Widget collapsedContent() {
    return Column(
      children: [
        header(),
        Container(
            padding: EdgeInsets.symmetric(
                horizontal: 15.toWidth, vertical: 10.toHeight),
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
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                height: 7.toHeight,
              ),
              Text(
                'Locations',
                style: TextStyle(
                    color: AllColors().DARK_GREY, fontSize: 16.toFont),
              ),
              SizedBox(
                height: 7.toHeight,
              ),
              DisplayTile(
                title: 'Event @ Group Name',
                subTitle: 'Sharing my location until 20:00',
                number: 10,
              ),
              Divider(),
              DisplayTile(title: 'User Name', subTitle: 'Can see my location'),
              Divider(),
              DisplayTile(
                  title: 'User Name',
                  subTitle: 'Sharing his location until 21:45'),
              Divider(),
            ])),
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

class ShowDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.toHeight,
      width: 50.toWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(6.0),
        ),
        color: AllColors().WHITE,
        boxShadow: [
          BoxShadow(
            color: AllColors().DARK_GREY,
            blurRadius: 2.0,
            spreadRadius: 2.0,
            offset: Offset(0.0, 0.0),
          )
        ],
      ),
      child: IconButton(
          padding: EdgeInsets.all(10),
          //iconSize: 20.toHeight,
          icon: Icon(
            Icons.grid_view,
            size: 27.toFont,
          ),
          onPressed: () {
            Scaffold.of(context).openEndDrawer();
          }),
    );
  }
}

class Tasks extends StatelessWidget {
  final Color color;
  final String task;
  Tasks({@required this.task, @required this.color});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 55.toHeight,
          width: 55.toWidth,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40.0), color: color),
        ),
        SizedBox(
          height: 5.toHeight,
        ),
        Text(
          task,
          style: TextStyle(color: AllColors().DARK_GREY),
        )
      ],
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
