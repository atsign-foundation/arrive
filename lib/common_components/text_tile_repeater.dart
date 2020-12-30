import 'package:atsign_location_app/common_components/tiles/text_tile.dart';
import 'package:atsign_common/services/size_config.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';

class TextTileRepeater extends StatelessWidget {
  final String title;
  final List<String> options;

  TextTileRepeater({this.title, this.options});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10.toWidth, 10.toHeight, 20.toWidth, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          title != null
              ? Text(title, style: CustomTextStyles().grey16)
              : SizedBox(),
          Expanded(
            child: ListView.separated(
              separatorBuilder: (context, index) {
                return Divider();
              },
              itemCount: options.length,
              itemBuilder: (context, index) {
                return SizedBox(
                  height: 60,
                  child: TextTile(title: options[index]),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
