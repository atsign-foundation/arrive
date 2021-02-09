import 'package:flutter/material.dart';

bottomSheet(BuildContext context, T, double height, {Function onSheetCLosed}) {
  Future<void> future = showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: StadiumBorder(),
      builder: (BuildContext context) {
        return Container(
          height: height,
          decoration: new BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: new BorderRadius.only(
              topLeft: const Radius.circular(12.0),
              topRight: const Radius.circular(12.0),
            ),
          ),
          child: T,
        );
      });

  future.then((value) {
    if (onSheetCLosed != null) onSheetCLosed();
  });
}

// import 'package:flutter/material.dart';

// void bottomSheet(BuildContext context, T, double height) {
//   showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: StadiumBorder(),
//       builder: (BuildContext context) {
//         return Container(
//           height: height,
//           decoration: new BoxDecoration(
//             color: Theme.of(context).scaffoldBackgroundColor,
//             borderRadius: new BorderRadius.only(
//               topLeft: const Radius.circular(12.0),
//               topRight: const Radius.circular(12.0),
//             ),
//           ),
//           child: T,
//         );
//       });
// }
