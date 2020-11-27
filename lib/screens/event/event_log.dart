import 'package:atsign_location_app/common_components/custom_appbar.dart';
import 'package:atsign_location_app/common_components/custom_event_card.dart';
import 'package:atsign_location_app/common_components/pop_button.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
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
                          indicatorColor: AllColors().Black,
                          indicatorWeight: 3.toHeight,
                          labelColor: AllColors().Black,
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
                        padding: EdgeInsets.only(top: 20.toHeight),
                        height: SizeConfig().screenHeight - 180.toHeight,
                        child: TabBarView(
                          children: [
                            ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: 10,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    CustomEventCard(
                                      eventAndGroupName: Text(
                                        'Event @ Group Name',
                                        style: CustomTextStyles().black14,
                                      ),
                                      shareLocationDurationLable: Text(
                                          'Sharing my location untill 20:00',
                                          style: CustomTextStyles().grey12),
                                      eventDate: Text('Event on May 11',
                                          style: CustomTextStyles().grey12),
                                      invitedByLabel: Text(
                                          'Invited bt Username',
                                          style: CustomTextStyles().grey14),
                                    ),
                                    SizedBox(height: 10.toHeight),
                                    Divider(),
                                  ],
                                );
                              },
                            ),
                            ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: 3,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    CustomEventCard(
                                      eventAndGroupName: Text(
                                        'Event @ Group Name',
                                        style: CustomTextStyles().black14,
                                      ),
                                      shareLocationDurationLable: Text(
                                          'Sharing my location untill 20:00',
                                          style: CustomTextStyles().grey12),
                                      eventDate: Text('Event on May 11',
                                          style: CustomTextStyles().grey12),
                                      invitedByLabel: Text(
                                          'Invited bt Username',
                                          style: CustomTextStyles().grey14),
                                    ),
                                    SizedBox(height: 10.toHeight),
                                    Divider(),
                                  ],
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
