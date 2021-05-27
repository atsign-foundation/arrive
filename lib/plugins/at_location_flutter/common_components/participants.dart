import 'dart:async';

import 'package:atsign_location_app/common_components/display_tile.dart';
import 'package:atsign_location_app/common_components/draggable_symbol.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/common_components/custom_heading.dart';
import 'package:atsign_location_app/plugins/at_location_flutter/location_modal/hybrid_model.dart';
import 'package:atsign_location_app/plugins/at_location_flutter/service/location_service.dart';
import 'package:atsign_location_app/plugins/at_location_flutter/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_contact/at_contact.dart';

class ParticipantsData {
  ParticipantsData._();
  static final ParticipantsData _instance = ParticipantsData._();
  factory ParticipantsData() => _instance;

  // ignore: close_sinks
  StreamController dataController =
      StreamController<List<HybridModel>>.broadcast();
  Stream<List<HybridModel>> get dataStream => dataController.stream;
  StreamSink<List<HybridModel>> get dataSink => dataController.sink;
  List<HybridModel> data = [];

  // ignore: close_sinks
  StreamController atsignController =
      StreamController<List<String>>.broadcast();
  Stream<List<String>> get atsignStream => atsignController.stream;
  StreamSink<List<String>> get atsignSink => atsignController.sink;
  List<String> atsigns = [];

  updateParticipants() {
    dataController.add(data);
  }

  putData(List<HybridModel> data) {
    this.data = data;
    dataController.add(data);
  }

  putAtsign(List<String> atsigns) {
    this.atsigns = atsigns;
    atsignController.add(atsigns);
  }
}

// ignore: must_be_immutable
class Participants extends StatefulWidget {
  bool active;
  List<HybridModel> data;
  List<String> atsign;

  Participants(this.active, {this.data, this.atsign});

  @override
  _ParticipantsState createState() => _ParticipantsState();
}

class _ParticipantsState extends State<Participants> {
  List<String> untrackedAtsigns = [];

  List<String> trackedAtsigns = [];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: ParticipantsData().dataStream,
        builder: (context, AsyncSnapshot<List<HybridModel>> snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error in getting Participants',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 26),
                ),
              );
            } else {
              untrackedAtsigns = [];
              trackedAtsigns = snapshot.data != null
                  ? snapshot.data.map((e) => e.displayName).toList()
                  : [];

              ParticipantsData().atsigns.forEach((element) {
                trackedAtsigns.contains(element)
                    ? print('')
                    : untrackedAtsigns.add(element);
              });
              return builder();
            }
          } else {
            untrackedAtsigns = [];
            trackedAtsigns = ParticipantsData().data != null
                ? ParticipantsData().data.map((e) => e.displayName).toList()
                : [];

            ParticipantsData().atsigns.forEach((element) {
              trackedAtsigns.contains(element)
                  ? print('')
                  : untrackedAtsigns.add(element);
            });
            return builder();
          }
        });
  }

  Widget builder() {
    return Container(
      height: 422.toHeight,
      padding:
          EdgeInsets.fromLTRB(15.toWidth, 5.toHeight, 15.toWidth, 10.toHeight),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DraggableSymbol(),
            CustomHeading(heading: 'Participants', action: 'Cancel'),
            SizedBox(
              height: 10.toHeight,
            ),
            widget.active
                ? ListView.separated(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: widget.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return widget.data[index] == LocationService().eventData
                          ? SizedBox()
                          : DisplayTile(
                              title: widget.data[index].displayName ?? '',
                              atsignCreator: widget.data[index].displayName,
                              subTitle: null,
                              action: Text(
                                (widget.data[index].displayName ==
                                        LocationService().myData?.displayName)
                                    ? ''
                                    : '${widget.data[index].eta}',
                                style: CustomTextStyles().darkGrey14,
                              ),
                            );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return widget.data[index] == LocationService().eventData
                          ? Divider()
                          : SizedBox();
                    },
                  )
                : ListView.separated(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: widget.atsign.length,
                    itemBuilder: (BuildContext context, int index) {
                      return DisplayTile(
                        title: widget.atsign[index] ?? '',
                        atsignCreator: widget.atsign[index],
                        subTitle: null,
                        action: Text(
                          '',
                          style: CustomTextStyles().orange14,
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider();
                    },
                  ),
            widget.active
                ? ListView.separated(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: untrackedAtsigns.length,
                    itemBuilder: (BuildContext context, int index) {
                      return DisplayTile(
                        title: untrackedAtsigns[index] ?? 'user name',
                        atsignCreator: untrackedAtsigns[index],
                        subTitle: null,
                        action: Text(
                          LocationService()
                                  .exitedAtsigns
                                  .contains(untrackedAtsigns[index])
                              ? 'Exited'
                              : isActionRequired(untrackedAtsigns[index])
                                  ? 'Action Required'
                                  : 'Location not received',
                          style: CustomTextStyles().orange14,
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider();
                    },
                  )
                : SizedBox()
          ],
        ),
      ),
    );
  }

  bool isActionRequired(String _atsign) {
    Iterable<AtContact> _atcontact = LocationService()
        .eventListenerKeyword
        .group
        .members
        .where((element) => element.atSign == _atsign);
    if ((_atcontact != null) && (_atcontact.length > 0)) {
      if ((_atcontact.first.tags['isAccepted'] == false) &&
          (_atcontact.first.tags['isExited'] == false)) {
        return true;
      }
    }

    return false;
  }
}
