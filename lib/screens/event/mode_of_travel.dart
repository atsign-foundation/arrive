import 'package:atsign_location_app/common_components/invite_card.dart';
import 'package:atsign_location_app/common_components/tiles/text_tile.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';

class ModeOfTravel extends StatefulWidget {
  // String event, invitedPeopleCount, timeAndDate;

  @override
  _ModeOfTravelState createState() => _ModeOfTravelState();
}

class _ModeOfTravelState extends State<ModeOfTravel> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InviteCard(
            event: 'Tina Birthday’s Party',
            invitedPeopleCount: '10 people invited',
            timeAndDate: '10:00 am on Nov, 14',
          ),
          SizedBox(height: 10),
          Divider(),
          Text('How are you travelling to the event today?',
              style: CustomTextStyles().grey16),
          SizedBox(height: 10),
          Expanded(
              child: ListView.separated(
            separatorBuilder: (context, index) {
              return Column(
                children: <Widget>[SizedBox(height: 20), Divider()],
              );
            },
            itemCount: 4,
            itemBuilder: (context, index) {
              return Container(
                padding: EdgeInsets.only(top: 10),
                child: TextTile(
                  icon: Icons.directions_walk,
                  title: 'Walk',
                ),
              );
            },
          ))
        ],
      ),
    );
  }
}
