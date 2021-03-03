import 'dart:typed_data';

import 'package:atsign_location_app/plugins/at_events_flutter/common_components/contacts_initials.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';

class CustomCircleAvatar extends StatelessWidget {
  final String image, contactInitial;
  final double size;
  final bool isMemoryImage;
  final Uint8List memoryImage;

  const CustomCircleAvatar(
      {Key key,
      this.image,
      this.size = 50,
      this.isMemoryImage = false,
      this.memoryImage,
      this.contactInitial})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: size.toFont,
      width: size.toFont,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size.toWidth),
      ),
      child: isMemoryImage
          ? memoryImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  child: Image.memory(
                    memoryImage,
                    width: 50,
                    height: 50,
                    fit: BoxFit.fill,
                  ),
                )
              : ContactInitial(initials: contactInitial.substring(1, 3))
          : CircleAvatar(
              radius: (size - 5).toFont,
              backgroundColor: Colors.transparent,
              backgroundImage: AssetImage(image),
            ),
    );
  }
}
