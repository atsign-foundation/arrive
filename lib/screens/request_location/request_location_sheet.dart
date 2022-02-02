import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_group_flutter/screens/group_contact_view/group_contact_view.dart';
import 'package:at_location_flutter/at_location_flutter.dart';
import 'package:at_location_flutter/common_components/custom_toast.dart';
import 'package:at_location_flutter/service/request_location_service.dart';
import 'package:atsign_location_app/common_components/custom_appbar.dart';
import 'package:atsign_location_app/common_components/custom_button.dart';
import 'package:atsign_location_app/common_components/custom_input_field.dart';
import 'package:atsign_location_app/common_components/overlapping-contacts.dart';
import 'package:atsign_location_app/common_components/pop_button.dart';
import 'package:atsign_location_app/utils/constants/text_strings.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';

class RequestLocationSheet extends StatefulWidget {
  @override
  _RequestLocationSheetState createState() => _RequestLocationSheetState();
}

class _RequestLocationSheetState extends State<RequestLocationSheet> {
  List<AtContact> selectedContacts = [];
  bool isLoading;
  @override
  void initState() {
    super.initState();
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      padding: EdgeInsets.all(25),
      child: ListView(
        children: [
          CustomAppBar(
            centerTitle: false,
            title: TextStrings.requestLocation,
            action: PopButton(label: TextStrings.cancel),
          ),
          SizedBox(
            height: 25,
          ),
          Text(TextStrings.requestFrom, style: CustomTextStyles().greyLabel14),
          SizedBox(height: 10),
          CustomInputField(
            width: SizeConfig().screenWidth * 0.95,
            height: 50.toHeight,
            isReadOnly: true,
            hintText: TextStrings.searchAtsignFromContact,
            icon: Icons.contacts_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupContactView(
                    asSelectionScreen: true,
                    showGroups: true,
                    showContacts: true,
                    selectedList: (s) {
                      setState(() {
                        if (s.isEmpty) {
                          selectedContacts = [];
                        } else {
                          selectedContacts = [];
                          s.forEach((_groupElement) {
                            // for contacts
                            if (_groupElement.contact != null) {
                              var _containsContact = false;

                              // to prevent one contact from getting added again
                              selectedContacts.forEach((_contact) {
                                if (_groupElement.contact.atSign ==
                                    _contact.atSign) {
                                  _containsContact = true;
                                }
                              });

                              if (!_containsContact) {
                                selectedContacts.add(_groupElement.contact);
                              }
                            } else if (_groupElement.group != null) {
                              // for groups
                              _groupElement.group.members.forEach((element) {
                                var _containsContact = false;

                                // to prevent one contact from getting added again
                                selectedContacts.forEach((_contact) {
                                  if (element.atSign == _contact.atSign) {
                                    _containsContact = true;
                                  }
                                });

                                if (!_containsContact) {
                                  selectedContacts.add(element);
                                }
                              });
                            }
                          });
                        }
                      });
                    },
                  ),
                ),
              );
            },
          ),
          (selectedContacts.isNotEmpty)
              ? (OverlappingContacts(
                  selectedContacts,
                  onRemove: (_index) {
                    setState(() {
                      selectedContacts.removeAt(_index);
                    });
                  },
                ))
              : SizedBox(),
          SizedBox(
            height: 100,
          ),
          Center(
            child: isLoading
                ? CircularProgressIndicator()
                : CustomButton(
                    onTap: onRequestTap,
                    bgColor: Theme.of(context).primaryColor,
                    width: 164,
                    height: 48,
                    child: Text(
                      TextStrings.request,
                      style: TextStyle(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          fontSize: 16.toFont),
                    ),
                  ),
          )
        ],
      ),
    );
  }

  // ignore: always_declare_return_types
  onRequestTap() async {
    if (selectedContacts == null) {
      CustomToast().show(TextStrings.selectAContact, context, isError: true);
      return;
    }
    setState(() {
      isLoading = true;
    });

    var result;
    if (selectedContacts.length > 1) {
      await RequestLocationService()
          .sendRequestLocationToGroup(selectedContacts);
    } else {
      result =
          await sendRequestLocationNotification(selectedContacts[0].atSign);
    }
    if (result == null) {
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
      return;
    }

    if (result == true) {
      CustomToast().show(TextStrings.locationRequestSent, context, isSuccess: true);
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
    } else {
      CustomToast().show(TextStrings.somethingWentWrong, context, isError: true);
      setState(() {
        isLoading = false;
      });
    }
  }
}
