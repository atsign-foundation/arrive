import 'package:atsign_location_app/common_components/provider_callback.dart';

import 'package:atsign_location_app/services/backend_service.dart';
import 'package:atsign_location_app/services/home_event_service.dart';
import 'package:atsign_location_app/services/nav_service.dart';

import 'base_model.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/models/event_notification.dart';
import 'dart:convert';
import 'package:atsign_location_app/plugins/at_events_flutter/models/hybrid_notifiation_model.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'hybrid_provider.dart';

class EventProvider extends BaseModel {
  EventProvider();

  // ignore: non_constant_identifier_names
  String GET_ALL_EVENTS = 'get_all_events';
  // ignore: non_constant_identifier_names
  String UPDATE_EVENTS = 'update_event';
  // ignore: non_constant_identifier_names
  String CHECK_ACKNOWLEDGED_EVENT = 'check_acknowledged_event';
  // ignore: non_constant_identifier_names
  String MAP_UPDATED_EVENTS = 'map_updated_event';

  // ignore: non_constant_identifier_names
  String GET_SINGLE_USER = 'get_single_user';

  AtClientImpl atClientInstance;
  String currentAtSign;
  List<HybridNotificationModel> allNotifications = [];

  init(AtClientImpl clientInstance) {
    reset(GET_ALL_EVENTS);
    reset(UPDATE_EVENTS);
    reset(CHECK_ACKNOWLEDGED_EVENT);
    reset(MAP_UPDATED_EVENTS);
    reset(GET_SINGLE_USER);

    atClientInstance = clientInstance;
    currentAtSign = atClientInstance.currentAtSign;
  }

  getAllEvents() async {
    setStatus(GET_ALL_EVENTS, Status.Loading);

    allNotifications = [];

    List<String> response = await atClientInstance.getKeys(
      regex: 'createevent-',
    );

    if (response.length == 0) {
      setStatus(GET_ALL_EVENTS, Status.Done);
      return;
    }

    response.forEach((key) {
      HybridNotificationModel tempHyridNotificationModel =
          HybridNotificationModel(NotificationType.Event, key: key);
      allNotifications.add(tempHyridNotificationModel);
    });

    allNotifications.forEach((notification) {
      AtKey atKey = BackendService.getInstance().getAtKey(notification.key);
      notification.atKey = atKey;
    });

    filterBlockedContactsforEvents();

    for (int i = 0; i < allNotifications.length; i++) {
      AtValue value = await getAtValue(allNotifications[i].atKey);
      if (value != null) {
        allNotifications[i].atValue = value;
      }
    }

    convertJsonToEventModel();
    await checkForPendingEvents();
    setStatus(GET_ALL_EVENTS, Status.Done);

    updateEventDataAccordingToAcknowledgedData();
  }

  filterBlockedContactsforEvents() {
    List<HybridNotificationModel> tempList = [];
    for (int i = 0; i < allNotifications.length; i++) {
      if (ContactService().blockContactList.indexWhere((contact) =>
              ((contact.atSign == allNotifications[i].atKey.sharedBy) ||
                  (contact.atSign ==
                      '@' + allNotifications[i].atKey.sharedBy))) >=
          0) tempList.add(allNotifications[i]);
    }
    allNotifications.removeWhere((element) => tempList.contains(element));
  }

  Future<dynamic> getAtValue(AtKey key) async {
    AtValue atvalue = await atClientInstance
        .get(key)
        // ignore: return_of_invalid_type_from_catch_error
        .catchError((e) => print("error in get $e"));

    if (atvalue != null)
      return atvalue;
    else
      return null;
  }

  convertJsonToEventModel() {
    List<HybridNotificationModel> tempRemoveEventArray = [];

    for (int i = 0; i < allNotifications.length; i++) {
      try {
        // ignore: unrelated_type_equality_checks
        if (allNotifications[i].atValue != 'null' &&
            allNotifications[i].atValue != null) {
          EventNotificationModel event = EventNotificationModel.fromJson(
              jsonDecode(allNotifications[i].atValue.value));

          if (event != null && event.group.members.length > 0) {
            event.key = allNotifications[i].key;

            allNotifications[i].eventNotificationModel = event;
          }
        } else {
          tempRemoveEventArray.add(allNotifications[i]);
        }
      } catch (e) {
        tempRemoveEventArray.add(allNotifications[i]);
      }
    }

    allNotifications
        .removeWhere((element) => tempRemoveEventArray.contains(element));
  }

