import 'package:atsign_location_app/common_components/custom_appbar.dart';
import 'package:atsign_location_app/common_components/custom_button.dart';
import 'package:atsign_location_app/common_components/custom_input_field.dart';
import 'package:atsign_location_app/common_components/pop_button.dart';
import 'package:atsign_location_app/routes/route_names.dart';
import 'package:atsign_location_app/routes/routes.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_location_app/services/size_config.dart';

class RequestLocationSheet extends StatefulWidget {
  @override
  _RequestLocationSheetState createState() => _RequestLocationSheetState();
}

class _RequestLocationSheetState extends State<RequestLocationSheet> {
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
            width: 330,
            height: 50,
            hintText: 'Type @sign or search from contact',
            icon: Icons.contacts_rounded,
          ),
          Expanded(child: SizedBox()),
          Center(
            child: CustomButton(
              child: Text('Request',
                  style: TextStyle(
                      color: Theme.of(context).scaffoldBackgroundColor)),
              onTap: () =>
                  SetupRoutes.push(context, Routes.REQUEST_LOCATION_EVENT),
              bgColor: Theme.of(context).primaryColor,
              width: 164,
              height: 48,
            ),
          )
        ],
      ),
    );
  }
}
