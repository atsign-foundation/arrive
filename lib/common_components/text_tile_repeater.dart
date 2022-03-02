import 'package:atsign_location_app/common_components/tiles/text_tile.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_location_app/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';

class TextTileRepeater extends StatelessWidget {
  final String? title;
  final ValueChanged<String>? onChanged;
  final List<String>? options;

  TextTileRepeater({this.title, this.options, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10.toWidth, 10.toHeight, 20.toWidth, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          title != null
              ? Text(title!, style: CustomTextStyles().grey16)
              : SizedBox(),
          Expanded(
            child: ListView.separated(
              separatorBuilder: (context, index) {
                return Divider();
              },
              itemCount: options!.length,
              itemBuilder: (context, index) {
                return SizedBox(
                  height: 60,
                  child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        onChanged!(options![index]);
                        Navigator.pop(context);
                      },
                      child: TextTile(title: options![index])),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
