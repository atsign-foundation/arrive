import 'package:atsign_location_app/services/size_config.dart';
import 'package:flutter/material.dart';

class CustomHeader extends StatelessWidget {
  final Text title, action;
  //final IconData actionIcon;
  final Function actionEvent;
  CustomHeader(
      {this.title = const Text(''),
      this.action = const Text(''),
      this.actionEvent});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: SizeConfig().screenWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(child: Center(child: title)),
            InkWell(
              onTap: () {
                if (actionEvent != null) {
                  actionEvent();
                }
              },
              child: action,
            ),
          ],
        )
        // child: Stack(
        //   // mainAxisAlignment: MainAxisAlignment.end,
        //   children: <Widget>[
        //     Container(
        //       //margin: EdgeInsets.only(left: SizeConfig().screenWidth / 2 - 35),
        //       child: title,
        //     ),
        //     Positioned(
        //       right: 16.toWidth,
        //       child: Container(
        //         child: InkWell(
        //           onTap: () {
        //             if (actionEvent != null) {
        //               actionEvent();
        //             }
        //           },
        //           child: action,
        //         ),
        //       ),
        //     )
        //   ],
        // )
        );
  }
}
