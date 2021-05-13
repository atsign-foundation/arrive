import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/screens/contacts_screen.dart';
import 'package:at_contacts_group_flutter/widgets/custom_toast.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/common_components/overlapping-contacts.dart';
import 'package:atsign_location_app/common_components/custom_appbar.dart';
import 'package:atsign_location_app/common_components/custom_button.dart';
import 'package:atsign_location_app/common_components/custom_input_field.dart';
import 'package:atsign_location_app/common_components/pop_button.dart';
import 'package:atsign_location_app/common_components/provider_callback.dart';
import 'package:atsign_location_app/services/location_sharing_service.dart';
import 'package:atsign_location_app/services/nav_service.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:atsign_location_app/view_models/hybrid_provider.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/models/hybrid_notifiation_model.dart';

class ShareLocationSheet extends StatefulWidget {
  @override
  _ShareLocationSheetState createState() => _ShareLocationSheetState();
}

class _ShareLocationSheetState extends State<ShareLocationSheet> {
  AtContact selectedContact;
  bool isLoading;
  String selectedOption;

  @override
  void initState() {
    super.initState();
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      padding: EdgeInsets.all(25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomAppBar(
            centerTitle: false,
            title: 'Share Location',
            action: PopButton(label: 'Cancel'),
          ),
          SizedBox(
            height: 25,
          ),
          Text('Share with', style: CustomTextStyles().greyLabel14),
          SizedBox(height: 10),
          CustomInputField(
            width: SizeConfig().screenWidth * 0.95,
            height: 50.toFont,
            isReadOnly: true,
            hintText: 'Search @sign from contacts',
            icon: Icons.contacts_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ContactsScreen(
                    asSelectionScreen: true,
                    asSingleSelectionScreen: true,
                    context: context,
                    selectedList: (selectedList) {
                      if (selectedList.length > 0)
                        setState(() {
                          selectedContact = selectedList[0];
                        });
                    },
                  ),
                ),
              );
            },
          ),
          (selectedContact != null)
              ? (OverlappingContacts(
                  selectedList: [selectedContact],
                  onRemove: () {
                    setState(() {
                      selectedContact = null;
                    });
                  },
                  isMultipleUser: false,
                ))
              : SizedBox(),
          SizedBox(height: 25),
          Text(
            'Duration',
            style: CustomTextStyles().greyLabel14,
          ),
          SizedBox(height: 10),
          Container(
            color: AllColors().INPUT_GREY_BACKGROUND,
            width: SizeConfig().screenWidth * 0.95,
            height: 50.toFont,
            padding: EdgeInsets.only(left: 10, right: 10, top: 10),
            child: DropdownButton(
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down),
              underline: SizedBox(),
              elevation: 0,
              dropdownColor: AllColors().INPUT_GREY_BACKGROUND,
              value: selectedOption,
              hint: Text("Select Duration",
                  style: TextStyle(
                      color: AllColors().LIGHT_GREY_LABEL,
                      fontSize: 15.toFont)),
              style:
                  TextStyle(color: AllColors().DARK_GREY, fontSize: 13.toFont),
              items: [
                "Select Duration",
                '30 mins',
                '2 hours',
                '24 hours',
                'Until turned off'
              ].map((String option) {
                return new DropdownMenuItem<String>(
                  value: option == "Select Duration" ? null : option,
                  child: option == "Select Duration"
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(option,
                                style: TextStyle(
                                    color: AllColors().LIGHT_GREY_LABEL,
                                    fontSize: 15.toFont)),
                            Icon(Icons.keyboard_arrow_up)
                          ],
                        )
                      : Text(option,
                          style: TextStyle(
                              color: AllColors().DARK_GREY,
                              fontSize: 13.toFont)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedOption = value;
                });
              },
            ),
          ),
          Expanded(child: SizedBox()),
          Center(
            child: isLoading
                ? CircularProgressIndicator()
                : CustomButton(
                    child: Text('Share',
                        style: TextStyle(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            fontSize: 16.toFont)),
                    onTap: onShareTap,
                    bgColor: Theme.of(context).primaryColor,
                    width: 164,
                    height: 48,
                  ),
          ),
        ],
      ),
    );
  }

  onShareTap() async {
    if (selectedContact == null) {
      CustomToast().show('Select a contact', context);
      return;
    }
    if (selectedOption == null) {
      CustomToast().show('Select time', context);
      return;
    }

    int minutes = (selectedOption == '30 mins'
        ? 30
        : (selectedOption == '2 hours'
            ? (2 * 60)
            : (selectedOption == '24 hours' ? (24 * 60) : null)));
    setState(() {
      isLoading = true;
    });

    var result = await LocationSharingService().sendShareLocationEvent(
        selectedContact.atSign, false,
        minutes: minutes);

    if (result == null) {
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
      return;
    }

    if (result[0] == true) {
      CustomToast().show('Share Location Request sent', context);
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
      providerCallback<HybridProvider>(NavService.navKey.currentContext,
          task: (provider) => provider.addNewEvent(HybridNotificationModel(
              NotificationType.Location,
              locationNotificationModel: result[1])),
          taskName: (provider) => provider.HYBRID_ADD_EVENT,
          showLoader: false,
          showDialog: false,
          onSuccess: (provider) {});
    } else {
      CustomToast()
          .show('Something went wrong ${result[1].toString()}', context);
      setState(() {
        isLoading = false;
      });
    }
  }
}
