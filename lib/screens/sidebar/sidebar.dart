import 'dart:typed_data';
import 'package:at_backupkey_flutter/at_backupkey_flutter.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:at_location_flutter/common_components/contacts_initial.dart';
import 'package:at_location_flutter/common_components/custom_toast.dart';
import 'package:at_location_flutter/service/my_location.dart';
import 'package:atsign_location_app/common_components/bottom_sheet/bottom_sheet.dart';
import 'package:atsign_location_app/common_components/change_atsign_bottom_sheet.dart';
import 'package:atsign_location_app/routes/route_names.dart';
import 'package:atsign_location_app/routes/routes.dart';
import 'package:atsign_location_app/screens/contacts/contacts_bottomsheet.dart';
import 'package:atsign_location_app/services/backend_service.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:atsign_location_app/view_models/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:provider/provider.dart';
import 'package:package_info/package_info.dart';

class SideBar extends StatefulWidget {
  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  bool state = false;
  Uint8List image;
  AtContact contact;
  AtContactsImpl atContact;
  String name;
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  String _currentAtsign;

  @override
  void initState() {
    _currentAtsign = AtClientManager.getInstance().atClient.getCurrentAtSign();

    super.initState();
    getEventCreator();
    state = false;
    getLocationSharing();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  // ignore: always_declare_return_types
  getLocationSharing() async {
    var newState = await LocationProvider().getShareLocation();
    setState(() {
      state = newState;
    });
  }

  // ignore: always_declare_return_types
  getEventCreator() async {
    var contact = await getAtSignDetails(_currentAtsign);
    name = null;
    if (contact != null) {
      if (contact.tags != null && contact.tags['image'] != null) {
        List<int> intList = contact.tags['image'].cast<int>();
        setState(() {
          image = Uint8List.fromList(intList);
        });
      }
      if (contact.tags != null && contact.tags['name'] != null) {
        var newName = contact.tags['name'].toString();
        setState(() {
          name = newName;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: EdgeInsets.symmetric(horizontal: 22, vertical: 0.toHeight),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 0.toWidth, vertical: 50.toHeight),
              child: Row(
                children: [
                  (image != null)
                      ? ClipRRect(
                          borderRadius:
                              BorderRadius.all(Radius.circular(30.toFont)),
                          child: Image.memory(
                            image,
                            width: 50.toFont,
                            height: 50.toFont,
                            fit: BoxFit.fill,
                          ),
                        )
                      : ContactInitial(initials: _currentAtsign),
                  Flexible(
                      child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        name != null
                            ? Text(
                                name ?? '',
                                style: CustomTextStyles().darkGrey16,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            : SizedBox(),
                        Text(
                          _currentAtsign ?? '@sign',
                          style: CustomTextStyles().darkGrey14,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            iconText('Events', Icons.arrow_upward,
                () => SetupRoutes.push(context, Routes.EVENT_LOG)),
            SizedBox(
              height: 25.toHeight,
            ),
            iconText(
              'Contacts',
              Icons.contacts_rounded,
              () async {
                return SetupRoutes.push(context, Routes.CONTACT_SCREEN,
                    arguments: {
                      'currentAtSign': _currentAtsign,
                      'asSelectionScreen': false,
                      'onSendIconPressed': (String atsign) {
                        bottomSheet(context, ContactsBottomSheet(atsign), 150);
                      },
                    });
              },
            ),
            SizedBox(
              height: 25.toHeight,
            ),
            iconText(
              'Blocked Contacts',
              Icons.not_interested,
              () async {
                return SetupRoutes.push(
                  context,
                  Routes.BLOCKED_CONTACT_SCREEN,
                );
              },
            ),
            SizedBox(
              height: 25.toHeight,
            ),
            iconText(
              'Groups',
              Icons.group,
              () async {
                return SetupRoutes.push(context, Routes.GROUP_LIST, arguments: {
                  'currentAtSign': _currentAtsign,
                });
              },
            ),
            SizedBox(
              height: 25.toHeight,
            ),
            iconText(
              'Backup your keys',
              Icons.file_copy,
              () async {
                BackupKeyWidget(
                  atClientService: AtClientManager.getInstance().atClient,
                  atsign:
                      AtClientManager.getInstance().atClient.getCurrentAtSign(),
                ).showBackupDialog(context);
              },
            ),
            SizedBox(
              height: 25.toHeight,
            ),
            iconText('FAQ', Icons.question_answer,
                () => SetupRoutes.push(context, Routes.FAQS)),
            SizedBox(
              height: 25.toHeight,
            ),
            iconText(
                'Terms and Conditions',
                Icons.text_format_outlined,
                () =>
                    SetupRoutes.push(context, Routes.TERMS_CONDITIONS_SCREEN)),
            SizedBox(
              height: 25.toHeight,
            ),
            iconText(
              'Delete @sign',
              Icons.delete,
              () async {
                _deleteAtSign(_currentAtsign);
                setState(() {});
              },
            ),
            SizedBox(
              height: 25.toHeight,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Location Sharing',
                  style: CustomTextStyles().darkGrey16,
                ),
                Consumer<LocationProvider>(
                  builder: (context, provider, child) {
                    return Switch(
                      value: provider.isSharing,
                      onChanged: (value) async {
                        if (value) {
                          var latlng = await getMyLocation();
                          if (latlng == null) {
                            CustomToast().show(
                                'Location permission not granted', context);
                            return;
                          }
                        }
                        // ignore: unawaited_futures
                        provider.updateShareLocation(value);
                      },
                    );
                  },
                ),
              ],
            ),
            SizedBox(
              height: 14.toHeight,
            ),
            Flexible(
                child: Text(
              'When you turn this on, everyone you have given access to can see  your location.',
              style: CustomTextStyles().darkGrey12,
            )),
            Expanded(child: Container(height: 0)),
            iconText('Switch @sign', Icons.logout, () async {
              var currentAtsign = _currentAtsign;
              var atSignList = await KeyChainManager.getInstance()
                  .getAtSignListFromKeychain();

              await showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) => AtSignBottomSheet(
                  atSignList: atSignList,
                ),
              );
            }),
            Expanded(child: Container(height: 0)),
            Text(
              'App Version ${_packageInfo.version} (${_packageInfo.buildNumber})',
              style: CustomTextStyles().darkGrey13,
            ),
          ],
        ),
      ),
    );
  }

  // ignore: always_declare_return_types
  _deleteAtSign(String atsign) async {
    final _formKey = GlobalKey<FormState>();
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: Center(
              child: Text(
                'Delete @sign',
                style: TextStyle(
                    color: Colors.black,
                    letterSpacing: 0.1,
                    fontSize: 20.toFont,
                    fontWeight: FontWeight.bold),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Are you sure you want to delete all data associated with',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    letterSpacing: 0.1,
                    color: Colors.grey[700],
                    fontSize: 15.toFont,
                  ),
                ),
                SizedBox(height: 20),
                Text('$atsign',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20.toFont,
                        letterSpacing: 0.1,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                Text(
                  'Type the @sign above to proceed',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[700],
                    letterSpacing: 0.1,
                    fontSize: 12.toFont,
                  ),
                ),
                SizedBox(height: 5),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    validator: (value) {
                      if (value.toLowerCase().replaceAll(' ', '') != atsign) {
                        return "The @sign doesn't match. Please retype.";
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: AllColors().DARK_GREY)),
                        filled: true,
                        fillColor: Colors.white),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Caution: this action can't be undone",
                  style: TextStyle(
                    fontSize: 13.toFont,
                    letterSpacing: 0.1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                        child: Text('DELETE',
                            style: CustomTextStyles().primaryBold14),
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            await BackendService.getInstance()
                                .deleteAtSignFromKeyChain(atsign);
                            // await Navigator.pushNamedAndRemoveUntil(
                            //     context, Routes.SPLASH, (route) => false);
                          }
                        }),
                    Spacer(),
                    TextButton(
                        child: Text('Cancel',
                            style: CustomTextStyles().primaryBold14),
                        onPressed: () {
                          Navigator.pop(context);
                        })
                  ],
                )
              ],
            ),
          );
        });
  }

  Widget iconText(String text, IconData icon, Function onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            color: AllColors().DARK_GREY,
            size: 16.toFont,
          ),
          SizedBox(
            width: 15.toWidth,
          ),
          Flexible(
            child: Text(
              text,
              style: CustomTextStyles().darkGrey16,
            ),
          ),
        ],
      ),
    );
  }
}