  actionOnEvent(EventNotificationModel event, ATKEY_TYPE_ENUM keyType,
      {bool isAccepted, bool isSharing, bool isExited}) async {
    setStatus(UPDATE_EVENTS, Status.Loading);

    EventNotificationModel eventData = EventNotificationModel.fromJson(
        jsonDecode(
            EventNotificationModel.convertEventNotificationToJson(event)));

    try {
      String atkeyMicrosecondId =
          eventData.key.split('createevent-')[1].split('@')[0];

      String currentAtsign =
          BackendService.getInstance().atClientInstance.currentAtSign;

      eventData.isUpdate = true;
      if (eventData.atsignCreator.toLowerCase() ==
          currentAtsign.toLowerCase()) {
        eventData.isSharing =
            isSharing != null ? isSharing : eventData.isSharing;
        if (isSharing == false) {
          eventData.lat = null;
          eventData.long = null;
        }
      } else {
        eventData.group.members.forEach((member) {
          if (member.atSign[0] != '@') member.atSign = '@' + member.atSign;
          if (currentAtsign[0] != '@') currentAtsign = '@' + currentAtsign;

          if (member.atSign.toLowerCase() == currentAtsign.toLowerCase()) {
            member.tags['isAccepted'] =
                isAccepted != null ? isAccepted : member.tags['isAccepted'];
            member.tags['isSharing'] =
                isSharing != null ? isSharing : member.tags['isSharing'];
            member.tags['isExited'] =
                isExited != null ? isExited : member.tags['isExited'];

            if (isSharing == false) {
              member.tags['lat'] = null;
              member.tags['long'] = null;
            }
          }
        });
      }

      AtKey key = formAtKey(keyType, atkeyMicrosecondId,
          eventData.atsignCreator, currentAtsign, event);

      // TODO : Check whther key is correct
      print('key $key');

      var notification =
          EventNotificationModel.convertEventNotificationToJson(eventData);
      var result = await atClientInstance.put(key, notification);

      // if key type is createevent, we have to notify all members
      if (keyType == ATKEY_TYPE_ENUM.CREATEEVENT) {
        // providerCallback<HybridProvider>(NavService.navKey.currentContext,
        //     task: (t) => t.mapUpdatedData(BackendService.getInstance()
        //         .convertEventToHybrid(NotificationType.Event,
        //             eventNotificationModel: eventData)),
        //     showLoader: false,
        //     taskName: (t) => t.HYBRID_MAP_UPDATED_EVENT_DATA,
        //     onSuccess: (t) {});

        List<String> allAtsignList = [];
        eventData.group.members.forEach((element) {
          allAtsignList.add(element.atSign);
        });

        key.sharedWith = jsonEncode(allAtsignList);
        var notifyAllResult = await atClientInstance.notifyAll(
            key, notification, OperationEnum.update);
      }

      setStatus(UPDATE_EVENTS, Status.Done);
      if (result) {
        providerCallback<HybridProvider>(NavService.navKey.currentContext,
            task: (provider) => provider.updatePendingStatus(
                BackendService.getInstance().convertEventToHybrid(
                    NotificationType.Event,
                    eventNotificationModel: eventData)),
            taskName: (provider) => provider.HYBRID_MAP_UPDATED_EVENT_DATA,
            showLoader: false,
            onSuccess: (provider) {});
      }

      return result;
    } catch (e) {
      print('error in updating event $e');
      setStatus(UPDATE_EVENTS, Status.Error);
      return false;
    }
  }

