import 'package:atsign_location_app/common_components/display_tile.dart';
import 'package:atsign_location_app/common_components/draggable_symbol.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/common_components/custom_heading.dart';
import 'package:atsign_location_app/plugins/at_location_flutter/location_modal/hybrid_model.dart';
import 'package:atsign_location_app/plugins/at_location_flutter/service/location_service.dart';
import 'package:atsign_location_app/plugins/at_location_flutter/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';

// ignore: must_be_immutable
class Participants extends StatelessWidget {
  bool active;
  List<HybridModel> data;
  List<String> atsign;

  Participants(this.active, {this.data, this.atsign});
  List<String> untrackedAtsigns = [];
  List<String> trackedAtsigns = [];

  @override
  Widget build(BuildContext context) {
    untrackedAtsigns = [];
    trackedAtsigns =
        data != null ? data.map((e) => e.displayName).toList() : [];

    atsign.forEach((element) {
      trackedAtsigns.contains(element)
          ? print('')
          : untrackedAtsigns.add(element);
    });
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
            active
                ? ListView.separated(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return data[index] == LocationService().eventData
                          ? SizedBox()
                          : DisplayTile(
                              title: data[index].displayName ?? 'user name',
                              atsignCreator: data[index].displayName,
                              subTitle: data[index].displayName ?? '@sign',
                              action: Text(
                                '${data[index].eta}' ?? 'At the location',
                                style: CustomTextStyles().darkGrey14,
                              ),
                            );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return data[index] == LocationService().eventData
                          ? Divider()
                          : SizedBox();
                    },
                  )
                : ListView.separated(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: atsign.length,
                    itemBuilder: (BuildContext context, int index) {
                      return DisplayTile(
                        title: atsign[index] ?? 'user name',
                        atsignCreator: atsign[index],
                        subTitle: '@sign',
                        action: Text(
                          'Location not received',
                          style: CustomTextStyles().orange14,
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider();
                    },
                  ),
            active
                ? ListView.separated(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: untrackedAtsigns.length,
                    itemBuilder: (BuildContext context, int index) {
                      return DisplayTile(
                        title: untrackedAtsigns[index] ?? 'user name',
                        atsignCreator: untrackedAtsigns[index],
                        subTitle: '@sign',
                        action: Text(
                          'Location not received',
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
}
