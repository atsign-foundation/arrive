import 'package:atsign_location_app/common_components/custom_button.dart';
import 'package:atsign_location_app/common_components/custom_input_field.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_location_app/services/size_config.dart';

class RequestLocation extends StatefulWidget {
  @override
  _RequestLocationState createState() => _RequestLocationState();
}

class _RequestLocationState extends State<RequestLocation> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(25),
      child: SingleChildScrollView(
        child: Container(
          height: SizeConfig().screenHeight * 0.4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text('Request Location',
                            style: CustomTextStyles().black16),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Cancel',
                          style: CustomTextStyles().orange16,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Text('Request From', style: CustomTextStyles().darkGrey14),
                  SizedBox(height: 10),
                  CustomInputField(
                    width: 330,
                    height: 50,
                    hintText: 'Type @sign or search from contact',
                    isIcon: true,
                    icon: Icons.contacts_rounded,
                  ),
                ],
              ),
              CustomButton(
                child:
                    Text('Request', style: TextStyle(color: AllColors().WHITE)),
                onTap: null,
                bgColor: AllColors().Black,
                width: 164,
                height: 48,
              )
            ],
          ),
        ),
      ),
    );
  }
}