  // ignore: missing_return
  AtKey formAtKey(ATKEY_TYPE_ENUM keyType, String atkeyMicrosecondId,
      String sharedWith, String sharedBy, EventNotificationModel eventData) {
    switch (keyType) {
      case ATKEY_TYPE_ENUM.CREATEEVENT:
        AtKey atKey;
        List<HybridNotificationModel> allEventsNotfication =
            HomeEventService().getAllEvents;
        allEventsNotfication.forEach((event) {
          if (event.notificationType == NotificationType.Event &&
              event.key == eventData.key) {
            atKey = BackendService.getInstance().getAtKey(event.key);
          }
        });
        return atKey;
        break;

      case ATKEY_TYPE_ENUM.ACKNOWLEDGEEVENT:
        AtKey key = AtKey()
          ..metadata = Metadata()
          ..metadata.ttr = -1
          ..sharedWith = sharedWith
          ..sharedBy = sharedBy;

        key.key = 'eventacknowledged-$atkeyMicrosecondId';
        return key;
        break;
    }
  }

  checkForPendingEvents() async {
    allNotifications.forEach((notification) async {
      notification.eventNotificationModel.group.members.forEach((member) async {
        if ((member.atSign == currentAtSign) &&
            (member.tags['isAccepted'] == false) &&
            (member.tags['isExited'] == false)) {
          String atkeyMicrosecondId =
              notification.key.split('createevent-')[1].split('@')[0];
          String acknowledgedKeyId = 'eventacknowledged-$atkeyMicrosecondId';
          List<String> allRegexResponses =
              await atClientInstance.getKeys(regex: acknowledgedKeyId);
          if ((allRegexResponses != null) && (allRegexResponses.length > 0)) {
            notification.haveResponded = true;
          }
        }
      });
    });
  }

  checkForAcknowledgeEvents() {
    providerCallback<EventProvider>(NavService.navKey.currentContext,
        task: (provider) =>
            provider.updateEventDataAccordingToAcknowledgedData(),
        taskName: (provider) => provider.CHECK_ACKNOWLEDGED_EVENT,
        showLoader: false,
        onSuccess: (provider) {});
  }

  updateEventDataAccordingToAcknowledgedData() async {
    List<String> allEventKey = await atClientInstance.getKeys(
      regex: 'createevent-',
    );

    if (allEventKey.length == 0) {
      return;
    }

    List<String> allRegexResponses = [];
    for (int i = 0; i < allNotifications.length; i++) {
      allRegexResponses = [];
      String atkeyMicrosecondId =
          allNotifications[i].key.split('createevent-')[1].split('@')[0];
      String acknowledgedKeyId = 'eventacknowledged-$atkeyMicrosecondId';

      allRegexResponses =
          await atClientInstance.getKeys(regex: acknowledgedKeyId);

      if (allRegexResponses.length > 0) {
        for (int j = 0; j < allRegexResponses.length; j++) {
          if (allRegexResponses[j] != null &&
              !allNotifications[i].key.contains('cached')) {
            AtKey acknowledgedAtKey =
                BackendService.getInstance().getAtKey(allRegexResponses[j]);
            AtKey createEventAtKey =
                BackendService.getInstance().getAtKey(allNotifications[i].key);

            AtValue result = await atClientInstance
                .get(acknowledgedAtKey)
                // ignore: return_of_invalid_type_from_catch_error
                .catchError((e) => print("error in get $e"));

            if (result == null) {
              continue;
            }

            EventNotificationModel acknowledgedEvent =
                EventNotificationModel.fromJson(jsonDecode(result.value));
            EventNotificationModel storedEvent = new EventNotificationModel();

            String acknowledgedEventKeyId =
                acknowledgedEvent.key.split('createevent-')[1].split('@')[0];

            for (int k = 0; k < allNotifications.length; k++) {
              if (allNotifications[k]
                  .eventNotificationModel
                  .key
                  .contains(acknowledgedEventKeyId)) {
                storedEvent = allNotifications[k].eventNotificationModel;

                if (!compareEvents(storedEvent, acknowledgedEvent)) {
                  storedEvent.isUpdate = true;

                  storedEvent.group.members.forEach((groupMember) {
                    acknowledgedEvent.group.members.forEach((element) {
                      if (groupMember.atSign.toLowerCase() ==
                              element.atSign.toLowerCase() &&
                          groupMember.atSign
                              .contains(acknowledgedAtKey.sharedBy)) {
                        groupMember.tags = element.tags;
                      }
                    });
                  });

                  List<String> allAtsignList = [];
                  storedEvent.group.members.forEach((element) {
                    allAtsignList.add(element.atSign);
                  });
                  var updateResult =
                      await updateEvent(storedEvent, createEventAtKey);

                  createEventAtKey.sharedWith = jsonEncode(allAtsignList);

                  var notifyAllResult = await atClientInstance.notifyAll(
                      createEventAtKey,
                      EventNotificationModel.convertEventNotificationToJson(
                          storedEvent),
                      OperationEnum.update);

                  if (updateResult is bool && updateResult == true)
                    mapUpdatedEventDataToWidget(storedEvent);
                }
              }
            }
          }
        }
      }
    }
  }

