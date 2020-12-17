import 'package:atsign_location_app/common_components/custom_appbar.dart';
import 'package:atsign_location_app/common_components/display_tile.dart';
import 'package:atsign_location_app/common_components/pop_button.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/images.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_location_app/services/size_config.dart';

class EventLog extends StatefulWidget {
  @override
  _EventLogState createState() => _EventLogState();
}

class _EventLogState extends State<EventLog> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SafeArea(
        child: Scaffold(
          appBar: CustomAppBar(
            centerTitle: true,
            padding: true,
            title: 'Events',
            action: PopButton(label: 'Close'),
          ),
          body: Column(
            children: <Widget>[
              Container(
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      Container(
                        child: TabBar(
                          indicatorColor: Theme.of(context).primaryColor,
                          indicatorWeight: 3.toHeight,
                          labelColor: Theme.of(context).primaryColor,
                          unselectedLabelColor: AllColors().DARK_GREY,
                          tabs: [
                            Tab(
                              child: Text(
                                'Upcoming',
                                style: CustomTextStyles().boldLabel16,
                              ),
                            ),
                            Tab(
                              child: Text('Past',
                                  style: CustomTextStyles().boldLabel16),
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(
                            20.toWidth, 20.toHeight, 10.toWidth, 5.toHeight),
                        height: SizeConfig().screenHeight - 190.toHeight,
                        child: TabBarView(
                          children: [
                            ListView.separated(
                              scrollDirection: Axis.vertical,
                              itemCount: 10,
                              separatorBuilder: (context, index) {
                                return Divider();
                              },
                              itemBuilder: (context, index) {
                                return DisplayTile(
                                  title: 'Event @ Group Name',
                                  number: 10,
                                  image: AllImages().PERSON2,
                                  subTitle: 'Sharing my location untill 20:00',
                                  invitedBy: 'Invited bt Username',
                                );
                              },
                            ),
                            ListView.separated(
                              scrollDirection: Axis.vertical,
                              itemCount: 10,
                              separatorBuilder: (context, index) {
                                return Divider();
                              },
                              itemBuilder: (context, index) {
                                return DisplayTile(
                                  title: 'Event @ Group Name',
                                  number: 10,
                                  image: AllImages().PERSON2,
                                  subTitle: 'Sharing my location untill 20:00',
                                  invitedBy: 'Invited bt Username',
                                );
                              },
                            )
                          ],
                        ),
                      ),
                    ],
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
