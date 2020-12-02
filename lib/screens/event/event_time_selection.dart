import 'package:atsign_location_app/common_components/invite_card.dart';
import 'package:atsign_location_app/common_components/text_tile_repeater.dart';
import 'package:flutter/material.dart';

class EventTimeSelection extends StatefulWidget {
  final String title;
  EventTimeSelection({this.title});

  @override
  _EventTimeSelectionState createState() => _EventTimeSelectionState();
}

class _EventTimeSelectionState extends State<EventTimeSelection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          InviteCard(
            event: 'Tina Birthday’s Party',
            invitedPeopleCount: '10 people invited',
            timeAndDate: '10:00 am on Nov, 14',
          ),
          SizedBox(height: 10),
          Divider(),
          Expanded(
            child: TextTileRepeater(
              title: widget.title,
              options: [
                '2 hours before the event',
                '60 hours before the event',
                '30 hours before the event'
              ],
            ),
          )
        ],
      ),
    );
  }
}
