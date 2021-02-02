import 'dart:async';
import 'dart:typed_data';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_contact/at_contact.dart';
import 'package:atsign_location/location_modal/hybrid_model.dart';
import 'package:atsign_location/location_modal/location_notification.dart';
import 'package:atsign_location/service/location_service.dart';
import 'package:atsign_location/service/send_location_notification.dart';
import 'package:atsign_location_app/data_services/hive/hive_db.dart';
import 'package:atsign_location_app/services/nav_service.dart';
import 'package:atsign_location_app/view_models/hybrid_provider.dart';
import 'package:hive/hive.dart';
import 'package:latlong/latlong.dart';
import 'package:provider/provider.dart';

import 'client_sdk_service.dart';

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
  String LOCATION_NOTIFY = 'locationNotify';
  bool sendLocation;

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
      print('!contains');
      String atsign = newUser.atsignCreator;
      LatLng _latlng = newUser.getLatLng;
      var _image = await getImageOfAtsignNew(atsign);

      HybridModel user = HybridModel(
          displayName: newUser.atsignCreator,
          latLng: _latlng,
          image: _image,
          eta: '?');

      allUsersList.add(user);
      _allUsersController.add(allUsersList);
      print('atHybridUsersSink added');
      atHybridUsersSink.add(allUsersList);
      LocationService().newList(allUsersList);
    } else {
      print('contains');
      print(newUser.getLatLng.toString());
      print(allUsersList[index].latLng.toString());
      if (newUser.getLatLng == LatLng(0, 0)) {
        allUsersList.remove(allUsersList[index]);
        LocationService().removeUser(newUser.atsignCreator);
        atHybridUsersSink.add(allUsersList);
      } else if (allUsersList[index].latLng != newUser.getLatLng) {
        allUsersList[index].latLng = newUser.getLatLng;
        allUsersList[index].eta = '?';
        _allUsersController.add(allUsersList);
        print('atHybridUsersSink added');
        atHybridUsersSink.add(allUsersList);
        LocationService().newList(allUsersList);
      }
    }
  }

  Future<dynamic> getImageOfAtsign(String atsign) async {
    try {
      var metadata = Metadata();
      metadata.isPublic = true;
      metadata.namespaceAware = false;
      AtKey key = AtKey();
      key.sharedBy = atsign;
      key.metadata = metadata;
      key.metadata.isBinary = true;
      key.key = 'image.persona';
      var result = await atClientInstance.get(key);
      var _image = result.value;
      return _image;
    } catch (e) {
      return null;
    }
  }

  getImageOfAtsignNew(String atsign) async {
    AtContact contact;
    Uint8List image;
    AtContactsImpl atContact = await AtContactsImpl.getInstance(
        ClientSdkService.getInstance()
            .atClientServiceInstance
            .atClient
            .currentAtSign);
    contact = await atContact.get(atsign);
    if (contact != null) {
      if (contact.tags != null && contact.tags['image'] != null) {
        List<int> intList = contact.tags['image'].cast<int>();
        image = Uint8List.fromList(intList);
      }
    }
    return image;
  }
}
