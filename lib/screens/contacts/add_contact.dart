import 'dart:typed_data';

import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_common_flutter/widgets/custom_button.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:atsign_location_app/common_components/custom_circle_avatar.dart';
import 'package:atsign_location_app/utils/constants/text_strings.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';

class AddContact extends StatefulWidget {
  final String atSignName, name;
  final Uint8List image;
  final Function onSuccessCallback;
  const AddContact(
      {Key key, this.atSignName, this.name, this.image, this.onSuccessCallback})
      : super(key: key);

  @override
  _AddContactState createState() => _AddContactState();
}

class _AddContactState extends State<AddContact> {
  bool isContactAdding = false;
  String nickName;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 100,
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
                '${TextStrings.add} ${widget.atSignName} ${TextStrings.toContacts}',
                textAlign: TextAlign.center,
                style: CustomTextStyles().black16,
              ),
            )
          ],
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: (widget.name != null) ? 190.toHeight : 160.toHeight),
          child: Column(
            children: [
              SizedBox(
                height: 21.toHeight,
              ),
              CustomCircleAvatar(
                isMemoryImage: true,
                memoryImage: widget.image,
                contactInitial: widget.atSignName,
                size: 75,
              ),
              SizedBox(
                height: 10.toHeight,
              ),
              (widget.name != null)
                  ? Text(
                      widget.name,
                      style: CustomTextStyles().black16bold,
                    )
                  : SizedBox(),
              SizedBox(
                height: (widget.name != null) ? 2.toHeight : 0,
              ),
              Text(
                (widget.atSignName ?? ''),
                style: CustomTextStyles().black16,
              ),
            ],
          ),
        ),
        actionsPadding: EdgeInsets.only(left: 20, right: 20),
        actions: [
          TextFormField(
            autofocus: true,
            onChanged: (value) {
              nickName = value;
            },
            // validator: Validators.validateAdduser,
            decoration: InputDecoration(
              hintText: TextStrings.enterNickName,
            ),
            style: TextStyle(fontSize: 15.toFont),
          ),
          SizedBox(
            height: 10.toHeight,
          ),
          isContactAdding
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : SizedBox(
                  width: SizeConfig().screenWidth,
                  child: CustomButton(
                    buttonText: TextStrings.yes,
                    fontColor: Colors.white,
                    onPressed: () async {
                      setState(() {
                        isContactAdding = true;
                      });
                      await ContactService().addAtSign(
                        atSign: widget.atSignName,
                        nickName: nickName,
                      );
                      setState(() {
                        isContactAdding = false;
                      });

                      await ContactService().fetchContacts();

                      if (widget.onSuccessCallback != null) {
                        widget.onSuccessCallback();
                      }
                      Navigator.pop(context);
                    },
                  ),
                ),
          SizedBox(
            height: 10.toHeight,
          ),
          isContactAdding
              ? SizedBox()
              : SizedBox(
                  width: SizeConfig().screenWidth,
                  child: CustomButton(
                    buttonColor: Colors.white,
                    buttonText: TextStrings.no,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )),
        ],
      ),
    );
  }
}
