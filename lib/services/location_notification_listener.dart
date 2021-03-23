import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/at_contacts_flutter.dart';
import 'package:atsign_location_app/plugins/at_location_flutter/location_modal/hybrid_model.dart';
import 'package:atsign_location_app/plugins/at_location_flutter/location_modal/location_notification.dart';
import 'package:atsign_location_app/plugins/at_location_flutter/service/location_service.dart';
import 'package:atsign_location_app/data_services/hive/hive_db.dart';
import 'package:atsign_location_app/services/nav_service.dart';
import 'package:atsign_location_app/view_models/hybrid_provider.dart';
import 'package:latlong/latlong.dart';
import 'package:provider/provider.dart';

import 'backend_service.dart';

class LocationNotificationListener {
  LocationNotificationListener._();
  static LocationNotificationListener _instance =
      LocationNotificationListener._();
  factory LocationNotificationListener() => _instance;
  final HiveDataProvider _hiveDataProvider = HiveDataProvider();

  AtClientImpl atClientInstance;
  AtClientService atClientServiceInstance;
  String atsign;
  List<HybridModel> allUsersList;
  // ignore: non_constant_identifier_names
  String LOCATION_NOTIFY = 'locationnotify';
  bool sendLocation;
  List<KeyLocationModel> allLocationNotifications = [];

  StreamController _allUsersController;
  Stream<List<HybridModel>> get atHybridUsersStream =>
      _allUsersController.stream;
  StreamSink<List<HybridModel>> get atHybridUsersSink =>
      _allUsersController.sink;

  init(AtClientImpl _atClientInstance) {
    atClientInstance = _atClientInstance;
    atClientServiceInstance = AtClientService();
    allUsersList = [];
    _allUsersController = StreamController<List<HybridModel>>.broadcast();

    getAllLocationData();
  }

  getAllLocationData() async {
    List<String> response = await atClientInstance.getKeys(
      regex: '$LOCATION_NOTIFY',
    );
    if (response.length == 0) {
      return;
    }

    await Future.forEach(response, (key) async {
      if ('@$key'.contains('cached')) {
        AtKey atKey = BackendService.getInstance().getAtKey(key);
        AtValue value = await getAtValue(atKey);
        if (value != null) {
          KeyLocationModel tempKeyLocationModel =
              KeyLocationModel(key: key, atKey: atKey, atValue: value);
          allLocationNotifications.add(tempKeyLocationModel);
        }
      }
    });

    convertJsonToLocationModel();
    filterData();

    createHybridFromKeyLocationModel();
  }

  convertJsonToLocationModel() {
    for (int i = 0; i < allLocationNotifications.length; i++) {
      try {
        if ((allLocationNotifications[i].atValue.value != null) &&
            (allLocationNotifications[i].atValue.value != "null")) {
          LocationNotificationModel locationNotificationModel =
              LocationNotificationModel.fromJson(
                  jsonDecode(allLocationNotifications[i].atValue.value));
          allLocationNotifications[i].locationNotificationModel =
              locationNotificationModel;
        }
      } catch (e) {
        print('error in convertJsonToLocationModel:$e');
      }
    }
  }

  filterData() {
    List<KeyLocationModel> tempArray = [];
    for (int i = 0; i < allLocationNotifications.length; i++) {
      // ignore: unrelated_type_equality_checks
      if ((allLocationNotifications[i].locationNotificationModel == 'null') ||
          (allLocationNotifications[i].locationNotificationModel == null) ||
          (allLocationNotifications[i]
                  .locationNotificationModel
                  .to
                  .difference(DateTime.now())
                  .inMinutes <
              0)) tempArray.add(allLocationNotifications[i]);
    }

    allLocationNotifications
        .removeWhere((element) => tempArray.contains(element));
  }

  createHybridFromKeyLocationModel() {
    allLocationNotifications.forEach((keyLocationModel) async {
      var _image = await getImageOfAtsign(
          keyLocationModel.locationNotificationModel.atsignCreator);
      HybridModel user = HybridModel(
          displayName: keyLocationModel.locationNotificationModel.atsignCreator,
          latLng: keyLocationModel.locationNotificationModel.getLatLng,
          image: _image,
          eta: '?');

      allUsersList.add(user);
    });
    atHybridUsersSink.add(allUsersList);
  }

  updateShareLocation(bool value) async {
    await _hiveDataProvider.insertData(
      "Sharing",
      {"isSharing": value.toString()},
    );

    Provider.of<HybridProvider>(NavService.navKey.currentContext, listen: false)
        .initialiseLacationSharing();
  }

  getShareLocation() async {
    var data = await _hiveDataProvider.readData("Sharing");
    return (data['isSharing'] == 'true') ? true : false;
  }

  updateHybridList(LocationNotificationModel newUser) async {
    bool contains = false;
    int index;
    allUsersList.forEach((user) {
      if (user.displayName == newUser.atsignCreator) {
        contains = true;
        index = allUsersList.indexOf(user);
      }
    });
    if (!contains) {
      print('!contains from main app');

      String atsign = newUser.atsignCreator;
      LatLng _latlng = newUser.getLatLng;
      var _image = await getImageOfAtsign(atsign);

      HybridModel user = HybridModel(
          displayName: newUser.atsignCreator,
          latLng: _latlng,
          image: _image,
          eta: '?');

      allUsersList.add(user);
      _allUsersController.add(allUsersList);
      atHybridUsersSink.add(allUsersList);
      LocationService().newList(allUsersList);
    } else {
      allUsersList[index].latLng = newUser.getLatLng;
      allUsersList[index].eta = '?';
      _allUsersController.add(allUsersList);
      atHybridUsersSink.add(allUsersList);
      LocationService().newList(allUsersList);
    }
  }

  deleteReceivedData(String atsign) {
    allUsersList.removeWhere((element) => element.displayName == atsign);
    LocationService().removeUser(atsign);
    atHybridUsersSink.add(allUsersList);
  }

  getImageOfAtsign(String atsign) async {
    try {
      AtContact contact;
      Uint8List image;
      contact = await getAtSignDetails(atsign);

      if (contact == null) {
        AtContactsImpl atContact = await AtContactsImpl.getInstance(
            BackendService.getInstance()
                .atClientServiceInstance
                .atClient
                .currentAtSign);
        contact = await atContact.get(atsign);
      }

      if (contact != null) {
        if (contact.tags != null && contact.tags['image'] != null) {
          List<int> intList = contact.tags['image'].cast<int>();
          image = Uint8List.fromList(intList);
        }
      }
      return image;
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> getAtValue(AtKey key) async {
    try {
      AtValue atvalue = await atClientInstance
          .get(key)
          // ignore: return_of_invalid_type_from_catch_error
          .catchError((e) => print("error in get $e"));

      if (atvalue != null)
        return atvalue;
      else
        return null;
    } catch (e) {
      print('getAtValue:$e');
      return null;
    }
  }
}

class KeyLocationModel {
  String key;
  AtKey atKey;
  AtValue atValue;
  LocationNotificationModel locationNotificationModel;
  KeyLocationModel(
      {this.key, this.atKey, this.atValue, this.locationNotificationModel});
}
