import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/screens/contacts_screen.dart';
import 'package:at_contacts_group_flutter/widgets/custom_toast.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/common_components/overlapping-contacts.dart';
import 'package:atsign_location_app/common_components/custom_appbar.dart';
import 'package:atsign_location_app/common_components/custom_button.dart';
import 'package:atsign_location_app/common_components/custom_input_field.dart';
import 'package:atsign_location_app/common_components/pop_button.dart';
import 'package:atsign_location_app/common_components/provider_callback.dart';
import 'package:atsign_location_app/services/backend_service.dart';
import 'package:atsign_location_app/services/nav_service.dart';
import 'package:atsign_location_app/services/request_location_service.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:atsign_location_app/view_models/hybrid_provider.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_location_app/plugins/at_events_flutter/models/hybrid_notifiation_model.dart';

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
      height: SizeConfig().screenHeight * 0.4,
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
            width: 330.toWidth,
            height: 50,
            //isReadOnly: true,
            hintText: 'Type @sign or search from contact',
            icon: Icons.contacts_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ContactsScreen(
                    asSelectionScreen: true,
                    context: context,
                    selectedList: (selectedList) {
                      print(selectedList);
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
              ? (OverlappingContacts(selectedList: [selectedContact]))
              : SizedBox(),
          Expanded(child: SizedBox()),
          Center(
            child: CustomButton(
              child: Text('Request',
                  style: TextStyle(
                      color: Theme.of(context).scaffoldBackgroundColor)),
              onTap: onRequestTap,
              bgColor: Theme.of(context).primaryColor,
              width: 164,
              height: 48,
            ),
          )
        ],
      ),
    );
  }

  onRequestTap() async {
    if (selectedContact == null) {
      CustomToast().show('Select a contact', context);
      return;
    }
    setState(() {
      isLoading = true;
    });

    var result = await RequestLocationService()
        .sendRequestLocationEvent(selectedContact.atSign);

    if (result[0] == true) {
      CustomToast().show('Location Request sent', context);
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
      providerCallback<HybridProvider>(NavService.navKey.currentContext,
          task: (provider) => provider.addNewEvent(BackendService.getInstance()
              .convertEventToHybrid(NotificationType.Location,
                  locationNotificationModel: result[1])),
          taskName: (provider) => provider.HYBRID_ADD_EVENT,
          showLoader: false,
          onSuccess: (provider) {});
    } else {
      CustomToast().show('some thing went wrong , try again.', context);
      setState(() {
        isLoading = false;
      });
    }
  }
}
