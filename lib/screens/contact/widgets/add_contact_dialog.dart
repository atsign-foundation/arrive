import 'package:atsign_location_app/common_components/custom_button.dart';
import 'package:atsign_location_app/services/validators.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:atsign_location_app/utils/text_strings.dart';

/// This widgets pops up when a contact is added it takes [name]
/// [handle] to display the name and the handle of the user and an
/// onTap function named as [onYesTap] for on press of [Yes] button of the dialog

import 'package:flutter/material.dart';
import 'package:atsign_location_app/services/size_config.dart';

class AddContactDialog extends StatelessWidget {
  final String name;
  final String handle;
  final Function(String) onYesTap;
  final formKey;
  String atsignName = '';
  AddContactDialog({
    Key key,
    this.name,
    this.handle,
    this.onYesTap,
    this.formKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double deviceTextFactor = MediaQuery.of(context).textScaleFactor;
    return Container(
        height: 100.toHeight * deviceTextFactor,
        width: 100.toWidth,
        child: SingleChildScrollView(
          child: AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.toWidth)),
            titlePadding: EdgeInsets.only(
                top: 20.toHeight, left: 25.toWidth, right: 25.toWidth),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    TextStrings().addContact,
                    textAlign: TextAlign.center,
                    style: CustomTextStyles().black16,
                  ),
                )
              ],
            ),
            content: ConstrainedBox(
              constraints:
                  BoxConstraints(maxHeight: 255.toHeight * deviceTextFactor),
              child: Column(
                children: [
                  SizedBox(
                    height: 20.toHeight,
                  ),
                  TextFormField(
                    autofocus: true,
                    onChanged: (value) {
                      atsignName = value;
                    },
                    validator: Validators.validateAdduser,
                    decoration: InputDecoration(
                      prefixText: '@',
                      prefixStyle: TextStyle(color: Colors.grey),
                      hintText: '\tEnter user atsign',
                    ),
                  ),
                  SizedBox(
                    height: 45.toHeight,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomButton(
                        height: 50.toHeight * deviceTextFactor,
                        child: Text(
                          TextStrings().addtoContact,
                          style: TextStyle(
                              color: Theme.of(context).scaffoldBackgroundColor),
                        ),
                        onTap: () => onYesTap(atsignName),
                        bgColor: Theme.of(context).primaryColor,
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20.toHeight,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomButton(
                        height: 50.toHeight * deviceTextFactor,
                        child: Text(
                          TextStrings().buttonCancel,
                          style: TextStyle(
                              color: Theme.of(context).scaffoldBackgroundColor),
                        ),
                        onTap: () => Navigator.pop(context),
                        bgColor: Theme.of(context).primaryColor,
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
