import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/screens/contacts_screen.dart';
import 'package:at_location_flutter/at_location_flutter.dart';
import 'package:at_location_flutter/common_components/custom_toast.dart';
import 'package:atsign_location_app/common_components/custom_appbar.dart';
import 'package:atsign_location_app/common_components/custom_button.dart';
import 'package:atsign_location_app/common_components/custom_input_field.dart';
import 'package:atsign_location_app/common_components/overlapping-contacts.dart';
import 'package:atsign_location_app/common_components/pop_button.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';

class RequestLocationSheet extends StatefulWidget {
  @override
  _RequestLocationSheetState createState() => _RequestLocationSheetState();
}

class _RequestLocationSheetState extends State<RequestLocationSheet> {
  AtContact selectedContact;
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomAppBar(
            centerTitle: false,
            title: 'Request Location',
            action: PopButton(label: 'Cancel'),
          ),
          SizedBox(
            height: 25,
          ),
          Text('Request From', style: CustomTextStyles().greyLabel14),
          SizedBox(height: 10),
          CustomInputField(
            width: SizeConfig().screenWidth * 0.95,
            height: 50.toHeight,
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
                  [selectedContact],
                  onRemove: (_index) {
                    setState(() {
                      selectedContact = null;
                    });
                  },
                  isMultipleUser: false,
                ))
              : SizedBox(),
          Expanded(child: SizedBox()),
          Center(
            child: isLoading
                ? CircularProgressIndicator()
                : CustomButton(
                    onTap: onRequestTap,
                    bgColor: Theme.of(context).primaryColor,
                    width: 164,
                    height: 48,
                    child: Text(
                      'Request',
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
    if (selectedContact == null) {
      CustomToast().show('Select a contact', context, isError: true);
      return;
    }
    setState(() {
      isLoading = true;
    });

    var result = await sendRequestLocationNotification(selectedContact.atSign);

    if (result == null) {
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
      return;
    }

    if (result == true) {
      CustomToast().show('Location Request sent', context, isSuccess: true);
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
    } else {
      CustomToast().show('Something went wrong', context, isError: true);
      setState(() {
        isLoading = false;
      });
    }
  }
}
