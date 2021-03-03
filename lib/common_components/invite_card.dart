import 'dart:typed_data';

import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:atsign_location_app/common_components/custom_circle_avatar.dart';
import 'package:atsign_location_app/common_components/pop_button.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/images.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';

class InviteCard extends StatefulWidget {
  final String event, invitedPeopleCount, timeAndDate, atSign, memberCount;
  InviteCard(
      {this.event,
      this.invitedPeopleCount,
      this.timeAndDate,
      this.atSign,
      this.memberCount});

  @override
  _InviteCardState createState() => _InviteCardState();
}

class _InviteCardState extends State<InviteCard> {
  Uint8List memoryImage;
  @override
  void initState() {
    super.initState();
    if (widget.atSign != null) getAtsignDetails();
  }

  getAtsignDetails() async {
    AtContact contact = await getAtSignDetails(widget.atSign);
    if (contact != null) {
      if (contact.tags != null && contact.tags['image'] != null) {
        List<int> intList = contact.tags['image'].cast<int>();
        setState(() {
          memoryImage = Uint8List.fromList(intList);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Stack(
            children: [
              CustomCircleAvatar(
                image: AllImages().PERSON2,
                size: 74,
                isMemoryImage: true,
                contactInitial: widget.atSign,
              ),
              widget.memberCount != null
                  ? Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AllColors().BLUE,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                            child: Text(
                          '${widget.memberCount}',
                          style: CustomTextStyles().black10,
                        )),
                      ),
                    )
                  : SizedBox()
            ],
          ),
          SizedBox(width: 10.toWidth),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.event != null
                    ? Text(widget.event, style: CustomTextStyles().black18)
                    : SizedBox(),
                SizedBox(height: 5.toHeight),
                widget.invitedPeopleCount != null
                    ? Text(widget.invitedPeopleCount,
                        style: CustomTextStyles().grey14)
                    : SizedBox(),
                SizedBox(height: 10.toHeight),
                widget.timeAndDate != null
                    ? Text(widget.timeAndDate,
                        style: CustomTextStyles().black14)
                    : SizedBox(),
              ],
            ),
          ),
          PopButton(label: 'Decide Later')
        ],
      ),
    );
  }
}
