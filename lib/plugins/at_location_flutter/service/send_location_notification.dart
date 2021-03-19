import 'dart:async';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:atsign_location_app/plugins/at_location_flutter/location_modal/location_notification.dart';
import 'package:atsign_location_app/plugins/at_location_flutter/service/my_location.dart';
import 'package:atsign_location_app/services/backend_service.dart';
import 'package:atsign_location_app/services/location_notification_listener.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';

class SendLocationNotification {
  SendLocationNotification._();
  static SendLocationNotification _instance = SendLocationNotification._();
  factory SendLocationNotification() => _instance;
  Timer timer;
  List<LocationNotificationModel> receivingAtsigns;
  AtClientImpl atClient;
  StreamSubscription<Position> positionStream;
  init(List<LocationNotificationModel> atsigns, AtClientImpl newAtClient) {
    if ((timer != null) && (timer.isActive)) timer.cancel();

    receivingAtsigns = [...atsigns];
    atClient = newAtClient;
    print('receivingAtsigns length - ${receivingAtsigns.length}');

    if (positionStream != null) positionStream.cancel();
    updateMyLocation();
  }

  addMember(LocationNotificationModel notification) async {
    print('addMember ${notification.receiver} ${notification.key}');

    print('before adding receivingAtsigns length ${receivingAtsigns.length}');
    receivingAtsigns.forEach((element) {
      print('${element.key}');
    });
    if (receivingAtsigns
            .indexWhere((element) => element.key == notification.key) >
        -1) {
      print('receivingAtsigns already contain ${notification.key}');
      return;
    }
    // send
    bool isMasterSwitchOn =
        await LocationNotificationListener().getShareLocation();
    if (isMasterSwitchOn) {
      bool isSend = false;

      if (notification.to == null)
        isSend = true;
      else if ((DateTime.now().difference(notification.from) >
              Duration(seconds: 0)) &&
          (notification.to.difference(DateTime.now()) > Duration(seconds: 0)))
        isSend = true;

      LatLng myLocation = await getMyLocation();
      if (isSend) {
        notification.lat = myLocation.latitude;
        notification.long = myLocation.longitude;
        String atkeyMicrosecondId =
            notification.key.split('-')[1].split('@')[0];
        AtKey atKey = newAtKey(
            5000, "locationnotify-$atkeyMicrosecondId", notification.receiver);
        try {
          await atClient.put(
              atKey,
              LocationNotificationModel.convertLocationNotificationToJson(
                  notification));
        } catch (e) {
          print('error in sending location: $e');
        }
      }
    }

    // add

    receivingAtsigns.add(notification);
    print('after adding receivingAtsigns length ${receivingAtsigns.length}');
  }

  removeMember(String key) async {
    print('removeMember $key');
    // TODO: Delete
    print('before deleting receivingAtsigns length ${receivingAtsigns.length}');
    receivingAtsigns.forEach((element) {
      print('${element.key}');
    });

    LocationNotificationModel locationNotificationModel;
    receivingAtsigns.removeWhere((element) {
      if (key.contains(element.key)) locationNotificationModel = element;
      return key.contains(element.key);
    });
    if (locationNotificationModel != null) sendNull(locationNotificationModel);

    print('after deleting receivingAtsigns length ${receivingAtsigns.length}');
    receivingAtsigns.forEach((element) {
      print('${element.key}');
    });
  }

  updateMyLocation() async {
    print('updateMyLocation');
    positionStream = Geolocator.getPositionStream(distanceFilter: 100)
        .listen((myLocation) async {
      bool isMasterSwitchOn =
          await LocationNotificationListener().getShareLocation();
      if (isMasterSwitchOn) {
        receivingAtsigns.forEach((notification) async {
          print('receivingAtSigns content ${notification.key}');

          //TODO: Before sending check for duplicate users (notification with same receiver)
          bool isSend = false;

          if (notification.to == null)
            isSend = true;
          else if ((DateTime.now().difference(notification.from) >
                  Duration(seconds: 0)) &&
              (notification.to.difference(DateTime.now()) >
                  Duration(seconds: 0))) isSend = true;
          if (isSend) {
            notification.lat = myLocation.latitude;
            notification.long = myLocation.longitude;
            String atkeyMicrosecondId =
                notification.key.split('-')[1].split('@')[0];
            AtKey atKey = newAtKey(5000, "locationnotify-$atkeyMicrosecondId",
                notification.receiver);
            try {
              var result = await atClient.put(
                  atKey,
                  LocationNotificationModel.convertLocationNotificationToJson(
                      notification));
            } catch (e) {
              print('error in sending location: $e');
            }
          }
        });
      }
    });
  }

  sendNull(LocationNotificationModel locationNotificationModel) async {
    String atkeyMicrosecondId =
        locationNotificationModel.key.split('-')[1].split('@')[0];
    AtKey atKey = newAtKey(5000, "locationnotify-$atkeyMicrosecondId",
        locationNotificationModel.receiver);
    var result = await atClient.delete(atKey);
    print('$atKey delete operation $result');
  }

  deleteAllLocationKey() async {
    List<String> response = await atClient.getKeys(
      regex: 'locationnotify',
    );
    response.forEach((key) async {
      if (!'@$key'.contains('cached')) {
        // the keys i have created
        AtKey atKey = BackendService.getInstance().getAtKey(key);
        var result = await atClient.delete(atKey);
        print('$key is deleted ? $result');
      }
    });
  }

  AtKey newAtKey(int ttr, String key, String sharedWith) {
    AtKey atKey = AtKey()
      ..metadata = Metadata()
      ..metadata.ttr = ttr
      ..metadata.ccd = true
      ..key = key
      ..sharedWith = sharedWith
      ..sharedBy = atClient.currentAtSign;
    return atKey;
  }
}

enum ATSIGNS { COLIN, ASHISH, BOB }
