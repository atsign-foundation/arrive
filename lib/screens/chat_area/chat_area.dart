import 'package:atsign_location_app/common_components/custom_appbar.dart';
import 'package:atsign_location_app/common_components/custom_input_field.dart';
import 'package:atsign_location_app/common_components/draggable_symbol.dart';
import 'package:atsign_location_app/common_components/message.dart';
import 'package:atsign_location_app/common_components/pop_button.dart';
import 'package:atsign_location_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_common_flutter/services/size_config.dart';

class ChatArea extends StatefulWidget {
  @override
  _ChatAreaState createState() => _ChatAreaState();
}

class _ChatAreaState extends State<ChatArea> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 743.toHeight,
      padding:
          EdgeInsets.fromLTRB(15.toWidth, 5.toHeight, 15.toWidth, 20.toHeight),
      child: Column(
        children: [
          DraggableSymbol(),
          CustomAppBar(
            title: 'Messages',
            action: PopButton(label: 'Close'),
          ),
          SizedBox(
            height: 10.toHeight,
          ),
          Message(isSend: false, text: 'Sed do eiusmod tempor.'),
          Message(isSend: false, text: 'Okay'),
          Message(isSend: true, text: 'okay'),
          Message(
              isSend: true,
              text: 'Excepteur sint occaecat cupidatat non proident.'),
          Expanded(child: SizedBox()),
          CustomInputField(
            height: 48,
            width: double.infinity,
            hintText: 'Type a message to notify others',
            icon: Icons.arrow_right,
            iconColor: AllColors().ORANGE,
          ),
        ],
      ),
    );
  }
}
