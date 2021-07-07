import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/screens/contacts_screen.dart';
import 'package:at_contacts_group_flutter/widgets/custom_toast.dart';
import 'package:at_location_flutter/at_location_flutter.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/common_components/overlapping-contacts.dart';
import 'package:atsign_location_app/common_components/custom_appbar.dart';
import 'package:atsign_location_app/common_components/custom_button.dart';
import 'package:atsign_location_app/common_components/custom_input_field.dart';
import 'package:atsign_location_app/common_components/pop_button.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';

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
                      if (selectedList.isNotEmpty) {
                        setState(() {
                          selectedContact = selectedList[0];
                        });
                      }
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
              hint: Text('Select Duration',
                  style: TextStyle(
                      color: AllColors().LIGHT_GREY_LABEL,
                      fontSize: 15.toFont)),
              style:
                  TextStyle(color: AllColors().DARK_GREY, fontSize: 13.toFont),
              items: [
                'Select Duration',
                '30 mins',
                '2 hours',
                '24 hours',
                'Until turned off'
              ].map((String option) {
                return DropdownMenuItem<String>(
                  value: option == 'Select Duration' ? null : option,
                  child: option == 'Select Duration'
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
                    onTap: onShareTap,
                    bgColor: Theme.of(context).primaryColor,
                    width: 164,
                    height: 48,
                    child: Text('Share',
                        style: TextStyle(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            fontSize: 16.toFont)),
                  ),
          ),
        ],
      ),
    );
  }

  // ignore: always_declare_return_types
  onShareTap() async {
    if (selectedContact == null) {
      CustomToast().show('Select a contact', context);
      return;
    }
    if (selectedOption == null) {
      CustomToast().show('Select time', context);
      return;
    }

    var minutes = (selectedOption == '30 mins'
        ? 30
        : (selectedOption == '2 hours'
            ? (2 * 60)
            : (selectedOption == '24 hours' ? (24 * 60) : null)));
    setState(() {
      isLoading = true;
    });

    var result =
        await sendShareLocationNotification(selectedContact.atSign, minutes);

    if (result == null) {
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
      return;
    }

    if (result == true) {
      CustomToast().show('Share Location Request sent', context);
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
    } else {
      CustomToast().show('Something went wrong', context);
      setState(() {
        isLoading = false;
      });
    }
  }
}