  mapUpdatedEventDataToWidget(EventNotificationModel eventData) {
    BackendService.getInstance().mapUpdatedDataToWidget(
        BackendService.getInstance().convertEventToHybrid(
            NotificationType.Event,
            eventNotificationModel: eventData));
  }

  bool compareEvents(
      EventNotificationModel eventOne, EventNotificationModel eventTwo) {
    bool isDataSame = true;

    eventOne.group.members.forEach((groupOneMember) {
      eventTwo.group.members.forEach((groupTwoMember) {
        if (groupOneMember.atSign == groupTwoMember.atSign) {
          if (groupOneMember.tags['isAccepted'] !=
                  groupTwoMember.tags['isAccepted'] ||
              groupOneMember.tags['isSharing'] !=
                  groupTwoMember.tags['isSharing'] ||
              groupOneMember.tags['isExited'] !=
                  groupTwoMember.tags['isExited']) {
            isDataSame = false;
          }
        }
      });
    });

    return isDataSame;
  }

  cancelEvent(EventNotificationModel event) async {
    EventNotificationModel eventData = EventNotificationModel.fromJson(
        jsonDecode(
            EventNotificationModel.convertEventNotificationToJson(event)));
    if (eventData.atsignCreator == currentAtSign) {
      try {
        eventData.isCancelled = true;
        List<String> response = await atClientInstance.getKeys(
          regex: '${eventData.key}',
        );
        AtKey key = BackendService.getInstance().getAtKey(response[0]);
        bool result = await updateEvent(eventData, key);

        // notifying all members
        List<String> allAtsignList = [];
        eventData.group.members.forEach((element) {
          allAtsignList.add(element.atSign);
        });

        key.sharedWith = jsonEncode(allAtsignList);

        var notifyAllResult = await atClientInstance.notifyAll(
            key,
            EventNotificationModel.convertEventNotificationToJson(eventData),
            OperationEnum.update);

        if (result) {
          BackendService.getInstance().mapUpdatedDataToWidget(
              BackendService.getInstance().convertEventToHybrid(
                  NotificationType.Event,
                  eventNotificationModel: eventData));
        }
      } catch (e) {
        print('error in cancelling event:$e');
      }
    }
  }

  Future<dynamic> updateEvent(
      EventNotificationModel eventData, AtKey key) async {
    try {
      var notification =
          EventNotificationModel.convertEventNotificationToJson(eventData);

      var result = await atClientInstance.put(key, notification);
      if (result is bool) {
        print('event acknowledged:$result');
        return result;
      } else if (result != null) {
        return result.toString();
      } else
        return result;
    } catch (e) {
      print('error in updating notification:$e');
      return false;
    }
  }

  addDataToListEvent(EventNotificationModel eventNotificationModel) async {
    String newLocationDataKeyId;
    newLocationDataKeyId =
        eventNotificationModel.key.split('createevent-')[1].split('@')[0];

    List<String> allRegexKeys = [];
    String key;

    allRegexKeys = await atClientInstance.getKeys(
      regex: 'createevent-',
    );

    allRegexKeys.forEach((regex) {
      if (regex.contains('$newLocationDataKeyId')) {
        key = regex;
      }
    });

    if (key == null) {
      return;
    }

    HybridNotificationModel tempHyridNotificationModel =
        HybridNotificationModel(NotificationType.Event, key: key);
    eventNotificationModel.key = key;
    tempHyridNotificationModel.atKey =
        BackendService.getInstance().getAtKey(key);
    tempHyridNotificationModel.atValue =
        await getAtValue(tempHyridNotificationModel.atKey);
    tempHyridNotificationModel.eventNotificationModel = eventNotificationModel;
    allNotifications.add(tempHyridNotificationModel);

    return tempHyridNotificationModel;
  }
}
