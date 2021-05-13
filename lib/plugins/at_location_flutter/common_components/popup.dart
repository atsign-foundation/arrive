import 'package:atsign_location_app/plugins/at_events_flutter/common_components/contacts_initials.dart';
import 'package:at_chat_flutter/widgets/custom_circle_avatar.dart';
import 'package:atsign_location_app/plugins/at_location_flutter/common_components/pointed_bottom.dart';
import 'package:atsign_location_app/plugins/at_location_flutter/location_modal/hybrid_model.dart';
import 'package:atsign_location_app/plugins/at_location_flutter/service/location_service.dart';
import 'package:flutter/material.dart';

Widget buildPopup(HybridModel user) {
  String contactInitial;
  if (user.displayName != null) {
    if (user.displayName[0] == '@') {
      contactInitial = user.displayName.substring(1, user.displayName.length);
    } else {
      contactInitial = user.displayName;
    }
  }

  return Stack(
    alignment: Alignment.center,
    children: [
      Positioned(bottom: 0, child: pointedBottom()),
      Container(
        width: ((LocationService().eventListenerKeyword != null) &&
                (user == LocationService().eventData))
            ? 140
            : 200,
        height: 82,
        alignment: Alignment.topCenter,
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          child: Container(
            color: Colors.white,
            height: 76,
            child: Row(
              mainAxisAlignment:
                  ((LocationService().eventListenerKeyword != null) &&
                          (user == LocationService().eventData))
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
              children: [
                ((LocationService().eventListenerKeyword != null) &&
                        (user == LocationService().eventData))
                    ? SizedBox()
                    : Expanded(
                        child: Container(
                          padding: EdgeInsets.all(10),
                          color: Colors.blue[100],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                Icons.car_rental,
                                color: Colors.grey[600],
                                size: 32,
                              ),
                              Flexible(
                                child: Text(
                                  user.eta ?? '?',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.grey[600]),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                Flexible(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          child: user.image != null
                              ? CustomCircleAvatar(
                                  byteImage: user.image,
                                  nonAsset: true,
                                  size: 30)
                              : ContactInitial(
                                  initials: contactInitial,
                                  size: 60,
                                ),
                        ),
                        Text(
                          user.displayName ?? '...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
